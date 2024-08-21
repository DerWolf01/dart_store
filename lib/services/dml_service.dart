import 'dart:math';
import 'dart:mirrors';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/services/constraint_service.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/sql/connection/many_to_many.dart';
import 'package:dart_store/sql/mirrors/primary_key/primary_key_mirror.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class DMLService with DartStoreUtility {
  Future<int> insert(dynamic entity) async {
    final modelMap = ConversionService.objectToMap(entity);
    print("modelMap --> $modelMap");
    final EntityMirror entityMirror =
        EntityMirror.byType(type: entity.runtimeType);
    final List<ColumnMirror> columnMirrors = entityMirror.column;
    print("columnMirrors --> ${columnMirrors.map((e) => e.name)}");
    final Map<String, dynamic> values = {};
    for (final column in columnMirrors) {
      if (column.isForeignKey()) {
        final foreignField = column.getForeignKey();
        if (foreignField is ManyToOne) {
          final connection = ManyToOneConnection(
              entityMirror,
              EntityMirror.byType(
                  type: reflect(foreignField)
                      .type
                      .typeArguments
                      .first
                      .reflectedType));

          values[connection.referencingColumn] = reflect(entity)
              .getField(Symbol(column.name))
              .getField(Symbol("id"))
              .reflectee;
        }
        continue;
      }
      values[column.name] = (column.dataType.convert(modelMap[column.name]));
    }
    String fieldsStatement = "";
    String valuesStatement = "";

    final primaryKeyMirror = entityMirror.primaryKeyMirror;
    if (primaryKeyMirror.dataType is Serial && entity.id == -1) {
      values.remove(primaryKeyMirror.name);
    }
    for (final valueEntry in values.entries) {
      if (fieldsStatement.isEmpty) {
        fieldsStatement += valueEntry.key;
        valuesStatement += valueEntry.value.toString();
        continue;
      }
      fieldsStatement += ", ${valueEntry.key}";

      valuesStatement += ", ${valueEntry.value}";
    }

    final query =
        '''INSERT INTO ${entityMirror.name} ($fieldsStatement) VALUES ($valuesStatement) 
ON CONFLICT (id) DO UPDATE 
SET ${values.entries.map((e) => "${e.key} = ${e.value}").join(', ')}''';
    print("inserting/updating --> $query");
    await executeSQL(query);

    if (primaryKeyMirror.dataType is! Serial) {
      await ForeignKeyService().insertForeignFields(entity);
      return entity.id;
    }

    final entityMap = ConversionService.objectToMap(entity)
      ..["id"] = await lastInsertedId(entityMirror.name);
    entity = ConversionService.mapToObject(entityMap, type: entity.runtimeType);
    await ForeignKeyService().insertForeignFields(entity);
    return entity.id;
  }

  //TODO implement where statement for update method
  Future<int> update<T>(Object entity,
      {WhereCollection? whereCollection}) async {
    return await insert(entity);
  }

  Future<void> delete<T>(String tableName,
      {required WhereCollection where}) async {
    final query = 'DELETE FROM $tableName ${where.chain()}';

    await executeSQL(query);
  }

  Future<int> lastInsertedId(String tableName) async {
    try {
      final query = "SELECT currval('${tableName}_id_seq');";
      final result = await executeSQL(query);
      return result.first.first as int;
    } catch (e) {
      final query = "SELECT NEXTVAL('${tableName}_id_seq');";
      final result = await executeSQL(query);
      return result.first.first as int;
    }
  }
}
