import 'package:dart_store/data_definition/constraint/foreign_key/foreign_key.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class OneToManyDefinitionService extends DartStoreUtility {
  Future<void> defineAndExecute(TableDescription tableDescription) async {
    for (final column in tableDescription.oneToManyColumns()) {
      final referenced = TableService()
          .findTable(column.getForeignKey<OneToMany>()!.referencedEntity);

      final OneToManyDescription oneToManyDescription = OneToManyDescription(
          referencingMember: OneToManyReferencingMemberDefinition(
            tableDescription: tableDescription,
          ),
          referencedMember: OneToManyReferencedMemberDefinition(
              tableDescription: referenced));
      final OneToManyDefinition oneToManyDefinition =
          OneToManyDefinition(description: oneToManyDescription);
      await executeSQL(oneToManyDefinition.define());
    }
  }
}
