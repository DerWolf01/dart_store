import 'package:dart_store/data_query/pagination/page.dart';
import 'package:dart_store/where/statement.dart';

List<Where> filterWheres(
    {required List<Where> where,
    Type? externalColumnType,
    String? columnName}) {
  if (externalColumnType == dynamic || externalColumnType == null) {
    return where
        .where((element) =>
            element.foreignField == null || element.foreignField == dynamic)
        .toList();
  }

  return where
      .where(
        (element) => element.foreignField == externalColumnType,
      )
      .toList();
}

class StatementFilter {
  static filterPages({required List<Page> pages, Type? externalColumnTyp}) {
    if (externalColumnTyp == dynamic || externalColumnTyp == null) {
      return pages.where((element) => !element.foreignFieldPage).toList();
    }
    return pages
        .where((element) => element.foreignField == externalColumnTyp)
        .toList();
  }
}
