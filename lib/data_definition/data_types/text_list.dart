import 'package:dart_store/dart_store.dart';

class TextList extends SQLDataType<List<String>> {
  const TextList({this.length, super.isNullable});

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
    return length != null ? "text[$length]" : "text[]";
  }
}
