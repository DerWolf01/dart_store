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
      required super.tableName,
      required List<ColumnInstance> columns})
      : super(columns: columns);

  Column columnByName(String name) =>
      columns.firstWhere((element) => element.name == name);

  T columnByNameAndType<T extends Column>(String name) =>
      columns.whereType<T>().firstWhere((element) => element.name == name);
  @override
  List<ColumnInstance> get columns => super.columns as List<ColumnInstance>;

  @override
  List<ColumnInstance> columnsByConstraint<T extends SQLConstraint>() =>
      super.columnsByConstraint() as List<ColumnInstance>;
  @override
  List<ForeignColumnInstance> foreignColumns() =>
      super.foreignColumns() as List<ForeignColumnInstance>;
  @override
  List<ForeignColumnInstance>
      foreignColumnsByForeignKeyType<T extends ForeignKey>() =>
          super.foreignColumnsByForeignKeyType() as List<ForeignColumnInstance>;

  @override
  List<ManyToManyColumnInstance> manyToManyColumns() =>
      super.manyToManyColumns() as List<ManyToManyColumnInstance>;

  @override
  List<ManyToOneColumnInstance> manyToOneColumns() =>
      super.manyToManyColumns() as List<ManyToOneColumnInstance>;
  @override
  List<OneToManyColumnInstance> oneToManyColumns() =>
      super.manyToManyColumns() as List<OneToManyColumnInstance>;
  @override
  List<OneToOneColumnInstance> oneToOneColumns() =>
      super.manyToManyColumns() as List<OneToOneColumnInstance>;

  setField(String name, dynamic value) {
    final columnInstance = columns
        .where(
          (element) => element.sqlName == name,
        )
        .firstOrNull;

    if (columnInstance == null) {
      throw Exception("Now column with name:$name exists in table $tableName");
    }
    columnInstance.value = value;
  }

  @override
  InternalColumnInstance primaryKeyColumn() {
    return super.primaryKeyColumn() as InternalColumnInstance;
  }
}
