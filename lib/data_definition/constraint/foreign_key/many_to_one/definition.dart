
import 'package:dart_store/data_definition/constraint/foreign_key/many_to_one/description.dart';
import 'package:dart_store/data_definition/data_definition.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';

class ManyToOneDefinition extends DataDefinition {
  ManyToOneDefinition({
    required this.description,
  });
  final ManyToOneDescription description;
  @override
  String define() {
    final String referencingTableName =
        description.referencingMember.tableDescription.tableName;
    final String referencedTableName =
        description.referencedMember.tableDescription.tableName;
    final String referencingColumnName =
        description.referencingMember.column.name;
    final InternalColumn referencedColumn = description.referencedMember.column;
    final String referencedColumnName = referencedColumn.name;
    final SQLDataType primaryKeyType = referencedColumn.dataType;

    return """
ALTER TABLE $referencingTableName ADD COLUMN IF NOT EXISTS $referencingColumnName ${primaryKeyType.sqlTypeName()} NOT NULL;
ALTER TABLE $referencingTableName ADD FOREIGN KEY ($referencingColumnName) REFERENCES $referencedTableName($referencedColumnName);
""";
  }
}
