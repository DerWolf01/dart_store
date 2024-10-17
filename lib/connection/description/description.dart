import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/my_logger.dart';

class TableConnectionDescription extends TableDescription {
  TableConnectionDescription({required super.entity, required super.columns})
      : super(objectType: dynamic);
  InternalColumn columnByName(String originalName) {
    final column = columns.whereType<InternalColumn>().firstOrNull;
    if (column == null) {
      myLogger.e("No column found with name $originalName",
          header: "TableConnectionDescription --> columnByName()",
          stackTrace: StackTrace.current);
      throw Exception("No column found with name $originalName");
    }
    myLogger.d("$originalName --> $column",
        header: "TableConnectionDescription --> columnByName()");
    return column;
  }

  @override
  String toString() {
    return 'TableConnectionDescription{entity: $entity, columns: $columns}';
  }
}
