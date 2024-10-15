import 'package:dart_store/data_definition/data_types/data_type.dart';

/// A data type to define a list of integers.
class IntegerList extends SQLDataType<List<int>> {
  final int? length;

  const IntegerList({this.length, super.isNullable});

  @override
  convert(value) {
    if (value == null && isNullable == false) {
      throw Exception('Value cannot be null for $runtimeType');
    } else if (value == null && isNullable == true) {
      return null;
    }
    return "'{${value?.map(
          (e) => e,
        ).join(",")}}'";
  }

  @override
  String sqlTypeName() {
    return length != null ? "INTEGER[$length]" : "INTEGER[]";
  }
}
