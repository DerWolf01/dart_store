import 'package:dart_store/sql/sql_anotations/data_types/data_type.dart';

class Varchar extends SQLDataType<String> {
  const Varchar({super.isNullable});

  @override
  convert(value) {
    if (value == null && isNullable == false) {
      throw Exception('Value cannot be null for $runtimeType');
    } else if (value == null && isNullable == true) {
      return null;
    }
    return "'$value'";
  }
}
