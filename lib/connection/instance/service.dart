import 'package:dart_store/connection/description/service.dart';
import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/string_utils/sort_names.dart';

/// This service is crucial for managing the relationships between different
/// tables in the database. It ensures that the connections are properly
/// established and maintained, allowing for efficient data retrieval and
/// manipulation.
///
/// The methods provided in this service facilitate the creation of many-to-one
/// and one-to-many relationships, as well as the generation of connection
/// instances between tables.
class TableConnectionInstanceService {
  List<InternalColumnInstance> columns(
    int connectionId,
    EntityInstance description,
    EntityInstance description2,
  ) {
    final res = [
      InternalColumnInstance(
          value: connectionId,
          dataType: Serial(),
          constraints: [PrimaryKey(autoIncrement: true)],
          name: "id"),
      InternalColumnInstance(
          value: description.primaryKeyColumn().value,
          dataType: description.primaryKeyColumn().dataType,
          constraints: [],
          name: description.tableName),
      InternalColumnInstance(
          value: description2.primaryKeyColumn().value,
          dataType: description2.primaryKeyColumn().dataType,
          constraints: [],
          name: description2.tableName),
    ];

    myLogger.d("$res", header: "TableConnectionInstanceService --> columns()");
    return res;
  }

  String connectionName(
      EntityInstance description, EntityInstance description2) {
    final sorted = sortNames(description.tableName, description2.tableName);

    final name = "${sorted[0]}_${sorted[1]}";
    myLogger.d(name,
        header: "TableConnectionInstanceService --> connectionName()");
    return name;
  }

  TableConnectionInstance generateManyToOneAndOneToManyConnectionInstance(
      {required EntityInstance oneToMany,
      required EntityInstance manyToOne,
      int conenctionId = -1}) {
    final description = TableConnectionDescriptionService()
        .generateManyToOneAndOneToManyDescription(
            oneToManyTableDescription: oneToMany,
            manyToOneTableDescription: manyToOne);

    final connectinoInstance = TableConnectionInstance(
        entity: description.entity,
        columns: <ColumnInstance>[
          InternalColumnInstance(
              value: conenctionId,
              dataType: Serial(),
              constraints: [PrimaryKey(autoIncrement: true)],
              name: "id"),
          InternalColumnInstance(
              value: oneToMany.primaryKeyColumn().value,
              dataType: oneToMany.primaryKeyColumn().dataType,
              constraints: [],
              name: oneToMany.tableName.toCamelCase()),
          InternalColumnInstance(
              value: manyToOne.primaryKeyColumn().value,
              dataType: manyToOne.primaryKeyColumn().dataType,
              constraints: [],
              name: manyToOne.tableName.toCamelCase())
        ]);

    myLogger.d("$connectinoInstance",
        header:
            "TableConnectionInstanceService --> generateManyToOneAndOneToManyConnectionInstance(oneToMany: $oneToMany, manyToOne: $manyToOne)");

    return connectinoInstance;
  }

  TableConnectionInstance generateTableConnectionInstance(
          EntityInstance instance, EntityInstance instance2,
          {int conenctionId = -1}) =>
      TableConnectionInstance(
          entity: Entity(name: connectionName(instance, instance2)),
          columns: columns(conenctionId, instance, instance2));
}
