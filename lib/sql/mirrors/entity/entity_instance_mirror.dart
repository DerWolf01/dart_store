import 'dart:mirrors';

import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql/mirrors/entity/entity_mirror_with_id.dart';

class EntityInstanceMirror extends EntityMirror {
  EntityInstanceMirror({
    required this.instanceMirror,
  }) : super.byClassMirror(classMirror: instanceMirror.type);

  late final InstanceMirror instanceMirror;

  dynamic get id => instanceMirror.getField(#id).reflectee;

  InstanceMirror fieldInstanceMirror(String fieldName) {
    return instanceMirror.getField(Symbol(fieldName));
  }

  dynamic field(String fieldName) {
    return instanceMirror.getField(Symbol(fieldName)).reflectee;
  }

  EntityMirrorWithId get entityMirrorWithId =>
      EntityMirrorWithId.byClassMirror(id: id, classMirror: classMirror);
}
