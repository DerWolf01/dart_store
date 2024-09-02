import 'package:dart_store/data_definition/constraint/foreign_key/one_to_many/description.dart';
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
    final referencedTableName = referencedTableDescription.tableName;
    final primaryKeyColumn = referencingTableDescription.primaryKeyColumn();
    return """
ALTER TABLE $referencedTableName ADD COLUMN IF NOT EXISTS ${primaryKeyColumn.name} ${primaryKeyColumn.dataType.sqlTypeName()} NOT NULL;
ALTER TABLE $referencedTableName ADD FOREIGN KEY (${primaryKeyColumn.name}) REFERENCES $referencedTableName(${primaryKeyColumn.name});
""";
  }
}
