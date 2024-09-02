import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/string_utils/sort_names.dart';

class TableConnectionInstanceService {
  TableConnectionInstance generateTableConnectionInstance(
          EntityInstance instance, EntityInstance instance2,
          {int conenctionId = -1}) =>
      TableConnectionInstance(
          tableName: connectionName(instance, instance2),
          columns: columns(conenctionId, instance, instance2));

  List<InternalColumnInstance> columns(
    int connectionId,
    EntityInstance description,
    EntityInstance description2,
  ) =>
      [
        InternalColumnInstance(
            value: connectionId,
            dataType: Serial(),
            constraints: [PrimaryKey(autoIncrement: true)],
            name: "id"),
        InternalColumnInstance(
            value: description.primaryKeyColumn().value,
            dataType: description.primaryKeyColumn().dataType,
            constraints: [],
            name: "${description.tableName}_id"),
        InternalColumnInstance(
            value: description2.primaryKeyColumn().value,
            dataType: description2.primaryKeyColumn().dataType,
            constraints: [],
            name: "${description2.tableName}_id"),
      ];

  String connectionName(
      EntityInstance description, EntityInstance description2) {
    final sorted = sortNames(description.tableName, description2.tableName);

    return "${sorted[0]}_${sorted[0]}";
  }
}
