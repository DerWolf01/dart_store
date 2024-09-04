import 'package:dart_store/statement/statement.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/service.dart';
import 'package:dart_store/where/statement.dart';

class StatementComposition<T extends Statement>
    with DartStoreUtility
    implements Statement {
  final T statement;
  final List<Where> where;

  StatementComposition({
    required this.statement,
    this.where = const [],
  });

  @override
  String define() {
    final res =
        '${statement.define()} ${WhereService().defineAndChainWhereStatements(where: where)}';

    return res;
  }
}
