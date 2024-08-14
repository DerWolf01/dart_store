import 'package:dart_store/dart_store.dart';
import 'package:dart_store/services/constraint_service.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class DqlService extends DartStoreUtility {
  Future<List<T>> query<T>({WhereCollection? where}) async {
    try {
      final _entityDecl = entityDecl<T>();
      final List<T> queryResult = [];

      for (final row
          in (await executeSQL(generateQueryString<T>(where: where)))) {
        final modelMap = row.toColumnMap();

        for (final foreignKey in _entityDecl.column.where(
          (e) => e.dataType is ForeignField,
        )) {
          modelMap[foreignKey.name] =
              await ForeignKeyService().query<T>(modelMap["id"]);
        }
        try {
          queryResult.add(ConversionService.mapToObject<T>(modelMap));
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

  String generateQueryString<T>({WhereCollection? where}) {
    final _entityDecl = entityDecl<T>();
    final columnNames = _entityDecl.column
        .where(
          (element) => element.dataType is! ForeignField,
        )
        .map((e) => e.name)
        .join(", ");
    print("columnNames: $columnNames");
    final tableName = _entityDecl.name;
    final queryString =
        "SELECT $columnNames FROM $tableName ${where?.chain() ?? ""}";
    print(queryString);
    return queryString;
  }
}
