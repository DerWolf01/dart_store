import 'dart:io';

import 'package:dart_store/data_definition/data_types/data_type.dart';

/// A data type to define a byte array.
class Bytea extends SQLDataType<File> {
  const Bytea({super.isNullable});

  @override
  String? convert(File? value) {
    if (value == null && isNullable == true) {
      return null;
    } else if (value == null && isNullable == false) {
      throw Exception("Value cannot be null");
    }

    return "'{${value!.readAsBytesSync().toList().join(',')}}'";
  }

  @override
  String sqlTypeName() {
    return 'INTEGER[]';
  }
}
