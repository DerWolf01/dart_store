import 'dart:mirrors';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql/declarations/column_decl.dart';
import 'package:dart_store/sql/sql_anotations/entity.dart';

class EntityDecl {
  EntityDecl(
      {required this.classMirror, required this.entity, required this.column})
      : primaryKeyDecl = column
            .where((element) =>
                element.constraints.whereType<PrimaryKey>().firstOrNull != null)
            .map((e) => PrimaryKeyDecl(e))
            .first;

  final ClassMirror classMirror;
  final Entity entity;
  final List<ColumnDecl> column;
  final PrimaryKeyDecl primaryKeyDecl;

  SQLDataType get primaryKeyType => primaryKeyDecl.dataType;

  get name =>
      entity.name ?? MirrorSystem.getName(classMirror.simpleName).toLowerCase();
}

EntityDecl entityDecl<T>({Type? type}) {
  final classMirror = reflectClass(type ?? T);
  final classAnnotations = classMirror.metadata;
  final Entity entityAnnotation = classAnnotations.firstWhere((annotation) {
    return annotation.reflectee is Entity;
  }).reflectee as Entity;
  return EntityDecl(
      classMirror: classMirror,
      entity: entityAnnotation,
      column: columnDecls(type: type ?? T));
}

class PrimaryKeyDecl extends ColumnDecl {
  PrimaryKeyDecl(ColumnDecl column)
      : primaryKey = column.constraints.whereType<PrimaryKey>().first,
        super(
            name: column.name,
            constraints: column.constraints,
            dataType: column.dataType,
            field: column.field);

  final PrimaryKey primaryKey;
}
