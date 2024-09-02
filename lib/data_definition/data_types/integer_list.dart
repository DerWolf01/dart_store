import 'package:dart_store/data_definition/data_types/data_type.dart';

class IntegerList extends SQLDataType<List<int>> {
  const IntegerList({this.length, super.isNullable});

  final int? length;

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
