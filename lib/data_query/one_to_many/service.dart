import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/connection/description/service.dart';
import 'package:dart_store/converter/converter.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/one_to_many.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/many_to_many/service.dart';
import 'package:dart_store/data_query/service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/filter_wheres.dart';
import 'package:dart_store/where/service.dart';
import 'package:dart_store/where/statement.dart';
import 'package:postgres/postgres.dart';

class OneToManyQueryService with DartStoreUtility {
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
        .oneToManyColumns()) {
      final referencedObjectType = foreignColumn.foreignKey.referencedEntity;
      final filteredWhere =
          filterWheres(where: where, externalColumnType: referencedObjectType);
      final referencedTableDescription =
          TableService().findTable(referencedObjectType);
      final TableConnectionDescription connectionDescription =
          TableConnectionDescriptionService().generateTableDescription(
              referencedTableDescription, entityInstance);
      final Result result = await executeSQL(
          "SELECT ${referencedTableDescription.tableName}.id as id, ${referencedTableDescription.internalColumnsSqlNamesWithoutId} FROM ${referencedTableDescription.tableName} JOIN ${connectionDescription.tableName} ON ${connectionDescription.tableName}.${referencedTableDescription.tableName} =${referencedTableDescription.tableName}.id WHERE ${connectionDescription.tableName}.${entityInstance.tableName} = ${pKey.dataType.convert(pKeyValue)} ${WhereService().defineAndChainWhereStatements(where: filteredWhere).replaceAll("WHERE", "AND")}");

      final List<EntityInstance> items = [];

      for (final res in result.withNormalizedNames()) {
        final instance = ConversionService().mapToEntityInstance(
            description: referencedTableDescription, map: res);
        DataQueryService().postQuery(
          entityInstance: instance,
          where: where,
        );
        items.add(instance);
      }
      entityInstance.columns.add(OneToManyColumnInstance(
          mapId: foreignColumn.mapId,
          value: items,
          foreignKey: foreignColumn.foreignKey,
          constraints: foreignColumn.constraints,
          name: foreignColumn.name));
    }

    return entityInstance;
  }
}
