import 'dart:mirrors';
import 'package:dart_store/data_definition/table/column/service.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/foreign.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';

class ColumnInstanceService {
  List<ColumnInstance> extractColumnInstances(dynamic value) {
    final InstanceMirror instanceMirror = reflect(value);
    final columns = ColumnService().extractColumns(instanceMirror.type);
    final Iterable<InternalColumnInstance> internalColumnsInstances =
        columns.whereType<InternalColumn>().map(
      (e) {
        print(
            "instanceMirror.value --> ${instanceMirror.getField(Symbol(e.name)).reflectee}");

        print("instanceMirror.name --> ${e.name}");

        return InternalColumnInstance(
            value: instanceMirror.getField(Symbol(e.name)).reflectee,
            dataType: e.dataType,
            constraints: e.constraints,
            name: e.name);
      },
    );
    final Iterable<ForeignColumnInstance> foreignColumnsInstances =
        columns.whereType<ForeignColumn>().map((e) {
      final foreignColumnEntityInstance = EntityInstanceService()
          .entityInstanceByValueInstance(
              instanceMirror.getField(Symbol(e.name)).reflectee);
      print("foreignColumnEntityInstance-extraction: $foreignColumnEntityInstance");
      return ForeignColumnInstanceService().generateForeignColumnInstances(
          value: foreignColumnEntityInstance,
          foreignKey: e.foreignKey,
          constraints: e.constraints,
          name: e.name);
    });
    // print("foreign-column-instances for $value: $foreignColumnsInstances");
    print("Foreign Columns Instances: $foreignColumnsInstances");
    return [...internalColumnsInstances, ...foreignColumnsInstances];
  }
}
