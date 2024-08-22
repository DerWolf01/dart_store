import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql/connection/connection.dart';

class ManyToOneConnection extends ForeignKeyConnection {
  final EntityMirror referencingEntity;
  final EntityMirror referencedEntity;

  ManyToOneConnection(this.referencingEntity, this.referencedEntity);

  String get referencingColumn => '${referencedEntity.name}_id';
  String get referencedColumn => '${referencedEntity.name}_id';

  @override
  get connectionStatements => [
        "ALTER TABLE ${referencingEntity.name} ADD COLUMN IF NOT EXISTS $referencedColumn ${referencingEntity.primaryKeyType.runtimeType}",
        "ALTER TABLE  ${referencingEntity.name} DROP CONSTRAINT IF EXISTS $referencedColumn",
        'ALTER TABLE ${referencingEntity.name} ADD FOREIGN KEY  ($referencedColumn) REFERENCES ${referencedEntity.name}(id)'
      ];
}
