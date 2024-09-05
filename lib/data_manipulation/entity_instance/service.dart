import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';

class EntityInstanceService {
  dynamic entityInstanceByValueInstance(dynamic value) {
    if (value is List) {
      return value
          .map((e) {
            entityInstanceByValueInstance(e);
          })
          .whereType<EntityInstance>()
          .toList();
    }
    final List<ColumnInstance> columnsInstances =
        ColumnInstanceService().extractColumnInstances(value);
    final table = TableService().findTable(value.runtimeType);
    return EntityInstance(
        tableName: table.tableName,
        objectType: value.runtimeType,
        columns: columnsInstances);
  }
}
