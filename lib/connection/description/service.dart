import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/string_utils/sort_names.dart';

class TableConnectionDescriptionService {
  TableConnectionDescription generateTableDescription(
          TableDescription description, TableDescription description2) =>
      TableConnectionDescription(
          tableName: connectionName(description, description2),
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
            name: "${description.tableName}_id"),
        InternalColumn(
            dataType: description2.primaryKeyColumn().dataType,
            constraints: [],
            name: "${description2.tableName}_id"),
      ];

  String connectionName(
      TableDescription description, TableDescription description2) {
    final sorted = sortNames(description.tableName, description2.tableName);

    return "${sorted[0]}_${sorted[0]}";
  }
}
