import 'package:dart_store/sql_anotations/constraints/constraint.dart';

class PrimaryKey extends SQLConstraint {
  final bool autoIncrement;
  const PrimaryKey({required this.autoIncrement});
}
