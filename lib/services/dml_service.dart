import 'package:dart_store/services/converter_service.dart';
import 'package:dart_store/sql/clauses/where.dart';
import 'package:dart_store/sql/declarations/entity_decl.dart';
import 'package:dart_store/sql/declarations/primary_key_decl.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class DMLService with DartStoreUtility {
  Future<int> insert(Object entity) async {
    final modelMap = ConverterService.objectToMap(entity);

    final EntityDecl _entityDecl = entityDecl(type: entity.runtimeType);
    final columnDecls = _entityDecl.column;

    final Map<String, dynamic> values = {};
    for (final column in columnDecls) {
      print(modelMap[column.name]);
      values[column.name] = (column.dataType.convert(modelMap[column.name]));
    }
    String fieldsStatement = "";
    String valuesStatement = "";

    final _primaryKeyDecl = primaryKeyDecl(type: entity.runtimeType);
    if (_primaryKeyDecl.primaryKey.autoIncrement == true) {
      values.remove(_primaryKeyDecl.name);
    }
    for (final valueEntry in values.entries) {
      if (fieldsStatement.isEmpty) {
        fieldsStatement += valueEntry.key;
        valuesStatement += valueEntry.value.toString();
        continue;
      }
      fieldsStatement += ", ${valueEntry.key}";
      print(valueEntry.value);
      valuesStatement += ", ${valueEntry.value}";
    }

    final query =
        'INSERT INTO ${_entityDecl.name} ($fieldsStatement) VALUES ($valuesStatement)';

    await executeSQL(query);
    return await _lastInsertedId(_entityDecl.name);
  }

  Future<void> update<T>(Object entity) async {}

  Future<void> delete<T>(String tableName,
      {required WhereCollection where}) async {
    final query = 'DELETE FROM $tableName ${where.chain()}';
    print(query);
    await executeSQL(query);
  }

  Future<int> _lastInsertedId(String tableName) async {
    final query = "SELECT currval('${tableName}_id_seq');";
    final result = await executeSQL(query);
    return result.first.first as int;
  }
}
