import 'package:dart_store/data_definition/data_types/data_type.dart';

/// A data type to define a varchar value.
class Varchar extends SQLDataType<String> {
  const Varchar({super.isNullable});

  @override
  convert(value) {
    if (value == null && isNullable == false) {
      throw Exception('Value cannot be null for $runtimeType');
    } else if (value == null && isNullable == true) {
      return null;
    }
    return "'${value?.replaceStringLiterals()}'";
  }
}
