import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';

class EntityInstance extends TableDescription {
  EntityInstance(
      {required super.tableName, required List<ColumnInstance> columns})
      : super(columns: columns);

  @override
  List<ColumnInstance> get columns => super.columns as List<ColumnInstance>;




}
