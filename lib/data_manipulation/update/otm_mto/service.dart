import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/definiton.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/description.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';

class OneToManyAndManyToOneUpdateService {
  Future updateManyToOneConnection(EntityInstance oneToManyInstance,
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
        "UPDATE ${oneToManyAndManyToOneDefinition.connectionName} SET ${oneToManyInstance.tableName} = ${oneToManyPKey.dataType.convert(oneToManyPKey.value)} WHERE ${manyToOneInstance.tableName} = ${manyToOnePkey.dataType.convert(manyToOnePkey.value)}");
  }

  Future updateOneToManyConnection(
      {required List<EntityInstance> manyToOneInstances,
      required EntityInstance oneToManyInstance,
      required ForeignKey foreignKey}) async {
    for (final manyToOneInstance in manyToOneInstances) {
      await updateManyToOneConnection(
          oneToManyInstance, manyToOneInstance, foreignKey);
    }
  }

  Future<void> postUpdate(EntityInstance entityInstance) async {
    for (final foreignColumnInstance
        in entityInstance.oneToManyColumnsInstances()) {
      final List<EntityInstance> values = foreignColumnInstance.value;

      await updateOneToManyConnection(
          manyToOneInstances: values,
          oneToManyInstance: entityInstance,
          foreignKey: foreignColumnInstance.foreignKey);
    }

    for (final foreignColumnInstance
        in entityInstance.manyToOneColumnsInstances()) {
      final EntityInstance oneToManyInstance = foreignColumnInstance.value;

      await updateManyToOneConnection(
          oneToManyInstance, entityInstance, foreignColumnInstance.foreignKey);
    }
  }
}
