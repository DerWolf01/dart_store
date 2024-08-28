import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/many_to_many/definition.dart';
import 'package:dart_store/data_definition/constraint/many_to_many/description.dart';
import 'package:dart_store/data_definition/constraint/many_to_many/member.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class ManyToManyDefinitionService with DartStoreUtility {
  Future<void> defineAndExecute(TableDescription tableDescription) async {
    for (final column in tableDescription.manyToManyColumns()) {
      final referencer = column.getForeignKey<ManyToMany>()!;
      final referenced = referencer.referencedEntity;
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
