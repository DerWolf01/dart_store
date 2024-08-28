import 'package:dart_store/data_definition/constraint/foreign_key/many_to_many/description.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/one_to_one/description.dart';
import 'package:dart_store/data_definition/data_definition.dart';

class OneToOneDefinition extends DataDefinition {
  OneToOneDefinition({
    required this.description,
  });
  final OneToOneDescription description;
  @override
  String define() {
    final membersOrdered = description.membersOrderedByTableName();
    final table1 = membersOrdered[0];
    final table2 = membersOrdered[1];
    final tableName1 = table1.tableDescription.tableName;
    final tableName2 = table2.tableDescription.tableName;
    final connectionName = "${tableName1}_$tableName2";
    final column1 = table1.column;
    final primaryKeyType1 = table1.primaryKeyType();

    final columnName1 = "${tableName1}_${column1.name}";

    final column2 = table1.column;
    final primaryKeyType2 = table1.primaryKeyType();

    final columnName2 = "${tableName2}_${column2.name}";
    return '''
CREATE TABLE IF NOT EXISTS $connectionName (
  $columnName1 ${primaryKeyType1.sqlTypeName()} NOT NULL UNIQUE,
  $columnName2 ${primaryKeyType2.sqlTypeName()} NOT NULL UNIQUE,
  PRIMARY KEY($columnName1, $columnName2),
  FOREIGN KEY ($columnName1) REFERENCES $tableName1($columnName1),
  FOREIGN KEY ($columnName2) REFERENCES $tableName2($columnName2)
)
''';
  }
}
