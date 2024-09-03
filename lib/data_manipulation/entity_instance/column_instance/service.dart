import 'dart:mirrors';
import 'package:dart_store/data_definition/table/column/service.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';

class ColumnInstanceService {
  extractColumnInstances(dynamic value) {
    final InstanceMirror instanceMirror = reflect(value);

    final columns = ColumnService().extractColumns(instanceMirror.type);
    final internalColumnsInstances = columns.whereType<InternalColumn>().map(
          (e) => InternalColumnInstance(
              value: instanceMirror.getField(Symbol(e.name)),
              dataType: e.dataType,
              constraints: e.constraints,
              name: e.name),
        );
    final foreignColumnsInstances = columns.whereType<ForeignColumn>().map(
          (e) => ForeignColumnInstanceService().generateForeignColumnInstances(
              value: instanceMirror.getField(Symbol(e.name)),
              foreignKey: e.foreignKey,
              constraints: e.constraints,
              name: e.name),
        );

    return [...internalColumnsInstances, ...foreignColumnsInstances];
  }
}
