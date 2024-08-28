import 'package:dart_store/sql/sql_anotations/constraints/constraint.dart';

class PrimaryKey extends SQLConstraint {
  final bool? autoIncrement;
  const PrimaryKey({this.autoIncrement = false});
}
