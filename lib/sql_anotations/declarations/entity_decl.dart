import 'dart:mirrors';

import 'package:dart_store/sql_anotations/declarations/column_decl.dart';
import 'package:dart_store/sql_anotations/entity.dart';

class EntityDecl {
  const EntityDecl(
      {required this.classMirror, required this.entity, required this.column});
  final ClassMirror classMirror;
  final Entity entity;
  final List<ColumnDecl> column;

  String get name =>
      entity.name ?? MirrorSystem.getName(classMirror.simpleName).toLowerCase();
}

EntityDecl entityDecl<T>({Type? type}) {
  final classMirror = reflectClass(type ?? T);
  final classAnnotations = classMirror.metadata;
  final Entity entityAnnotation = classAnnotations.firstWhere((annotation) {
    print(
        "annotation.reflectee ${annotation.reflectee} ${annotation.reflectee is Entity}");
    return annotation.reflectee is Entity;
  }).reflectee as Entity;
  return EntityDecl(
      classMirror: classMirror,
      entity: entityAnnotation,
      column: columnDecls(type: type ?? T));
}