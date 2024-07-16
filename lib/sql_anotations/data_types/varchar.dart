import 'package:dart_persistence_api/sql_anotations/data_types/data_type.dart';

class Varchar extends SQLDataType<String> {
  const Varchar();

  @override
  convert(value) {
    return "'$value'";
  }
}
