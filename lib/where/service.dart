import 'package:dart_store/where/statement.dart';

class WhereService {
  String defineAndChainWhereStatements({required List<Where> where}) {
    final orWheres = where.whereType<OrWhere>();
    final andWheres = where.where(
      (element) => element is! OrWhere,
    );
    final res = where.isNotEmpty
        ? "WHERE ${andWheres.map((e) => e.define()).join(' AND ')} ${orWheres.isNotEmpty ? 'OR ${orWheres.map((e) => e.define()).join(' OR ')}' : ''}"
        : "";

    print(res);
    return res;
  }

  List<Where> extractInternalWheres(List<Where> where) => where
      .where(
        (e) => e.foreignField == null,
      )
      .toList();

  List<Where> extractStatementsFor(
          {required List<Where> where, required Type type}) =>
      where
          .where(
            (e) => e.foreignField == Type,
          )
          .toList();
}
