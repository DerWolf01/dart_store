import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

class DataDefinitonService with DartStoreUtility {
  Future<void> defineData() async {
    final tableService = TableService();
    List<TableDescription> tables = tableService.findTables();
    for (final table in tables) {
      await tableService.createTable(table);
    }
    return;
  }
}

// TODO
// Add constraintts, columns <Datatype, FieldName> to EntityMirror

extension PostgreSQLUpdatedAtTrigger on DataDefinitonService {
  /// enables trigger and extension for updated_at column
  /// catches exception if trigger already exists and ignores it
  /// reason for that being that "IF NOT EXISTS" is not supported for triggers
  Future enableUpdatedAtTrigger(String tableName, String triggerName) async {
    try {
      await executeSQL("CREATE EXTENSION IF NOT EXISTS moddatetime;");
      await executeSQL(
          "CREATE TRIGGER update_timestamp BEFORE UPDATE ON $tableName FOR EACH ROW EXECUTE PROCEDURE moddatetime($triggerName);");
    } catch (e) {
      if (e is ServerException &&
          e.message.contains(
              'trigger "update_timestamp" for relation "$tableName" already exists')) {
        return;
      }
      throw Exception("Error enabling updatedAt trigger: $e");
    }
    return;
  }
}
