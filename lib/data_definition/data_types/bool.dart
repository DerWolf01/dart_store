import 'package:dart_store/data_definition/data_types/data_type.dart';

class Bool extends SQLDataType<bool> {
  const Bool({super.isNullable = false});

  @override
  convert(bool? value) {
    if (value == null && isNullable == true) {
      return null;
    } else if (value == null && isNullable == false) {
      throw Exception("Value cannot be null");
    }
    return value.toString() == "true" ? 'true' : 'false';
  }
}
