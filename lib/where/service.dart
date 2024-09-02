import 'package:dart_store/where/statement.dart';

class WhereService {
  defineAndChainWhereStatements({required List<Where> wheres}) =>
      wheres.map((e) => e.define()).join(' AND ');

  List<Where> extractStatementsFor(
          {required List<Where> wheres, required Type type}) =>
      wheres
          .where(
            (e) => e.foreignField == Type,
          )
          .toList();

  List<Where> extractInternalWheres(List<Where> wheres) => wheres
      .where(
        (e) => e.foreignField == null,
      )
      .toList();
}
