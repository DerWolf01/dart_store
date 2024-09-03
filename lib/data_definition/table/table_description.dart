import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';

class TableDescription {
  final Type objectType;
  final String tableName;
  final List<Column> columns;
  TableDescription(
      {required this.objectType,
      required this.tableName,
      required this.columns});

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

  List<Column> get foreignKeyColumns =>
      columns.whereType<ForeignColumn>().toList();

  List<Column> columnsByConstraint<T extends SQLConstraint>() => columns
      .where((element) => element.constraints.any((element) => element is T))
      .toList();

  List<Column> manyToManyColumns() => foreignKeyColumns
      .where((element) => element.getForeignKey<ManyToMany>() != null)
      .toList();

  List<Column> oneToOneColumns() => foreignKeyColumns
      .where((element) => element.getForeignKey<OneToOne>() != null)
      .toList();

  List<Column> oneToManyColumns() => foreignKeyColumns
      .where((element) => element.getForeignKey<OneToMany>() != null)
      .toList();

  List<Column> manyToOneColumns() => foreignKeyColumns
      .where((element) => element.getForeignKey<ManyToOne>() != null)
      .toList();
}
