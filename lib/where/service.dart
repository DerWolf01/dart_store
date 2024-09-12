import 'package:dart_store/where/statement.dart';

class WhereService {
  String defineAndChainWhereStatements({required List<Where> where}) =>
      where.isNotEmpty
          ? "WHERE ${where.map((e) => e.define()).join(' AND ')}"
          : "";

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
