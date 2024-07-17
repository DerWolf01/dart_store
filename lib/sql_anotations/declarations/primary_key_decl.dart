import 'package:dart_store/sql_anotations/constraints/primary_key.dart';
import 'package:dart_store/sql_anotations/declarations/column_decl.dart';

class PrimaryKeyDecl {
  const PrimaryKeyDecl(this.name, this.primaryKey);
  final String name;
  final PrimaryKey primaryKey;
}

PrimaryKeyDecl primaryKeyDecl<T>({Type? type}) {
  late PrimaryKeyDecl primaryKeyDecl;
  for (final c in columnDecls<T>(type: type ?? T)) {
    final primaryKey = c.constraints.whereType<PrimaryKey>().firstOrNull;
    if (primaryKey != null) {
      primaryKeyDecl = PrimaryKeyDecl(c.name, primaryKey);
      return primaryKeyDecl;
    }
  }

  return primaryKeyDecl;
}
