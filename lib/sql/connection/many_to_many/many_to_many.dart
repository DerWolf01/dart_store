import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql/connection/connection.dart';
import 'package:change_case/change_case.dart';

class ManyToManyConnection extends ForeignKeyConnection {
  final EntityMirror entity$1;
  final EntityMirror entity$2;

  ManyToManyConnection(this.entity$2, this.entity$1);

  String get connectionTableName => '${entity$1.name}_${entity$2.name}';

  String get entity$1Name => entity$1.name;
  String get entity$2Name =>
      entity$1Name == entity$2.name ? "${entity$2.name}_1" : entity$2.name;
  @override
  List<String> get connectionStatements => [
        'CREATE TABLE IF NOT EXISTS $connectionTableName (id SERIAL PRIMARY KEY, ${entity$1Name}_id ${entity$1.primaryKeyType.sqlTypeName()} REFERENCES ${entity$1Name}(id), ${entity$2Name}_id ${entity$2.primaryKeyType.sqlTypeName()} REFERENCES ${entity$2.name}(id), UNIQUE(${entity$1Name}_id, ${entity$2Name}_id))'
      ];

  List<EntityMirror> get ordered =>
      [entity$1, entity$2]..sort((a, b) => a.name.compareTo(b.name));
}
