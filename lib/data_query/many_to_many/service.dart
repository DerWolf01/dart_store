import 'package:change_case/change_case.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/connection/description/service.dart';
import 'package:dart_store/converter/converter.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/many_to_many.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/service.dart';
import 'package:dart_store/where/statement.dart';
import 'package:dart_store/where/statement_filter.dart';
import 'package:postgres/postgres.dart';

// TODO: Implement logic to instanciate EntityInstance using a value
class ManyToManyQueryService with DartStoreUtility {
  Future<EntityInstance> postQuery(EntityInstance entityInstance,
      {List<Where> where = const []}) async {
    final pKey = entityInstance.primaryKeyColumn();
    final pKeyValue = pKey.value;
    if (entityInstance.primaryKeyColumn().value == -1 ||
        entityInstance.primaryKeyColumn().value == null) {
      throw Exception(
          "Entity of table ${entityInstance.tableName} has to be queryed before querying foreign columns");
    }

    for (final foreignColumn in TableService()
        .findTable(entityInstance.objectType)
        .manyToManyColumns()) {
      final referencedObjectType = foreignColumn.foreignKey.referencedEntity;

      final filteredWhere =
          filterWheres(where: where, externalColumnType: referencedObjectType);
      final referencedTableDescription =
          TableService().findTable(referencedObjectType);
      final TableConnectionDescription connectionDescription =
          TableConnectionDescriptionService().generateTableDescription(
              referencedTableDescription, entityInstance);

      final String internalColumnsSqlNamesWithoutId =
          referencedTableDescription.internalColumnsSqlNamesWithoutId;

      final statement =
          "SELECT ${referencedTableDescription.tableName}.id as id ${internalColumnsSqlNamesWithoutId.isNotEmpty ? ", $internalColumnsSqlNamesWithoutId" : ""} FROM ${referencedTableDescription.tableName} JOIN ${connectionDescription.tableName} ON ${connectionDescription.tableName}.${referencedTableDescription.tableName} =${referencedTableDescription.tableName}.id WHERE ${connectionDescription.tableName}.${entityInstance.tableName} = ${pKey.dataType.convert(pKeyValue)} ${WhereService().defineAndChainWhereStatements(where: filteredWhere).replaceAll("WHERE", "AND")}";
      print(statement);
      final Result result = await executeSQL(statement);

      final List<EntityInstance> items = [];

      for (final res in result.withNormalizedNames()) {
        final instance = ConversionService().mapToEntityInstance(
            description: referencedTableDescription, map: res);
        await DataQueryService().postQuery(
          entityInstance: instance,
          where: where,
        );
        items.add(instance);
      }

      print(
          "adding typeOf ${items.first.runtimeType} to value of EntityInstance and ${entityInstance.columns} ${entityInstance.columns.runtimeType}");

      entityInstance.columns.add(ManyToManyColumnInstance(
          mapId: foreignColumn.mapId,
          value: items,
          foreignKey: foreignColumn.foreignKey,
          constraints: foreignColumn.constraints,
          name: foreignColumn.name));
    }

    return entityInstance;
  }
}

extension NameNormailzer on Result {
  List<Map<String, dynamic>> withNormalizedNames() => map(
        (element) => element.toColumnMap().map(
              (key, value) => MapEntry(key.toCamelCase(), value),
            ),
      ).toList();
}
