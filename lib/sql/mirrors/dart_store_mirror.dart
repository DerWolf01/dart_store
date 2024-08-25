import 'package:dart_store/dart_store.dart';

extension ColumnMirrorNames on ColumnMirror {
  String get camelCase => name.toString();
  String get snakeCase => name.toString().camelCaseToSnakeCase();
}

