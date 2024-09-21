import 'dart:mirrors';

import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/column/service.dart';
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

    final Iterable<ForeignColumnInstance> foreignColumnsInstances =
        columns.whereType<ForeignColumn>().map((final ForeignColumn e) {
      final foreignColumnEntityInstance = e.mapId
          ? EntityInstanceService().byMappedIdField(
              fieldName: e.name, holderInstanceMirror: instanceMirror)
          : EntityInstanceService().entityInstanceByValueInstance(
              instanceMirror.getField(Symbol(e.name)));

      return ForeignColumnInstanceService().generateForeignColumnInstances(
          mapId: e.mapId,
          value: foreignColumnEntityInstance,
          foreignKey: e.foreignKey,
          constraints: e.constraints,
          name: e.name);
    });

    return <ColumnInstance>[
      ...internalColumnsInstances,
      ...foreignColumnsInstances
    ];
  }
}
