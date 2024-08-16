import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql/connection/connection.dart';

class OneToManyConnection extends ForeignKeyConnection {
  final EntityMirror referencingEntity;
  final EntityMirror referencedEntity;

  OneToManyConnection(this.referencingEntity, this.referencedEntity);

  String get referencingColumn => '${referencingEntity.name}_id';

  @override
  get connectionStatements => [
        "ALTER TABLE ${referencedEntity.name} ADD COLUMN IF NOT EXISTS $referencingColumn ${referencingEntity.primaryKeyType.runtimeType}",
        "ALTER TABLE ${referencedEntity.name} DROP CONSTRAINT IF EXISTS $referencingColumn",
        'ALTER TABLE ${referencedEntity.name} ADD FOREIGN KEY  ($referencingColumn) REFERENCES ${referencingEntity.name}(id)'
      ];
}
