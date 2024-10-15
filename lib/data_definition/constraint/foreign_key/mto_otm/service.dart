import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/definiton.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/description.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class OneToManyAndManyToOneDefintionService with DartStoreUtility {
  Future<void> defineAndExecute(TableDescription tableDescription) async {
    await defineAndExecuteOneToMany(tableDescription);
    await defineAndExecuteManyToOne(tableDescription);
  }

  Future<void> defineAndExecuteManyToOne(
      TableDescription tableDescription) async {
    myLogger.d("defineAndExecuteManyToOne --> ${tableDescription.tableName}",
        header: "OneToManyAndManyToOneDefintionService");
    for (final column in tableDescription.manyToOneColumns()) {
      final referenced = TableService()
          .findTable(column.getForeignKey<ManyToOne>()!.referencedEntity);
      await TableService().createTable(referenced);
      final OneToManyAndManyToOneDescription manyToOneDescription =
          OneToManyAndManyToOneDescription(
              foreignKey: column.getForeignKey<ManyToOne>()!,
              oneToManyTableDescription: referenced,
              manyToOneTableDescription: tableDescription);
      final OneToManyAndManyToOneDefinition manyToOneDefinition =
          OneToManyAndManyToOneDefinition(description: manyToOneDescription);
      final statement = manyToOneDefinition.define();

      await executeSQL(statement);
    }
  }

  Future<void> defineAndExecuteOneToMany(
      TableDescription tableDescription) async {
    for (final column in tableDescription.oneToManyColumns()) {
      final foreignKey = column.getForeignKey<OneToMany>()!;
      final manyToOneTable =
          TableService().findTable(foreignKey.referencedEntity);

      final OneToManyAndManyToOneDescription oneToManyDescription =
          OneToManyAndManyToOneDescription(
              foreignKey: foreignKey,
              oneToManyTableDescription: tableDescription,
              manyToOneTableDescription: manyToOneTable);
      final OneToManyAndManyToOneDefinition oneToManyDefinition =
          OneToManyAndManyToOneDefinition(description: oneToManyDescription);
      final statement = oneToManyDefinition.define();

      myLogger.i(statement);
      await executeSQL(statement);
    }
  }
}
