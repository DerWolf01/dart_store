import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/string_utils/sort_names.dart';
import 'package:change_case/change_case.dart';

class TableConnectionDescriptionService {
  TableConnectionDescription generateManyToOneAndOneToManyDescription(
      {required TableDescription oneToManyTableDescription,
      required TableDescription manyToOneTableDescription}) {
    return TableConnectionDescription(
        entity: Entity(
            name:
                "${oneToManyTableDescription.tableName}_${manyToOneTableDescription.tableName}"),
        columns: columns(oneToManyTableDescription, manyToOneTableDescription));
  }

  TableConnectionDescription generateTableDescription(
          TableDescription description, TableDescription description2) =>
      TableConnectionDescription(
          entity: Entity(name: connectionName(description, description2)),
          columns: columns(description, description2));

  List<InternalColumn> columns(
          TableDescription description, TableDescription description2) =>
      [
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

  String connectionName(
      TableDescription description, TableDescription description2) {
    final sorted = sortNames(description.tableName, description2.tableName);

    return "${sorted[0]}_${sorted[1]}";
  }
}
