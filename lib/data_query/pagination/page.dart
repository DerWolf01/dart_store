import 'package:dart_store/statement/statement.dart';

class Page<ForeignField> extends Statement {
  final int pageNumber;
  final int pageSize;
  final Type foreignField = ForeignField;

  Page({this.pageNumber = 0, this.pageSize = 10});

  bool get foreignFieldPage => foreignField != dynamic;
  @override
  String define() {
    return "LIMIT $pageSize OFFSET ${pageNumber * pageSize}";
  }
}
