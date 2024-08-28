import 'package:dart_store/data_definition/constraint/many_to_many/description.dart';
import 'package:dart_store/data_definition/data_definition.dart';

class ManyToManyDefinition extends DataDefinition {
  ManyToManyDefinition({
    required this.description,
  });
  final ManyToManyDescription description;
  @override
  String define() {
    final membersOrdered = description.membersOrderedByTableName();
    final table1 = membersOrdered[0];
    final table2 = membersOrdered[1];
    final tableName1 = table1.tableDescription.tableName;
    final tableName2 = table2.tableDescription.tableName;
    final connectionName = "${tableName1}_$tableName2";

    final primaryKeyType1 = table1.primaryKeyType();

    final columnName1 = "${tableName1}_id";

    final primaryKeyType2 = table1.primaryKeyType();

    final columnName2 = "${tableName2}_id";
    return '''
CREATE TABLE IF NOT EXISTS $connectionName (
  ${connectionName}_id SERIAL PRIMARY KEY,
  $columnName1 ${primaryKeyType1.sqlTypeName()} NOT NULL,
  $columnName2 ${primaryKeyType2.sqlTypeName()} NOT NULL,
  FOREIGN KEY ($columnName1) REFERENCES $tableName1($columnName1),
  FOREIGN KEY ($columnName2) REFERENCES $tableName2($columnName2),
  UNIQUE($columnName1, $columnName2)
)
''';
  }
}
