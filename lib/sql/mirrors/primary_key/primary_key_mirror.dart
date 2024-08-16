import 'package:dart_store/dart_store.dart';

class PrimaryKeyMirror {
  const PrimaryKeyMirror(this.name, this.primaryKey, this.dataType);

  final String name;
  final PrimaryKey primaryKey;
  final SQLDataType dataType;
}
