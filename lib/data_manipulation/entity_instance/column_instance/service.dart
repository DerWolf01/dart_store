import 'dart:mirrors';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/data_definition/table/column/service.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/foreign.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';

class ColumnInstanceService {
  List<ColumnInstance> extractColumnInstances(InstanceMirror instanceMirror) {
    final columns = ColumnService().extractColumns(instanceMirror.type);

    final Iterable<InternalColumnInstance> internalColumnsInstances = columns
        .whereType<InternalColumn>()
        .map((e) => InternalColumnInstance(
            value: instanceMirror.getField(Symbol(e.name)).reflectee,
            dataType: e.dataType,
            constraints: e.constraints,
            name: e.name));

    print("foreignColumns --> ${columns.whereType<ForeignColumn>()}");
    final Iterable<ForeignColumnInstance> foreignColumnsInstances =
        columns.whereType<ForeignColumn>().map((final ForeignColumn e) {
      print(
          "Next foreign field to extract --> $e.name --> ${instanceMirror.getField(Symbol(e.name)).type.metadata}");
      final foreignColumnEntityInstance = e.mapId
          ? EntityInstanceService().byMappedIdField(
              fieldName: e.name, holderInstanceMirror: instanceMirror)
          : EntityInstanceService().entityInstanceByValueInstance(
              instanceMirror.getField(Symbol(e.name)));
      print(
          "foreignColumnEntityInstance-extraction: $foreignColumnEntityInstance");
      return ForeignColumnInstanceService().generateForeignColumnInstances(
          mapId: e.mapId,
          value: foreignColumnEntityInstance,
          foreignKey: e.foreignKey,
          constraints: e.constraints,
          name: e.name);
    });
    // print("foreign-column-instances for $value: $foreignColumnsInstances");
    print(
        "Foreign Columns Instances for ${instanceMirror.type.simpleName}: $foreignColumnsInstances");
    return [...internalColumnsInstances, ...foreignColumnsInstances];
  }
}
