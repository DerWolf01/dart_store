import 'package:dart_store/data_definition/constraint/constraint.dart';

class PrimaryKey extends SQLConstraint {
  final bool? autoIncrement;
  const PrimaryKey({this.autoIncrement = false});
}
