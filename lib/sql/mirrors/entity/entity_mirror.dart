import 'dart:mirrors';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/mapping/mapping.dart';
import 'package:dart_store/sql/mirrors/dart_store_mirror.dart';

class EntityMirror<T> {
  EntityMirror.byType({Type? type}) : classMirror = reflectClass(type ?? T) {
    initFields();
  }
  EntityMirror.byClassMirror({
    required this.classMirror,
  }) {
    initFields();
  }

  final ClassMirror classMirror;
  late final Entity entity;
  late final List<ColumnMirror> column;
  late final PrimaryKeyMirror primaryKeyMirror;

  SQLDataType get primaryKeyType => primaryKeyMirror.dataType;

  get name =>
      entity.name ?? MirrorSystem.getName(classMirror.simpleName).toLowerCase();

  bool get isEntity =>
      classMirror.metadata.any((annotation) => annotation.reflectee is Entity);

  void initFields() {
    entity = _extractEntityAnotation();
    column = _generateColumnMirrors();
    primaryKeyMirror = _extractPrimaryKeyMirror();
  }

  List<ColumnMirror> _generateColumnMirrors() {
    final List<ColumnMirror> columns = [];

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

      final isForeignField = constraints.whereType<ForeignKey>().isNotEmpty;
      if (isForeignField) {
      } else if (dataTypes.isEmpty) {
        continue;
      }

      final columnName = MirrorSystem.getName(field.simpleName);
      final dataType = isForeignField ? ForeignField() : dataTypes.first;

      columns.add(ColumnMirror(
          name: columnName,
          field: field,
          dataType: dataType,
          constraints: constraints,
          mappings: field.metadata
              .where((element) => element.reflectee is Mapping)
              .map((e) => e.reflectee as Mapping)
              .toList()));
    }

    return columns;
  }

  Entity _extractEntityAnotation() => classMirror.metadata
      .firstWhere((annotation) => annotation.reflectee is Entity,
          orElse: () => throw Exception(
              "Class ${classMirror.simpleName} is not anotated with '@Entity()'"))
      .reflectee as Entity;

  PrimaryKeyMirror _extractPrimaryKeyMirror() {
    final pKey = column
        .where(($1) => $1.constraints.any(
              (($2) => $2 is PrimaryKey),
            ))
        .firstOrNull;
    if (pKey == null) {
      throw Exception("Entity must have a primary key");
    }

    return PrimaryKeyMirror(
      pKey,
    );
  }
}

class PrimaryKeyMirror extends ColumnMirror {
  PrimaryKeyMirror(ColumnMirror column)
      : primaryKey = column.constraints.whereType<PrimaryKey>().first,
        super(
            name: column.name,
            constraints: column.constraints,
            dataType: column.dataType,
            field: column.field,
            mappings: []);

  @override
  final PrimaryKey primaryKey;
}
