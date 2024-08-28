import 'package:dart_store/data_definition/data_types/data_type.dart';

class Bool extends SQLDataType {
  const Bool({super.isNullable = false});

  @override
  convert(value) {
    return value == 0 ? 'false' : 'true';
  }
}
