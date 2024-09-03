import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';

class EntityInstanceService {
  entityInstanceByValueInstance(dynamic value) {
    final columnsInstances =
        ColumnInstanceService().extractColumnInstances(value);
    final table = TableService().findTable(value.runtimeType);
    return EntityInstance(
        objectType: value.runtimeType,
        tableName: table.tableName,
        columns: columnsInstances);
  }
}
