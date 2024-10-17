import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/my_logger.dart';

/// A class that defines a member in a many-to-many relationship.
///
/// This class holds the table description and provides methods to
/// retrieve the table name and primary key type.
class ManyToManyMemberDefinition {
  /// The description of the table involved in the many-to-many relationship.
  final TableDescription tableDescription;

  /// Creates a new instance of [ManyToManyMemberDefinition].
  ///
  /// The [tableDescription] parameter is required and provides the
  /// details of the table involved in the many-to-many relationship.
  ManyToManyMemberDefinition({
    required this.tableDescription,
  });

  /// Returns the name of the table.
  ///
  /// This getter retrieves the table name from the [tableDescription].
  String get tableName => tableDescription.tableName;

  /// Returns the primary key type of the table.
  ///
  /// This method retrieves the data type of the primary key column from
  /// the [tableDescription]. Throws an [Exception] if the primary key
  /// column is missing.
  ///
  /// Returns an [SQLDataType] representing the primary key type.
  SQLDataType primaryKeyType() {
    final key = tableDescription.primaryKeyColumn().dataType;
    myLogger.d("$key",
        header: "ManyToManyMemberDefinition --> primaryKeyType()");
    return key;
  }
}
