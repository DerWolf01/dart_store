import 'package:dart_store/sql/sql_anotations/data_types/data_type.dart';

class Varchar extends SQLDataType<String> {
  const Varchar();

  @override
  convert(value) {
    if (value == null && isNullable == false) {
      throw Exception('Value cannot be null');
    } else if (value == null && isNullable == true) {
      return null;
    }
    return "'$value'";
  }
}
