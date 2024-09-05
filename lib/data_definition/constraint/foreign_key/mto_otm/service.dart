import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/definiton.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/description.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class OneToManyAndManyToOneDefintionService with DartStoreUtility {
  Future<void> defineAndExecute(TableDescription tableDescription) async {
    await defineAndExecuteOneToMany(tableDescription);
    await defineAndExecuteManyToOne(tableDescription);
  }

  Future<void> defineAndExecuteManyToOne(
      TableDescription tableDescription) async {
    for (final column in tableDescription.manyToOneColumns()) {
      await TableService().createTable(TableService()
          .findTable(column.getForeignKey<ManyToOne>()!.referencedEntity));
      final referenced = TableService()
          .findTable(column.getForeignKey<ManyToOne>()!.referencedEntity);

      final OneToManyAndManyToOneDescription manyToOneDescription =
          OneToManyAndManyToOneDescription(
              foreignKey: column.getForeignKey<ManyToOne>()!,
              oneToManyTableDescription: referenced,
              manyToOneTableDescription: tableDescription);
      final OneToManyAndManyToOneDefinition oneToManyDefinition =
          OneToManyAndManyToOneDefinition(description: manyToOneDescription);
      await executeSQL(oneToManyDefinition.define());
    }
  }

  Future<void> defineAndExecuteOneToMany(
      TableDescription tableDescription) async {
    for (final column in tableDescription.oneToManyColumns()) {
      final referenced = TableService()
          .findTable(column.getForeignKey<OneToMany>()!.referencedEntity);

      final OneToManyAndManyToOneDescription oneToManyDescription =
          OneToManyAndManyToOneDescription(
              foreignKey: column.getForeignKey<OneToMany>()!,
              oneToManyTableDescription: tableDescription,
              manyToOneTableDescription: referenced);
      final OneToManyAndManyToOneDefinition oneToManyDefinition =
          OneToManyAndManyToOneDefinition(description: oneToManyDescription);

      await executeSQL(oneToManyDefinition.define());
    }
  }
}
