import 'package:dart_store/data_query/order_by/order_by.dart';
import 'package:dart_store/data_query/pagination/page.dart';
import 'package:dart_store/statement/statement.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/service.dart';
import 'package:dart_store/where/statement.dart';

class StatementComposition<T extends Statement>
    with DartStoreUtility
    implements Statement {
  final T statement;
  final List<Where> where;
  final Page? page;
  final OrderBy? orderBy;

  StatementComposition(
      {required this.statement,
      this.where = const [],
      this.page,
      this.orderBy});

  @override
  String define() {
    final res =
        '${statement.define()} ${WhereService().defineAndChainWhereStatements(where: where)} ${page?.define() ?? ""} ${orderBy?.define()}';

    return res;
  }
}
