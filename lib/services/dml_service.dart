import 'package:dart_store/services/converter_service.dart';
import 'package:dart_store/sql_anotations/declarations/entity_decl.dart';
import 'package:dart_store/sql_anotations/declarations/primary_key_decl.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

class DMLService with DartStoreUtility {
  Future<Result> insert(Object entity) async {
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
        valuesStatement += valueEntry.value;
        continue;
      }
      fieldsStatement += ", ${valueEntry.key}";
      print(valueEntry.value);
      valuesStatement += ", ${valueEntry.value}";
    }

    final query =
        'INSERT INTO ${_entityDecl.name} ($fieldsStatement) VALUES ($valuesStatement)';
    print(query);
    return await executeSQL(query);
  }

  Future<void> update<T>(T entity) async {}

  Future<void> delete<T>(T entity) async {}
}
