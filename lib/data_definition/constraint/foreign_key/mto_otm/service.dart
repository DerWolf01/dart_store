import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/definiton.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/description.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

/// A service to define and execute sql statements associated with one to many and many to one relationships.
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
      myLogger.d("column --> ${column.name}",
          header:
              "OneToManyAndManyToOneDefintionService --> defineAndExecuteManyToOne(tableDescription: $tableDescription)");

      final referenced = TableService()
          .findTable(column.getForeignKey<ManyToOne>()!.referencedEntity);
      myLogger.d("referenced --> ${referenced.tableName}",
          header:
              "OneToManyAndManyToOneDefintionService --> defineAndExecuteManyToOne(tableDescription: $tableDescription)");
      await TableService().createTable(referenced);

      final OneToManyAndManyToOneDescription manyToOneDescription =
          OneToManyAndManyToOneDescription(
              foreignKey: column.getForeignKey<ManyToOne>()!,
              oneToManyTableDescription: referenced,
              manyToOneTableDescription: tableDescription);
      myLogger.d(manyToOneDescription,
          header:
              "OneToManyAndManyToOneDefintionService --> defineAndExecuteManyToOne(tableDescription: $tableDescription)");
      final OneToManyAndManyToOneDefinition manyToOneDefinition =
          OneToManyAndManyToOneDefinition(description: manyToOneDescription);
      final definition = manyToOneDefinition.define();
      myLogger.d(definition,
          header:
              "OneToManyAndManyToOneDefintionService --> defineAndExecuteManyToOne(tableDescription: $tableDescription)");
      final statement = definition;

      await executeSQL(statement);
    }
  }

  Future<void> defineAndExecuteOneToMany(
      TableDescription tableDescription) async {
    for (final column in tableDescription.oneToManyColumns()) {
      myLogger.d("column --> ${column.name}",
          header:
              "OneToManyAndManyToOneDefintionService --> defineAndExecuteOneToMany(tableDescription: $tableDescription)");
      final foreignKey = column.getForeignKey<OneToMany>()!;
      myLogger.d("foreignKey --> ${foreignKey.referencedEntity}",
          header:
              "OneToManyAndManyToOneDefintionService --> defineAndExecuteOneToMany(tableDescription: $tableDescription)");
      final manyToOneTable =
          TableService().findTable(foreignKey.referencedEntity);
      myLogger.d("manyToOneTable --> ${manyToOneTable.tableName}",
          header:
              "OneToManyAndManyToOneDefintionService --> defineAndExecuteOneToMany(tableDescription: $tableDescription)");
      final OneToManyAndManyToOneDescription oneToManyDescription =
          OneToManyAndManyToOneDescription(
              foreignKey: foreignKey,
              oneToManyTableDescription: tableDescription,
              manyToOneTableDescription: manyToOneTable);

      myLogger.d(oneToManyDescription,
          header:
              "OneToManyAndManyToOneDefintionService --> defineAndExecuteOneToMany(tableDescription: $tableDescription)");
      final OneToManyAndManyToOneDefinition oneToManyDefinition =
          OneToManyAndManyToOneDefinition(description: oneToManyDescription);
      myLogger.d(oneToManyDefinition.define(),
          header:
              "OneToManyAndManyToOneDefintionService --> defineAndExecuteOneToMany(tableDescription: $tableDescription)");
      final statement = oneToManyDefinition.define();

      myLogger.d(statement,
          header:
              "OneToManyAndManyToOneDefintionService --> defineAndExecuteOneToMany(tableDescription: $tableDescription)");
      await executeSQL(statement);
    }
  }
}
