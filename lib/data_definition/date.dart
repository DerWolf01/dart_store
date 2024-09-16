import 'package:dart_store/dart_store.dart';

class Date extends SQLDataType<DateTime> {
  @override
  String? convert(DateTime? value) {
    if (value == null && isNullable == true) {
      return null;
    } else if (value == null && isNullable == false) {
      throw Exception("Value cannot be null");
    }

    return "'${value!.toIso8601String()}'";
  }

  @override
  String sqlTypeName() {
    return 'INTEGER[]';
  }
}
