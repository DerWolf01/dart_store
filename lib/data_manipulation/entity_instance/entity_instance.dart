import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/foreign.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/many_to_many.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/many_to_one.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/one_to_many.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/one_to_one.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';

class EntityInstance extends TableDescription {
  EntityInstance(
      {required super.objectType,
      required super.entity,
      required List<ColumnInstance> columns})
      : super(columns: columns);

  Column columnByName(String name) =>
      columns.firstWhere((element) => element.name == name);

  T columnByNameAndType<T extends Column>(String name) => columns
      .whereType<T>()
      .firstWhere(
        (element) => element.name == name,
        orElse: () =>
            throw Exception("Column with name: $name and Type $T not found."),
      );
  @override
  List<ColumnInstance> get columns => super.columns as List<ColumnInstance>;
  @override
  List<ForeignColumnInstance> get foreignKeyColumns =>
      columns.whereType<ForeignColumnInstance>().toList();

  @override
  List<ColumnInstance> columnsByConstraint<T extends SQLConstraint>() => columns
      .where(
        (element) => element.constraints.any(
          (element) => element is T,
        ),
      )
      .toList();
  @override
  List<ForeignColumnInstance> foreignColumns() =>
      columns.whereType<ForeignColumnInstance>().toList();
  @override
  List<ForeignColumnInstance>
      foreignColumnsByForeignKeyType<T extends ForeignKey>() => foreignColumns()
          .where((element) => element.getForeignKey<T>() != null)
          .toList();

  List<ManyToManyColumnInstance> manyToManyColumnsInstances() =>
      columns.whereType<ManyToManyColumnInstance>().toList();

  List<ManyToOneColumnInstance> manyToOneColumnsInstances() =>
      columns.whereType<ManyToOneColumnInstance>().toList();

  List<OneToManyColumnInstance> oneToManyColumnsInstances() =>
      columns.whereType<OneToManyColumnInstance>().toList();

  List<OneToOneColumnInstance> oneToOneColumnsInstances() =>
      columns.whereType<OneToOneColumnInstance>().toList();

  setField(String name, dynamic value) {
    final columnInstance = columns
        .where(
          (element) => element.name == name,
        )
        .firstOrNull;

    if (columnInstance == null) {
      throw Exception("No column with name:$name exists in table $tableName");
    }

    columnInstance.value = value;
  }

  @override
  InternalColumnInstance primaryKeyColumn() {
    final column = columns
        .whereType<InternalColumnInstance>()
        .where(
          (element) => element.isPrimaryKey,
        )
        .firstOrNull;
    if (column == null) {
      throw Exception("No primary key found for table $tableName");
    }
    return column;
  }

  @override
  ColumnInstance? columnDescription(String columnName) => columns
      .where(
        (element) => element.name == columnName,
      )
      .firstOrNull;
}
