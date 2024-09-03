import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/table_description.dart';

class TableConnectionDescription extends TableDescription {
  TableConnectionDescription({required super.tableName, required super.columns})
      : super(objectType: dynamic);

  InternalColumn columnByName(String originalName) => columns
      .whereType<InternalColumn>()
      .firstWhere((element) => element.name == originalName);
}
