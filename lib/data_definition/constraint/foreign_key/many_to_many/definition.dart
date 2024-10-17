import 'package:dart_store/data_definition/data_definition.dart';
import 'package:dart_store/my_logger.dart';

/// A class that defines a many-to-many relationship between two tables.
///
/// This class generates the SQL statement to create a join table that
/// connects two other tables in a many-to-many relationship.
class ManyToManyDefinition extends DataDefinition {
  /// The description of the many-to-many relationship.
  final ManyToManyDescription description;

  /// Creates a new instance of [ManyToManyDefinition].
  ///
  /// The [description] parameter is required and provides the details
  /// of the many-to-many relationship.
  ManyToManyDefinition({
    required this.description,
  });

  /// Generates the SQL statement to create the join table for the
  /// many-to-many relationship.
  ///
  /// The method orders the tables by their names, constructs the join
  /// table name, and defines the columns and foreign keys for the join
  /// table.
  ///
  /// Returns a [String] containing the SQL statement.
  @override
  String define() {
    final membersOrdered = description.membersOrderedByTableName();
    final table1 = membersOrdered[0];
    final table2 = membersOrdered[1];
    final tableName1 = table1.tableDescription.tableName;
    final tableName2 = table2.tableDescription.tableName;
    final connectionName = "${tableName1}_$tableName2";

    final primaryKeyType1 = table1.primaryKeyType();

    final primaryKeyType2 = table2.primaryKeyType();

    final res =
        "CREATE TABLE IF NOT EXISTS $connectionName (id SERIAL PRIMARY KEY, $tableName1 ${primaryKeyType1.sqlTypeName()} NOT NULL, $tableName2 ${primaryKeyType2.sqlTypeName()} NOT NULL, FOREIGN KEY ($tableName1) REFERENCES $tableName1(id) ON DELETE CASCADE, FOREIGN KEY ($tableName2) REFERENCES $tableName2(id) ON DELETE CASCADE, UNIQUE($tableName1, $tableName2))";
    myLogger.d(res, header: "ManyToManyDefinition --> define()");
    return res;
  }
}
