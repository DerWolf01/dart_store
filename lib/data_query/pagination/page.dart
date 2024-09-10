import 'package:dart_store/statement/statement.dart';

class Page extends Statement {
  Page({this.pageNumber = 0, this.pageSize = 10});
  final int pageNumber;
  final int pageSize;

  @override
  String define() {
    return "LIMIT $pageSize OFFSET ${pageNumber * pageSize}";
  }
}
