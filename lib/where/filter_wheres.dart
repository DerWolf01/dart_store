import 'package:dart_store/where/statement.dart';

List<Where> filterWheres(
    {required List<Where> where,
    Type? externalColumnType,
    String? columnName}) {
  if (externalColumnType == null || columnName == null) {
    return where.where((element) => element.foreignField == dynamic).toList();
  }

  return where
      .where(
        (element) =>
            element.foreignField == externalColumnType &&
            element.internalColumn.name == columnName,
      )
      .toList();
}
