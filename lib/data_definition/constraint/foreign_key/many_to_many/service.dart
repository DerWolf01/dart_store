import 'package:dart_store/data_definition/constraint/foreign_key/foreign_key.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

/// A service class for defining and executing many-to-many relationships.
///
/// This class provides a method to define and execute the SQL statements
/// necessary to create the join tables for many-to-many relationships.
class ManyToManyDefinitionService with DartStoreUtility {
  /// Defines and executes the SQL statements for many-to-many relationships.
  ///
  /// This method iterates over the many-to-many columns of the given
  /// [tableDescription], constructs the necessary many-to-many definitions,
  /// and executes the corresponding SQL statements.
  ///
  /// The [tableDescription] parameter provides the details of the table
  /// for which the many-to-many relationships are being defined.
  Future<void> defineAndExecute(TableDescription tableDescription) async {
    for (final column in tableDescription.manyToManyColumns()) {
      final referencer = column.getForeignKey<ManyToMany>()!;
      final referenced = referencer.referencedEntity;

      await TableService().createTable(TableService().findTable(referenced));

      final ManyToManyDescription manyToManyDescription =
          ManyToManyDescription(members: [
        ManyToManyMemberDefinition(
          tableDescription: TableService().findTable(referenced),
        ),
        ManyToManyMemberDefinition(tableDescription: tableDescription)
      ]);
      final ManyToManyDefinition manyToManyDefinition =
          ManyToManyDefinition(description: manyToManyDescription);

      executeSQL(manyToManyDefinition.define());
    }
  }
}
