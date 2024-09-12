import 'package:dart_store/where/statement.dart';

List<Where> filterWheres(
    {required List<Where> where,
    Type? externalColumnType,
    String? columnName,
    bool plain = false}) {
  if (plain) {
    return where
        .where(
          (element) =>
              element.foreignField == dynamic || element.foreignField == null,
        )
        .toList();
  }
  if (externalColumnType == null) {
    return where.where((element) => element.foreignField == dynamic).toList();
  }

  return where
      .where((element) => element.foreignField == externalColumnType)
      .toList();
}
