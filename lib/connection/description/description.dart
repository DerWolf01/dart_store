import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/table_description.dart';

class TableConnectionDescription extends TableDescription {
  TableConnectionDescription({required super.entity, required super.columns})
      : super(objectType: dynamic);

  InternalColumn columnByName(String originalName) {
    final column = columns.whereType<InternalColumn>().firstOrNull;
    if (column == null) {
      throw Exception("No column found with name $originalName");
    }
    return column;
  }
}
