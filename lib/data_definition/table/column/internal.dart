import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/column.dart';

/// A column that is included in the table ittself.
class InternalColumn extends Column {
  SQLDataType dataType;

  InternalColumn({
    required this.dataType,
    required super.constraints,
    required super.name,
  });

  @override
  String get sqlName => name.toSnakeCase();
}
