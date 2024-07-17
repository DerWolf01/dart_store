import 'dart:mirrors';
import 'package:dart_persistence_api/dart_store.dart';
import 'package:dart_persistence_api/services/collector_service.dart';
import 'package:dart_persistence_api/services/constraint_service.dart';
import 'package:dart_persistence_api/sql_anotations/constraints/constraint.dart';
import 'package:dart_persistence_api/sql_anotations/constraints/not_null.dart';
import 'package:dart_persistence_api/sql_anotations/data_types/data_type.dart';
import 'package:dart_persistence_api/sql_anotations/declarations/column_decl.dart';
import 'package:dart_persistence_api/sql_anotations/declarations/entity_decl.dart';
import 'package:dart_persistence_api/sql_anotations/declarations/primary_key_decl.dart';
import 'package:dart_persistence_api/sql_anotations/entity.dart';

class DDLService {
  Future<void> createTables() async {
    // Get all classes in the current package
    final classes = _getClasses();

    // Filter classes annotated with @Model
    final List<EntityDecl> entityDecls = [];

    for (final c in classes) {
      entityDecls.add(_makeEntityDecl(c));
    }

    // Create tables for each model class
    for (final entityDecl in entityDecls) {
      final tableName = _getTableName(entityDecl);
      final columns = _getColumns(entityDecl.classMirror);

      // Generate SQL statement to create table
      final sql =
          _generateCreateTableStatement(tableName.toLowerCase(), columns);

      // Execute the SQL statement to create the table
      // print("executing $sql");
      await _executeSQL(sql);
      print("Entity $tableName created");
    }
    for (final entityDecl in entityDecls) {
      await ConstraintService().setCoinstraints(entityDecl);
    }
    return;
  }

  List<ClassMirror> _getClasses() {
    return CollectorService().searchClassesWithAnnotation<Entity>();
  }

  EntityDecl _makeEntityDecl(ClassMirror classMirror) {
    final classAnnotations = classMirror.metadata;
    final Entity entityAnnotation = classAnnotations.firstWhere((annotation) {
      print(
          "annotation.reflectee ${annotation.reflectee} ${annotation.reflectee is Entity}");
      return annotation.reflectee is Entity;
    }).reflectee as Entity;
    return EntityDecl(
        classMirror: classMirror,
        entity: entityAnnotation,
        column: _getColumns(classMirror));
  }

  String _getTableName(EntityDecl entityDecl) =>
      entityDecl.entity.name ??
      MirrorSystem.getName(entityDecl.classMirror.simpleName);

  List<ColumnDecl> _getColumns(ClassMirror classMirror) {
    final List<ColumnDecl> columns = [];

    final fields = classMirror.declarations.values.whereType<VariableMirror>();

    for (final field in fields) {
      final fieldAnnotations = field.metadata;

      List<SQLDataType> dataTypes = fieldAnnotations
          .map((annotation) => annotation.reflectee)
          .whereType<SQLDataType>()
          .toList();

      List<SQLConstraint> constraints = fieldAnnotations
          .map((annotation) => annotation.reflectee)
          .whereType<SQLConstraint>()
          .toList();

      if (dataTypes.isEmpty) {
        print(
            "No data type found for field $field. Will not be included in table!");
        continue;
      }

      final columnName = MirrorSystem.getName(field.simpleName);
      final dataType = dataTypes.first;

      columns.add(ColumnDecl(
          name: columnName,
          field: field,
          dataType: dataType,
          constraints: constraints));
    }

    return columns;
  }

  String _generateCreateTableStatement(
      String tableName, List<ColumnDecl> columns) {
    final String columnDefinitions = columns.map((column) {
      final columnName = column.name;
      final dataType = column.dataType;
      final nullable = column.nullable ? 'NULL' : 'NOT NULL';
      final isPrimaryKey = column.isPrimaryKey ? 'PRIMARY KEY' : '';

      return '$columnName ${dataType.runtimeType.toString()} $nullable $isPrimaryKey';
    }).join(', ');
    if (columnDefinitions.isEmpty) {
      throw Exception("No columns found for entity $tableName");
    }
    var sql = 'CREATE TABLE IF NOT EXISTS $tableName ( $columnDefinitions )';
    print(sql);
    return sql;
  }

  Future<void> dropTables() async {
    // Get all classes in the current package
    final classes = _getClasses();

    // Filter classes annotated with @Model
    final List<EntityDecl> entityDecls = [];

    for (final c in classes) {
      entityDecls.add(_makeEntityDecl(c));
    }

    // Drop tables for each model class
    for (final entityDecl in entityDecls) {
      final tableName = _getTableName(entityDecl);

      // Generate SQL statement to drop table
      final sql = _generateDropTableStatement(tableName);
      print(sql);
      // Execute the SQL statement to drop the table
      await _executeSQL(sql);
      print("Table $tableName dropped");
    }
  }

  String _generateDropTableStatement(String tableName) {
    return 'DROP TABLE IF EXISTS $tableName';
  }

  Future<void> _executeSQL(String sql) async {
    await dartStore.execute(sql);
  }
}
// TODO 
// Add constraintts, columns <Datatype, FieldName> to EntityDecl
