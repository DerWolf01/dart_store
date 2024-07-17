import 'package:dart_persistence_api/sql_anotations/constraints/primary_key.dart';
import 'package:dart_persistence_api/sql_anotations/declarations/column_decl.dart';

class PrimaryKeyDecl {
  const PrimaryKeyDecl(this.name, this.primaryKey);
  final String name;
  final PrimaryKey primaryKey;
}

PrimaryKeyDecl primaryKeyDecl<T>() {
  late PrimaryKeyDecl primaryKeyDecl;
  for (final c in columnDecls<T>()) {
    final primaryKey = c.constraints.whereType<PrimaryKey>().firstOrNull;
    if (primaryKey != null) {
      primaryKeyDecl = PrimaryKeyDecl(c.name, primaryKey);
      return primaryKeyDecl;
    }
  }

  return primaryKeyDecl;
}
