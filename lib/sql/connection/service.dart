import 'dart:mirrors';

import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql/mirrors/entity/entity_instance_mirror.dart';

abstract class ConnectionSerivce<OperatesWith> {
  Future<OperatesWith> insert(EntityInstanceMirror entityInstanceMirror);
  Future<OperatesWith> query(EntityMirror entityMirror);
}
