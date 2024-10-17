import 'package:dart_store/data_definition/data_definition.dart';
import 'package:dart_store/my_logger.dart';

///
class OneToOneDefinition extends DataDefinition {
  final OneToOneDescription description;
  OneToOneDefinition({
    required this.description,
  });
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

    final columnName1 = tableName1;

    final column2 = table1.column;
    final primaryKeyType2 = table1.primaryKeyType();

    final columnName2 = tableName2;
    final res =
        "CREATE TABLE IF NOT EXISTS $connectionName (id SERIAL PRIMARY KEY, $columnName1 ${primaryKeyType1.sqlTypeName()} NOT NULL UNIQUE, $columnName2 ${primaryKeyType2.sqlTypeName()} NOT NULL UNIQUE, FOREIGN KEY ($columnName1) REFERENCES $tableName1(id) ON DELETE CASCADE, FOREIGN KEY ($columnName2) REFERENCES $tableName2(id) ON DELETE CASCADE)";
    myLogger.d(res,
        header: "OneToOneDefinition --> define() using $description");
    return res;
  }
}
