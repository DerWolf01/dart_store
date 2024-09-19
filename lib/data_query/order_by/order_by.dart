import 'package:change_case/change_case.dart';
import 'package:dart_store/statement/statement.dart';

// TODO implement foreign field functionality yet
class OrderBy extends Statement {
  final String name;
  const OrderBy(this.name);

  @override
  String define() => "ORDER BY ${name.toSnakeCase()}";
}
