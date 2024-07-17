import 'package:dart_store/sql_anotations/data_types/data_type.dart';

class Varchar extends SQLDataType<String> {
  const Varchar();

  @override
  convert(value) {
    return "'$value'";
  }
}
