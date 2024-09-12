import 'package:dart_store/where/statement.dart';

class WhereService {
  defineAndChainWhereStatements({required List<Where> where}) {
    if (where.isEmpty) {
      return "";
    }

    String orWheres = where
        .whereType<OrWhere>()
        .map(
          (e) => e.define(),
        )
        .join(" OR ");
    ;

    final andWheres = where
        .where(
          (element) => element is! OrWhere,
        )
        .map(
          (e) => e.define(),
        )
        .join(" AND ");

    if (andWheres.isNotEmpty && orWheres.isNotEmpty) {
      orWheres = " OR $orWheres";
    }
    return "WHERE $andWheres $orWheres";
  }

  List<Where> extractStatementsFor(
          {required List<Where> where, required Type type}) =>
      where
          .where(
            (e) => e.foreignField == Type,
          )
          .toList();

  List<Where> extractInternalWheres(List<Where> where) => where
      .where(
        (e) => e.foreignField == null,
      )
      .toList();
}
