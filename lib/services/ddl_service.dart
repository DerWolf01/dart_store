import 'dart:mirrors';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/mapping/mapping.dart';
import 'package:dart_store/services/collector_service.dart';
import 'package:dart_store/services/constraint_service.dart';
import 'package:dart_store/sql/connection/many_to_one.dart';
import 'package:dart_store/sql/sql_anotations/data_types/created_at.dart';
import 'package:dart_store/sql/sql_anotations/data_types/updated_at.dart';
import 'package:postgres/postgres.dart';

class DDLService {
  Future<void> createTables() async {
    // Get all classes in the current package
    final classes = _getClasses();

    // Filter classes annotated with @Model
    final List<EntityMirror> entityMirrors = [];

    for (final c in classes) {
      entityMirrors.add(EntityMirror.byClassMirror(classMirror: c));
    }

    // Create tables for each model class
    for (final entityMirror in entityMirrors) {
      final tableName = _getTableName(entityMirror);
      final columns = _getColumns(entityMirror.classMirror);
      final manyToOneColumns = columns
          .where((element) => element.getForeignKey() is ManyToOne)
          .toList();
      print("manyToOneColumns --> $manyToOneColumns");
      for (final column in manyToOneColumns) {
        await createTable(EntityMirror.byType(
            type: column.getForeignKey()!.referencedEntity));
      }

      // Generate SQL statement to create table
      final sql =
          await _generateCreateTableStatement(tableName.toLowerCase(), columns);
      print("executing $sql");
      await _executeSQL(sql);
      // Execute the SQL statement to create the table
    }
    for (final entityMirror in entityMirrors) {
      await ConstraintService().setCoinstraints(entityMirror);
      // enableUpdatedAtTrigger(_getTableName(entityMirror));
    }
    return;
  }

  Future<void> createTable(EntityMirror entityMirror) async {
    final tableName = _getTableName(entityMirror);
    final columns = _getColumns(entityMirror.classMirror);
    // Generate SQL statement to create table
    final sql =
        await _generateCreateTableStatement(tableName.toLowerCase(), columns);
    // Execute the SQL statement to create the table
    // print("executing $sql");
    await _executeSQL(sql);

    await ConstraintService().setCoinstraints(entityMirror);
    // enableUpdatedAtTrigger(_getTableName(entityMirror));
    return;
  }

  List<ClassMirror> _getClasses() {
    return CollectorService().searchClassesWithAnnotation<Entity>();
  }

  String _getTableName(EntityMirror entityMirror) =>
      entityMirror.entity.name ??
      MirrorSystem.getName(entityMirror.classMirror.simpleName).toLowerCase();

  List<ColumnMirror> _getColumns(ClassMirror classMirror) {
    final List<ColumnMirror> columns = [];

    final fields = classMirror.declarations.values.whereType<VariableMirror>();

    // TODO create FieldMirror that includes if is entity or not
    for (final Field field in fields.map(
      (e) => Field(variableMirror: e),
    )) {
      final fieldAnnotations = field.metadata;

      List<SQLConstraint> constraints = fieldAnnotations
          .map((annotation) => annotation.reflectee)
          .whereType<SQLConstraint>()
          .toList();

      List<SQLDataType> dataTypes =
          constraints.whereType<ForeignKey>().isNotEmpty
              ? [ForeignField()]
              : fieldAnnotations
                  .map((annotation) => annotation.reflectee)
                  .whereType<SQLDataType>()
                  .toList();

      if (dataTypes.isEmpty) {
        print(
            "No data type found for field ${field.variableMirror.simpleName}. Will not be included in table!");
        continue;
      }

      final columnName = MirrorSystem.getName(field.variableMirror.simpleName);
      final dataType = dataTypes.first;

      columns.add(ColumnMirror(
          name: columnName,
          field: field.variableMirror,
          dataType: dataType,
          constraints: constraints,
          mappings: fieldAnnotations
              .where((element) => element.reflectee is Mapping)
              .map((e) => e.reflectee as Mapping)
              .toList()));
    }

    return columns;
  }

  Future<String> _generateCreateTableStatement(
      String tableName, List<ColumnMirror> columns) async {
    final List<String> columnDefinitions = [];
    for (final column in columns.where(
      (element) => element.dataType is! ForeignField,
    )) {
      if (column.dataType is CreatedAt) {
        columnDefinitions.add(
            "${column.name} timestamp with time zone NOT NULL DEFAULT now()");
        continue;
      } else if (column.dataType is UpdatedAt) {
        await enableUpdatedAtTrigger(tableName, column.name);
        columnDefinitions.add(
            "${column.name} timestamp with time zone NOT NULL DEFAULT now()");
        continue;
      }
      final columnName = column.name;
      final dataType = column.dataType;
      final nullable = column.nullable ? 'NOT NULL' : "";

      final isPrimaryKey = column.isPrimaryKey ? 'PRIMARY KEY' : '';
      final isUnique = column.unique ? 'UNIQUE' : '';

      columnDefinitions
          .add('$columnName ${dataType.sqlTypeName()} $nullable $isPrimaryKey');
    }

    if (columnDefinitions.isEmpty) {
      throw Exception("No columns found for entity $tableName");
    }
    print("Creating table $tableName with columns $columnDefinitions");
    var sql =
        'CREATE TABLE IF NOT EXISTS $tableName ( ${columnDefinitions.join(", ")} ) ';

    return sql;
  }

  Future<void> dropTables() async {
    // Get all classes in the current package
    final classes = _getClasses();

    // Filter classes annotated with @Model
    final List<EntityMirror> entityMirrors = [];

    for (final c in classes) {
      entityMirrors.add(EntityMirror.byClassMirror(classMirror: c));
    }

    // Drop tables for each model class
    for (final entityMirror in entityMirrors) {
      final tableName = _getTableName(entityMirror);

      // Generate SQL statement to drop table
      final sql = _generateDropTableStatement(tableName);

      // Execute the SQL statement to drop the table
      await _executeSQL(sql);
    }
  }

  String _generateDropTableStatement(String tableName) {
    return 'DROP TABLE IF EXISTS $tableName';
  }

  Future<void> _executeSQL(String sql) async {
    await dartStore.execute(sql);
  }

  /// enables trigger and extension for updated_at column
  /// catches exception if trigger already exists and ignores it
  /// reason for that being that "IF NOT EXISTS" is not supported for triggers
  Future enableUpdatedAtTrigger(String tableName, String triggerName) async {
    try {
      await _executeSQL("CREATE EXTENSION IF NOT EXISTS moddatetime;");
      await _executeSQL(
          "CREATE TRIGGER update_timestamp BEFORE UPDATE ON $tableName FOR EACH ROW EXECUTE PROCEDURE moddatetime($triggerName);");
    } catch (e) {
      if (e is ServerException &&
          e.message.contains(
              'trigger "update_timestamp" for relation "$tableName" already exists')) {
        return;
      }
      throw Exception("Error enabling updatedAt trigger: $e");
    }
    return;
  }
}

// TODO
// Add constraintts, columns <Datatype, FieldName> to EntityMirror

class Field {
  const Field({required this.variableMirror});

  final VariableMirror variableMirror;

  bool get isEntity =>
      metadata.where((element) => element.reflectee is Entity).isNotEmpty;

  List<InstanceMirror> get metadata => variableMirror.metadata;
}
