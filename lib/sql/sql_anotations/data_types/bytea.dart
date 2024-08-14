import 'dart:convert';
import 'dart:io';

import 'package:dart_store/dart_store.dart';

class BinaryData extends SQLDataType<dynamic> {
  const BinaryData({super.isNullable});

  @override
  String sqlTypeName() {
    return 'TEXT';
  }

  @override
  String? convert(value) {
    //TODO implement convert
    // if (value == null && isNullable == true) {
    //   return null;
    // } else if (value == null && isNullable == false) {
    //   throw Exception("Value cannot be null");
    // }
    // if (value is File) {
    //   return "'${base64.encode(value.readAsBytesSync())}'";
    // }
    return "'$value'";
  }
}
