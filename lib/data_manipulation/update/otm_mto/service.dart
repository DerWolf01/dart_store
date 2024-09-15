import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/definiton.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/description.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';

class OneToManyAndManyToOneUpdateService {
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

  Future updateManyToOneConnection(EntityInstance oneToManyInstance,
      EntityInstance manyToOneInstance, ForeignKey foreignKey) async {
    OneToManyAndManyToOneDescription description =
        OneToManyAndManyToOneDescription(
            foreignKey: foreignKey,
            oneToManyTableDescription: oneToManyInstance,
            manyToOneTableDescription: manyToOneInstance);
    OneToManyAndManyToOneDefinition oneToManyAndManyToOneDefinition =
        OneToManyAndManyToOneDefinition(description: description);
    final connectionName = oneToManyAndManyToOneDefinition.connectionName;
    final oneToManyPKey = oneToManyInstance.primaryKeyColumn();
    final manyToOnePkey = manyToOneInstance.primaryKeyColumn();
    final statement =
        "INSERT INTO $connectionName (${oneToManyInstance.tableName}, ${manyToOneInstance.tableName}) VALUES (${oneToManyPKey.dataType.convert(oneToManyPKey.value)}, ${manyToOnePkey.dataType.convert(manyToOnePkey.value)}) ON CONFLICT(${manyToOneInstance.tableName}) DO UPDATE SET ${oneToManyInstance.tableName} = ${oneToManyPKey.dataType.convert(oneToManyPKey.value)}  WHERE $connectionName.${manyToOneInstance.tableName} = ${manyToOnePkey.dataType.convert(manyToOnePkey.value)}";

    await dartStore.connection.execute(statement);
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
}
