import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/definiton.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/description.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';
import 'package:dart_store/data_manipulation/delete/service.dart';

class OneToManyAndManyToOneDeleteService {
  Future deleteConnections(EntityInstance oneToManyInstance,
      EntityInstance manyToOneInstance, ForeignKey foreignKey) async {
    OneToManyAndManyToOneDescription description =
        OneToManyAndManyToOneDescription(
            foreignKey: foreignKey,
            oneToManyTableDescription: oneToManyInstance,
            manyToOneTableDescription: manyToOneInstance);
    OneToManyAndManyToOneDefinition oneToManyAndManyToOneDefinition =
        OneToManyAndManyToOneDefinition(description: description);

    final oneToManyPKey = oneToManyInstance.primaryKeyColumn();
    final manyToOnePkey = manyToOneInstance.primaryKeyColumn();

    await dartStore.connection.execute(
        "DELETE FROM ${oneToManyAndManyToOneDefinition.connectionName} WHERE ${oneToManyInstance.tableName} = ${oneToManyPKey.dataType.convert(oneToManyPKey.value)} AND ${manyToOneInstance.tableName} = ${manyToOnePkey.dataType.convert(manyToOnePkey.value)}");
  }

  Future<void> preDelete(EntityInstance entityInstance) async {
    for (final foreignColumnInstance
        in entityInstance.oneToManyColumnsInstances()) {
      final List<EntityInstance> values = foreignColumnInstance.value;

      for (final oneOfManyItemsInstance in values) {
        await deleteConnections(entityInstance, oneOfManyItemsInstance,
            foreignColumnInstance.foreignKey);
        if (foreignColumnInstance.mapId) {
          continue;
        }
        await DeleteService().delete(oneOfManyItemsInstance);
      }
    }

    for (final foreignColumnInstance
        in entityInstance.manyToOneColumnsInstances()) {
      final EntityInstance oneToManyInstance = foreignColumnInstance.value;

      await deleteConnections(
          oneToManyInstance, entityInstance, foreignColumnInstance.foreignKey);
      if (foreignColumnInstance.mapId) {
        continue;
      }
      // TODO: evaluate if oneToMany entity should be deleted also optionally.
      // await DeleteService().delete(oneToManyInstance);
    }
  }
}
