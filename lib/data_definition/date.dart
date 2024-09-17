import 'package:dart_store/dart_store.dart';

class Date extends SQLDataType<DateTime> {
  const Date();
  @override
  String? convert(DateTime? value) {
    if (value == null && isNullable == true) {
      return null;
    } else if (value == null && isNullable == false) {
      throw Exception("Value cannot be null");
    }

    return "'${value!.toSqlConformFormat()}'";
  }

  @override
  String sqlTypeName() {
    return 'timestamp';
  }
}

extension DateTimeFormatter on DateTime {
  toSqlConformFormat() {
    final utc = toUtc();
    return "${utc.year}-${utc.month}-${utc.day} ${utc.hour}:${utc.minute}:${utc.second}.${utc.millisecond}";
  }
}
