import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/many_to_one/definition.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/many_to_one/description.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/many_to_one/member/referenced.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/many_to_one/member/referencing.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class ManyToOneDefinitionService with DartStoreUtility {
  Future<void> defineAndExecute(TableDescription tableDescription) async {
    for (final column in tableDescription.manyToOneColumns()) {
      final referenced = TableService()
          .findTable(column.getForeignKey<ManyToOne>()!.referencedEntity);

      final ManyToOneDescription manyToOneDescription = ManyToOneDescription(
          referencingMember: ManyToOneReferencingMemberDefinition(
              tableDescription: tableDescription, column: column),
          referencedMember: ManyToOneReferencedMemberDefinition(
              tableDescription: referenced));
      final ManyToOneDefinition manyToOneDefinition =
          ManyToOneDefinition(description: manyToOneDescription);
      await executeSQL(manyToOneDefinition.define());
    }
  }
}
