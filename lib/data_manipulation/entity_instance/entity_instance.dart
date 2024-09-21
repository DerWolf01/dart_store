import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/foreign.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/many_to_many.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/many_to_one.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/one_to_many.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/one_to_one.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';

class EntityInstance implements TableDescription {
  @override
  final Type objectType;

  @override
  final Entity entity;
  @override
  List<ColumnInstance> columns;
  EntityInstance(
      {required this.objectType, required this.entity, required this.columns});

  @override
  set entity(Entity entity) {
    // TODO: implement entity
  }
  @override
  List<ForeignColumnInstance> get foreignKeyColumns =>
      columns.whereType<ForeignColumnInstance>().toList();

  @override
  List<ColumnInstance> get getColumns =>
      List.castFrom<dynamic, ColumnInstance>(columns);
  @override
  String get internalColumnsSqlNamesWithoutId => columns
      .where(
        (element) => element is InternalColumnInstance && !element.isPrimaryKey,
      )
      .map(
        (e) => e.sqlName,
      )
      .join(", ");
  @override
  // TODO: implement tableName
  String get tableName => entity.name ?? objectType.toString().toSnakeCase();

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
  ColumnInstance? columnDescription(String columnName) => columns
      .where(
        (element) => element.name == columnName,
      )
      .firstOrNull;

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

  @override
  List<ForeignColumn> manyToManyColumns() => foreignKeyColumns
      .where((element) => element.getForeignKey<ManyToMany>() != null)
      .toList();

  List<ManyToManyColumnInstance> manyToManyColumnsInstances() =>
      columns.whereType<ManyToManyColumnInstance>().toList();

  @override
  List<ForeignColumn> manyToOneColumns() => foreignKeyColumns
      .where((element) => element.getForeignKey<ManyToOne>() != null)
      .toList();

  List<ManyToOneColumnInstance> manyToOneColumnsInstances() =>
      columns.whereType<ManyToOneColumnInstance>().toList();
  @override
  List<ForeignColumn> oneToManyColumns() => foreignKeyColumns
      .where((element) => element.getForeignKey<OneToMany>() != null)
      .toList();

  List<OneToManyColumnInstance> oneToManyColumnsInstances() =>
      columns.whereType<OneToManyColumnInstance>().toList();

  @override
  List<ForeignColumn> oneToOneColumns() => foreignKeyColumns
      .where((element) => element.getForeignKey<OneToOne>() != null)
      .toList();

  List<OneToOneColumnInstance> oneToOneColumnsInstances() =>
      columns.whereType<OneToOneColumnInstance>().toList();

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
  String toString() {
    return 'TableDescription{objectType: $objectType, tableName: $tableName, columns: ${columns.map((e) => e.toString()).toList()}';
  }
}
