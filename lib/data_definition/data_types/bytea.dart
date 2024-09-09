import 'dart:convert';
import 'dart:io';

import 'package:dart_store/data_definition/data_types/data_type.dart';

class Bytea extends SQLDataType<File> {
  const Bytea({super.isNullable});

  @override
  String sqlTypeName() {
    return 'TEXT';
  }

  @override
  String? convert(File? value) {
    if (value == null && isNullable == true) {
      return null;
    } else if (value == null && isNullable == false) {
      throw Exception("Value cannot be null");
    }

    return "'${base64Encode(value!.readAsBytesSync())}'";
  }
}