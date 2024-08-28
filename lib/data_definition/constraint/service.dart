import 'package:dart_store/data_definition/constraint/foreign_key/many_to_many/service.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/many_to_one/service.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/one_to_many/service.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/one_to_one/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class ConstraintService with DartStoreUtility {
  Future<void> postTableDefinitionAndExecution(
      TableDescription tableDescription) async {
    await ManyToManyDefinitionService().defineAndExecute(tableDescription);
    await OneToOneDefinitionService().defineAndExecute(tableDescription);
    await ManyToOneDefinitionService().defineAndExecute(tableDescription);
    await OneToManyDefinitionService().defineAndExecute(tableDescription);
    return;
  }
}
