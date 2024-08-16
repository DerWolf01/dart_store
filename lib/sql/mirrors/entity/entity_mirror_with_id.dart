import 'package:dart_store/dart_store.dart';

class EntityMirrorWithId<T> extends EntityMirror<T> {
  EntityMirrorWithId.byType({required this.id, super.type}) : super.byType();
  EntityMirrorWithId.byClassMirror(
      {required this.id, required super.classMirror})
      : super.byClassMirror();

  final dynamic id;
}
