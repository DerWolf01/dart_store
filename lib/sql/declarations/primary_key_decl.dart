import 'package:dart_store/dart_store.dart';

class PrimaryKeyDecl {
  const PrimaryKeyDecl(this.name, this.primaryKey, this.dataType);

  final String name;
  final PrimaryKey primaryKey;
  final SQLDataType dataType;
}

PrimaryKeyDecl primaryKeyDecl<T>({Type? type}) {
  late PrimaryKeyDecl primaryKeyDecl;
  for (final c in columnDecls<T>(type: type ?? T)) {
    final primaryKey = c.constraints.whereType<PrimaryKey>().firstOrNull;
    if (primaryKey != null) {
      primaryKeyDecl = PrimaryKeyDecl(c.name, primaryKey, c.dataType);
      return primaryKeyDecl;
    }
  }

  return primaryKeyDecl;
}
