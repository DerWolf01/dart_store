import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/column.dart';

class InternalColumn extends Column {
  SQLDataType dataType;

  InternalColumn({
    required this.dataType,
    required super.constraints,
    required super.name,
  });


}
