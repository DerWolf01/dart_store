import 'package:dart_store/dart_store.dart';
import 'package:dart_store/services/constraint_service.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/services/dml_service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:change_case/change_case.dart';

class DqlService extends DartStoreUtility {
  Future<List<T>> query<T>({WhereCollection? where, Type? type}) async {
    try {
      final entityMirror = EntityMirror<T>.byType(type: type ?? T);
      final List<T> queryResult = [];

      for (final row in (await executeSQL(
          generateQueryString<T>(where: where, type: type)))) {
        print("row: $row");
        print(
            "row.toColumnMap(): ${row.toColumnMap().entries.map((entry) => "${entry.key}: ${entry.value} ${entry.value.runtimeType}").join(", ")}");

        final modelMap = row.toColumnMap();

        for (final foreignKey in entityMirror.column.where(
          (e) => e.dataType is ForeignField,
        )) {
          print(
              "setting ${foreignKey.name} by querying through: ${modelMap["id"]}");
          modelMap[foreignKey.name] = await ForeignKeyService()
              .query<T>(modelMap["id"], type: type ?? T);

          print("${foreignKey.name} --> ${modelMap[foreignKey.name]}");
        }
        try {
          print("modelMap: $modelMap");

          queryResult.add(ConversionService.mapToObject<T>(
              modelMap.map(
                (key, value) => MapEntry(key.toCamelCase(), value),
              ),
              type: type));
        } catch (e, s) {
          print("Error: $e StackTrace: $s");
        }
      }
      return queryResult;
    } catch (e, s) {
      print("Error: $e StackTrace: $s");
      return [];
    }
  }

  String generateQueryString<T>({WhereCollection? where, Type? type}) {
    final entityMirror = EntityMirror<T>.byType(type: type);
    final columnNames = entityMirror.column
        .where(
          (element) => element.dataType is! ForeignField,
        )
        .map((e) => e.name.toSnakeCase())
        .join(", ");
    print("columnNames: $columnNames");
    final tableName = entityMirror.name;
    final queryString =
        "SELECT $columnNames FROM $tableName ${where?.chain() ?? ""}";
    print(queryString);
    return queryString;
  }
}
