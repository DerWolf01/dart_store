import 'package:dart_store/where/statement.dart';

List<Where> filterWheres(
    {required List<Where> where,
    Type? externalColumnType,
    String? columnName}) {
  if (externalColumnType == dynamic || externalColumnType == null) {
    return where.where((element) => element.foreignField == null || element.foreignField == dynamic).toList();
  }

  return where
      .where(
        (element) => element.foreignField == externalColumnType,
      )
      .toList();
}
