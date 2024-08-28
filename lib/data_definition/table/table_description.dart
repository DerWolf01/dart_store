import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/column/foreign_column.dart';
import 'package:dart_store/data_definition/table/column/internal_column.dart';

class TableDescription {
  final String tableName;
  final List<Column> columns;
  TableDescription({required this.tableName, required this.columns});

  Column? columnDescription(String columnName) =>
      columns.where((element) => element.name == columnName).firstOrNull;

  InternalColumn primaryKeyColumn() => columns.firstWhere(
        (element) => element.isPrimaryKey && element is InternalColumn,
        orElse: () {
          throw Exception("No primary key found for table $tableName");
        },
      ) as InternalColumn;

  List<Column> get foreignKeyColumns =>
      columns.whereType<ForeignColumn>().toList();

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
