import 'package:dart_store/where/statement.dart';

List<Where> filterWheres(
    {required List<Where> wheres,
    Type? externalColumnType,
    String? columnName}) {
  if (externalColumnType == null || columnName == null) {
    return wheres.where((element) => element.foreignField == null).toList();
  }

  return wheres
      .where(
        (element) =>
            element.foreignField == externalColumnType &&
            element.internalColumn.originalName == columnName,
      )
      .toList();
}
