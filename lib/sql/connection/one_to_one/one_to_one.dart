import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql/connection/connection.dart';
import 'package:change_case/change_case.dart';

class OneToOneConnection extends ForeignKeyConnection {
  final EntityMirror entity$1;
  final EntityMirror entity$2;

  OneToOneConnection(this.entity$2, this.entity$1);

  String get connectionTableName => '${entity$1.name}_${entity$2.name}';

  @override
  List<String> get connectionStatements => [
        'CREATE TABLE IF NOT EXISTS $connectionTableName (id SERIAL PRIMARY KEY, ${entity$1.name}_id ${entity$1.primaryKeyType.sqlTypeName()} REFERENCES ${entity$1.name}(id), ${entity$2.name}_id ${entity$2.primaryKeyType.sqlTypeName()} REFERENCES ${entity$2.name}(id), UNIQUE(${entity$1.name}_id), UNIQUE(${entity$2.name}_id))'
      ];

  List<EntityMirror> get ordered =>
      [entity$1, entity$2]..sort((a, b) => a.name.compareTo(b.name));
}
