import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/foreign.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';

class EntityInstance extends TableDescription {
  EntityInstance(
      {required super.tableName, required List<ColumnInstance> columns})
      : super(columns: columns);

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
  List<ForeignColumnInstance> manyToManyColumns() =>
      super.manyToManyColumns() as List<ForeignColumnInstance>;

  @override
  List<ForeignColumnInstance> manyToOneColumns() =>
      super.manyToManyColumns() as List<ForeignColumnInstance>;
  @override
  List<ForeignColumnInstance> oneToManyColumns() =>
      super.manyToManyColumns() as List<ForeignColumnInstance>;
  @override
  List<ForeignColumnInstance> oneToOneColumns() =>
      super.manyToManyColumns() as List<ForeignColumnInstance>;

  setField(String name, dynamic value) {
    final columnInstance = columns
        .where(
          (element) => element.name == name,
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
