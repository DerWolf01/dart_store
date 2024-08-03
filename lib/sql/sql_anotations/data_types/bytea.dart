import 'dart:io';

import 'package:dart_store/dart_store.dart';

class Bytea extends SQLDataType<File> {
  const Bytea({super.isNullable});

  @override
  convert(value) {
    if (value == null && isNullable == true) {
      return null;
    } else if (value == null && isNullable == false) {
      throw Exception("Value cannot be null");
    }
    return value!.readAsBytesSync();
  }
}
