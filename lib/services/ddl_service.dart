import 'dart:mirrors';
import 'package:dart_persistence_api/dart_store.dart';
import 'package:dart_persistence_api/services/collector_service.dart';
import 'package:dart_persistence_api/sql_anotations/constraints/constraint.dart';
import 'package:dart_persistence_api/sql_anotations/constraints/not_null.dart';
import 'package:dart_persistence_api/sql_anotations/data_types/data_type.dart';
import 'package:dart_persistence_api/sql_anotations/entity.dart';

class DDLService {
  Future<void> setConstraints() async {
    // Get all classes in the current package
    final classes = _getClasses();

    // Filter classes annotated with @Model
    final List<EntityDecl> entityDecls = [];

    for (final c in classes) {
      final entityDecl = _makeEntityDecl(c);
      entityDecls.add(entityDecl);
    }

    // Set constraints for each model class
    for (final entityDecl in entityDecls) {
      final tableName = _getTableName(entityDecl);
      final columns = _getColumns(entityDecl.classType);

      // Generate SQL statements to set constraints
      final sqlStatements =
          _generateSetConstraintStatements(tableName, columns);

      // Execute the SQL statements to set constraints
      for (final sql in sqlStatements) {
        print(sql);
        await _executeSQL(sql);
      }
    }
  }

  List<String> _generateSetConstraintStatements(
      String tableName, List<Column> columns) {
    final List<String> sqlStatements = [];

    for (final column in columns) {
      final columnName = column.name;
      final constraints = _getConstraints(column);

      for (final constraint in constraints) {
        final constraintName = constraint.runtimeType.toString();
        final sql = _generateSetConstraintStatement(
            tableName, columnName, constraintName);
        sqlStatements.add(sql);
      }
    }

    return sqlStatements;
  }

  List<SQLConstraint> _getConstraints(Column column) {
    final List<SQLConstraint> constraints = [];

    final fieldAnnotations = column.field.metadata;

    for (final annotation in fieldAnnotations) {
      if (annotation.reflectee is SQLConstraint) {
        constraints.add(annotation.reflectee);
      }
    }

    return constraints;
  }

  String _generateSetConstraintStatement(
      String tableName, String columnName, String constraintName) {
    return 'ALTER TABLE $tableName ADD CONSTRAINT $constraintName FOREIGN KEY ($columnName)';
  }

  Future<void> createTables() async {
    await dropTables();
    // Get all classes in the current package
    final classes = _getClasses();

    // Filter classes annotated with @Model
    final List<EntityDecl> entityDecls = [];

    for (final c in classes) {
      entityDecls.add(_makeEntityDecl(c));
    }
    print("entityDecls $entityDecls");

    // Create tables for each model class
    for (final entityDecl in entityDecls) {
      final tableName = _getTableName(entityDecl);
      final columns = _getColumns(entityDecl.classType);

      // Generate SQL statement to create table
      final sql =
          _generateCreateTableStatement(tableName.toLowerCase(), columns);

      // Execute the SQL statement to create the table
      print("executing $sql");
      await _executeSQL(sql);
      print("Table $tableName created");
    }
    await setConstraints();
  }

  List<ClassMirror> _getClasses() {
    return CollectorService().searchClassesWithAnnotation<Entity>();
  }

  EntityDecl _makeEntityDecl(ClassMirror classType) {
    final classAnnotations = classType.metadata;
    final Entity entityAnnotation = classAnnotations.firstWhere((annotation) {
      print(
          "annotation.reflectee ${annotation.reflectee} ${annotation.reflectee is Entity}");
      return annotation.reflectee is Entity;
    }).reflectee as Entity;
    return EntityDecl(classType, entityAnnotation);
  }

  String _getTableName(EntityDecl entityDecl) =>
      entityDecl.entity.name ??
      MirrorSystem.getName(entityDecl.classType.simpleName);

  List<Column> _getColumns(ClassMirror classMirror) {
    final List<Column> columns = [];

    final fields = classMirror.declarations.values.whereType<VariableMirror>();

    for (final field in fields) {
      final fieldAnnotations = field.metadata;

      List<SQLDataType> dataTypes = fieldAnnotations
          .map((annotation) => annotation.reflectee)
          .whereType<SQLDataType>()
          .toList();

      if (dataTypes.isEmpty) {
        continue;
      }

      final columnName = MirrorSystem.getName(field.simpleName);
      final dataType = dataTypes.first;
      final nullable =
          fieldAnnotations.any((annotation) => annotation.reflectee is NotNull);

      columns.add(Column(columnName, field, dataType, nullable: nullable));
    }

    return columns;
  }

  String _generateCreateTableStatement(String tableName, List<Column> columns) {
    final String columnDefinitions = columns.map((column) {
      final columnName = column.name;
      final dataType = column.dataType;
      final nullable = column.nullable ? 'NULL' : 'NOT NULL';
      return '$columnName ${dataType.runtimeType.toString()} $nullable';
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
class EntityDecl {
  const EntityDecl(this.classType, this.entity);
  final ClassMirror classType;
  final Entity entity;
}

class ConstraintDecl {
  const ConstraintDecl(this.constraint);
  final SQLConstraint constraint;
}

class Column {
  final String name;
  final DeclarationMirror field;
  final SQLDataType dataType;
  final bool nullable;

  Column(this.name, this.field, this.dataType, {this.nullable = false});
}
