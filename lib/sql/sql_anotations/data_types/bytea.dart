import 'dart:convert';
import 'dart:io';

import 'package:dart_store/dart_store.dart';

class Bytea extends SQLDataType<dynamic> {
  const Bytea({super.isNullable});

  @override
  String? convert(value) {
    if (value == null && isNullable == true) {
      return null;
    } else if (value == null && isNullable == false) {
      throw Exception("Value cannot be null");
    }
    if (value is File) {
      return "'${base64.encode(value.readAsBytesSync())}'";
    }
    return "'${base64.encode(value)}'";
  }
}
