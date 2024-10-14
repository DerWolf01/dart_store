import 'package:dart_store/my_logger.dart';
import 'package:dart_store/where/statement.dart';

class WhereService {
  String defineAndChainWhereStatements({required List<Where> where}) {
    final orWheres = where.whereType<OrWhere>();
    final andWheres = where.where(
      (element) => element is! OrWhere,
    );

    final or = andWheres.isNotEmpty ? 'OR' : '';
    final res = where.isNotEmpty
        ? "WHERE ${andWheres.map((e) => e.define()).join(' AND ')} ${orWheres.isNotEmpty ? '$or ${orWheres.map((e) => e.define()).join(' OR ')}' : ''}"
        : "";

    myLogger.log(res);
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
