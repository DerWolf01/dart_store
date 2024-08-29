import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql/connection/many_to_many/many_to_many.dart';
import 'package:dart_store/sql/connection/service.dart';
import 'package:dart_store/sql/mirrors/entity/entity_instance_mirror.dart';
import 'package:dart_store/sql/mirrors/entity/entity_mirror.dart';
import 'package:dart_store/sql/mirrors/entity/entity_mirror_with_id.dart';

class ManyToManyService extends ConnectionSerivce<List<dynamic>> {
  @override
  Future<List<dynamic>> insert(EntityInstanceMirror entityInstanceMirror,
      List<EntityMirrorWithId> ids) async {
    final manyToManyColumns = entityInstanceMirror.column
        .where((element) => element.getForeignKey() is ManyToMany)
        .toList();
    for (final column in manyToManyColumns) {
      final manyToMany = column.getForeignKey() as ManyToMany;
      final connection = ManyToManyConnection(entityInstanceMirror.entityMirror,
          EntityMirror.byType(type: manyToMany.referencedEntity));
      final values = {
        connection.referencedColumn: entityInstanceMirror.id,
        connection.column: entityInstanceMirror.field(column.name)
      };
      await connection.insert(values);
    }
  }

  @override
  Future query(EntityMirror entityMirror) {
    // TODO: implement query
    throw UnimplementedError();
  }
}
