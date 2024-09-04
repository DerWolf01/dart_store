import 'package:dart_store/data_definition/constraint/constraint.dart';

abstract class Column {
  List<SQLConstraint> constraints;
  String name;
  String get sqlName;

  hasConstraint<T>() => constraints.any((element) => element is T);
  Constraint? constraint<Constraint extends SQLConstraint>() =>
      constraints.whereType<Constraint>().firstOrNull;
  bool get isPrimaryKey => hasConstraint<PrimaryKey>();
  bool get isUniqe => hasConstraint<Unique>();
  bool get isNullable => !hasConstraint<NotNull>();
  bool get isAutoIncrement => constraint<PrimaryKey>()?.autoIncrement == true;
  bool get isForeignKey => hasConstraint<ForeignKey>();

  ForeignKeyType? getForeignKey<ForeignKeyType>() =>
      constraints.whereType<ForeignKeyType>().firstOrNull;

  Column({
    required this.constraints,
    required this.name,
  });

  @override
  String toString() =>
      "Column(name: $name, constraints: $constraints, sqlName: $sqlName, isPrimaryKey: $isPrimaryKey, isUniqe: $isUniqe, isNullable: $isNullable, isAutoIncrement: $isAutoIncrement, isForeignKey: $isForeignKey)";
}
