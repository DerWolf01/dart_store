import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/string_utils/sort_names.dart';

class TableConnectionDescriptionService {
  List<InternalColumn> columns(
      TableDescription description, TableDescription description2) {
    final columns = [
      InternalColumn(
          dataType: Serial(),
          constraints: [PrimaryKey(autoIncrement: true)],
          name: "id"),
      InternalColumn(
          dataType: description.primaryKeyColumn().dataType,
          constraints: [],
          name: description.tableName.toCamelCase()),
      InternalColumn(
          dataType: description2.primaryKeyColumn().dataType,
          constraints: [],
          name: description2.tableName.toCamelCase()),
    ];

    myLogger.d("$columns",
        header: "TableConnectionDescriptionService --> columns()");
    return columns;
  }

  String connectionName(
      TableDescription description, TableDescription description2) {
    final sorted = sortNames(description.tableName, description2.tableName);

    final name = "${sorted[0]}_${sorted[1]}";
    myLogger.d(name,
        header:
            "TableConnectionDescriptionService --> connectionName($description, $description2)");

    return name;
  }

  TableConnectionDescription generateManyToOneAndOneToManyDescription(
      {required TableDescription oneToManyTableDescription,
      required TableDescription manyToOneTableDescription}) {
    final description = TableConnectionDescription(
        entity: Entity(
            name:
                "${oneToManyTableDescription.tableName}_${manyToOneTableDescription.tableName}"),
        columns: columns(oneToManyTableDescription, manyToOneTableDescription));

    myLogger.d("$description",
        header:
            "TableConnectionDescriptionService --> generateManyToOneAndOneToManyDescription()");
    return description;
  }

  TableConnectionDescription generateTableDescription(
      TableDescription description, TableDescription description2) {
    final description0 = TableConnectionDescription(
        entity: Entity(name: connectionName(description, description2)),
        columns: columns(description, description2));

    myLogger.d("$description0",
        header:
            "TableConnectionDescriptionService --> generateTableDescription($description, $description2)");

    return description0;
  }
}
