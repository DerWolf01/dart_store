import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/connection/description/service.dart';
import 'package:dart_store/converter/converter.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/definiton.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/description.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/service.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/many_to_one.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/many_to_many/service.dart';
import 'package:dart_store/data_query/service.dart';
import 'package:dart_store/data_query/statement.dart';
import 'package:dart_store/statement/compositor.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/filter_wheres.dart';
import 'package:dart_store/where/statement.dart';
import 'package:postgres/postgres.dart';

class ManyToOneQueryService with DartStoreUtility {
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
        .manyToOneColumns()) {
      final referencedObjectType = foreignColumn.foreignKey.referencedEntity;

      final referencedTableDescription =
          TableService().findTable(referencedObjectType);
      final OneToManyAndManyToOneDescription manyToOneDescription =
          OneToManyAndManyToOneDescription(
              foreignKey: foreignColumn.foreignKey,
              oneToManyTableDescription: entityInstance,
              manyToOneTableDescription: referencedTableDescription);
      final OneToManyAndManyToOneDefinition oneToManyDefinition =
          OneToManyAndManyToOneDefinition(description: manyToOneDescription);

      final connectionName = oneToManyDefinition.connectionName;
      final statement =
          "SELECT ${referencedTableDescription.tableName}.id as id, ${referencedTableDescription.internalColumnsSqlNamesWithoutId} FROM ${referencedTableDescription.tableName} JOIN $connectionName ON $connectionName.${referencedTableDescription.tableName} =${referencedTableDescription.tableName}.id WHERE $connectionName.${entityInstance.tableName} = ${pKey.dataType.convert(pKeyValue)}";
      print(statement);
      final Result result = await executeSQL(statement);

      final List<EntityInstance> items = [];

      for (final res in result.withNormalizedNames()) {
        print("normalized: $res");
        final instance = ConversionService().mapToEntityInstance(
            description: referencedTableDescription, map: res);
        DataQueryService().postQuery(
          entityInstance: instance,
          where: where,
        );
        items.add(instance);
      }
      print(items);
      entityInstance.columns.add(ManyToOneColumnInstance(
          mapId: foreignColumn.mapId,
          value: items.first,
          foreignKey: foreignColumn.foreignKey,
          constraints: foreignColumn.constraints,
          name: foreignColumn.name));
    }

    return entityInstance;
  }
}
