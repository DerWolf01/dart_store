import 'package:dart_store/sql_anotations/data_types/data_type.dart';

class Bool extends SQLDataType {
  const Bool();

  @override
  convert(value) {
    return value == 0 ? 'false' : 'true';
  }
}
