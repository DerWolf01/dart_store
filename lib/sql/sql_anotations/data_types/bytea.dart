import 'dart:io';

import 'package:dart_store/dart_store.dart';

class Bytea extends SQLDataType<File> {
  const Bytea();

  @override
  convert(value) {
    return value.readAsBytesSync();
  }
}

