import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';

class TableDescription {
  final Type objectType;
  final List<Column> columns;
  TableDescription(
      {required this.objectType, required this.columns, required this.entity});

  Entity entity;
  String get tableName => entity.name ?? objectType.toString().toSnakeCase();

  List<ForeignColumn> foreignColumns() =>
      columns.whereType<ForeignColumn>().toList();

  List<ForeignColumn> foreignColumnsByForeignKeyType<T extends ForeignKey>() =>
      foreignColumns()
          .where((element) => element.getForeignKey<T>() != null)
          .toList();

  Column? columnDescription(String columnName) =>
      columns.where((element) => element.sqlName == columnName).firstOrNull;

  InternalColumn primaryKeyColumn() => columns.firstWhere(
        (element) => element.isPrimaryKey && element is InternalColumn,
        orElse: () {
          throw Exception("No primary key found for table $tableName");
        },
      ) as InternalColumn;

  List<ForeignColumn> get foreignKeyColumns =>
      columns.whereType<ForeignColumn>().toList();

  List<Column> columnsByConstraint<T extends SQLConstraint>() => columns
      .where((element) => element.constraints.any((element) => element is T))
      .toList();

  List<ForeignColumn> manyToManyColumns() => foreignKeyColumns
      .where((element) => element.getForeignKey<ManyToMany>() != null)
      .toList();

  List<ForeignColumn> oneToOneColumns() => foreignKeyColumns
      .where((element) => element.getForeignKey<OneToOne>() != null)
      .toList();

  List<ForeignColumn> oneToManyColumns() => foreignKeyColumns
      .where((element) => element.getForeignKey<OneToMany>() != null)
      .toList();

  List<ForeignColumn> manyToOneColumns() => foreignKeyColumns
      .where((element) => element.getForeignKey<ManyToOne>() != null)
      .toList();

  String get internalColumnsSqlNamesWithoutId => columns
      .where(
        (element) => element is InternalColumn && !element.isPrimaryKey,
      )
      .map(
        (e) => e.sqlName,
      )
      .join(", ");
  @override
  String toString() {
    return 'TableDescription{objectType: $objectType, tableName: $tableName, columns: ${columns.map((e) => e.toString()).toList()}';
  }
}
