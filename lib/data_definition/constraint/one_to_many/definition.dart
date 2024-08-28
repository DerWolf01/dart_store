import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/one_to_many/description.dart';
import 'package:dart_store/data_definition/data_definition.dart';

class OneToManyDefinition extends DataDefinition {
  OneToManyDefinition({
    required this.description,
  });
  final OneToManyDescription description;
  @override
  String define() {
    final referencingTableDescription =
        description.referencingMember.tableDescription;
    final referencedTableDescription =
        description.referencedMember.tableDescription;
    final referencingTableName = referencingTableDescription.tableName;
    final referencedTableName = referencedTableDescription.tableName;
    final primaryKeyColumn = referencingTableDescription.primaryKeyColumn();
    return """
ALTER TABLE $referencedTableName ADD COLUMN IF NOT EXISTS ${primaryKeyColumn.name} ${primaryKeyColumn.dataType.sqlTypeName()} NOT NULL;
ALTER TABLE $referencedTableName ADD FOREIGN KEY (${primaryKeyColumn.name}) REFERENCES $referencedTableName(${primaryKeyColumn.name});
""";
  }
}
