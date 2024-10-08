import 'package:dart_store/data_definition/constraint/foreign_key/foreign_key.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class OneToOneDefinitionService with DartStoreUtility {
  Future<void> defineAndExecute(TableDescription tableDescription) async {
    for (final column in tableDescription.oneToOneColumns()) {
      final referencer = column.getForeignKey<OneToOne>()!;
      final referenced = referencer.referencedEntity;
      final OneToOneDescription manyToManyDescription =
          OneToOneDescription(members: [
        OneToOneMemberDefinition(
          tableDescription: TableService().findTable(referenced),
        ),
        OneToOneMemberDefinition(tableDescription: tableDescription)
      ]);
      await TableService().createTable(TableService().findTable(referenced));
      final OneToOneDefinition oneToOneDefinition =
          OneToOneDefinition(description: manyToManyDescription);

      executeSQL(oneToOneDefinition.define());
    }
  }
}
