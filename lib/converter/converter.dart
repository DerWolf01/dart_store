import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';

import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/foreign.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';

extension EntityMapConverter on ConversionService {
  List<TableConnectionInstance> mapListToTableConnectionInstance(
          {required List<Map<String, dynamic>> maps,
          required TableConnectionDescription tableConnectionDescription}) =>
      maps
          .map((map) => TableConnectionInstance(
              tableName: tableConnectionDescription.tableName,
              columns: tableConnectionDescription.columns
                  .whereType<InternalColumn>()
                  .map(
                    (e) => InternalColumnInstance(
                        value: map[e.sqlName],
                        dataType: e.dataType,
                        constraints: e.constraints,
                        name: e.name),
                  )
                  .toList()))
          .toList();

  TableConnectionInstance mapToTableConnectionInstance(
          {required Map<String, dynamic> map,
          required TableConnectionDescription tableConnectionDescription}) =>
      TableConnectionInstance(
          tableName: tableConnectionDescription.tableName,
          columns: tableConnectionDescription.columns
              .whereType<InternalColumnInstance>()
              .map(
                (e) => InternalColumnInstance(
                    value: map[e.name],
                    dataType: e.dataType,
                    constraints: e.constraints,
                    name: e.name),
              )
              .toList());
  entityInstanceToMap(EntityInstance entityInstance) {
    final internalColumnsInstances =
        entityInstance.columns.whereType<InternalColumnInstance>();
    final internalColumnsInstancesMapEntries = internalColumnsInstances
        .map((e) => MapEntry<String, dynamic>(e.name, e.value));

    final foreignColumnsInstances =
        entityInstance.columns.whereType<ForeignColumnInstance>();
    final foreignColumnsInstancesMapEntries = foreignColumnsInstances.map(
        (e) => MapEntry<String, dynamic>(e.name, entityInstanceToMap(e.value)));

    final instanceMap = {
      ...internalColumnsInstancesMapEntries,
      ...foreignColumnsInstancesMapEntries
    };
    return instanceMap;
  }

  entityInstanceToModel(EntityInstance entityInstance) =>
      ConversionService.mapToObject(entityInstanceToMap(entityInstance));
}

TableConnectionInstance mapToTableConnectionInstance(
        {required Map<String, dynamic> map,
        required TableConnectionDescription tableConnectionDescription}) =>
    ConversionService().mapToTableConnectionInstance(
        map: map, tableConnectionDescription: tableConnectionDescription);

List<TableConnectionInstance> mapListToTableConnectionInstance(
    {required List<Map<String, dynamic>> maps,
    required TableConnectionDescription tableConnectionDescription}) {
  print("[Map<String, dynamic>] $maps");
  return ConversionService().mapListToTableConnectionInstance(
      maps: maps, tableConnectionDescription: tableConnectionDescription);
}

Map<String, dynamic> entityInstanceToMap(EntityInstance entityInstance) {
  final internalColumnsInstances =
      entityInstance.columns.whereType<InternalColumnInstance>();
  final internalColumnsInstancesMapEntries = internalColumnsInstances
      .map((e) => MapEntry<String, dynamic>(e.name, e.value));

  final foreignColumnsInstances = entityInstance.foreignKeyColumns;

  final foreignColumnsInstancesMapEntries =
      foreignColumnsInstances.map((ForeignColumnInstance e) {
    if (e.mapId) {
      if (e.value is List<EntityInstance>) {
        return MapEntry<String, dynamic>(
            e.name,
            e.value
                .map((EntityInstance e) => e.primaryKeyColumn().value)
                .toList());
      }
      return MapEntry<String, dynamic>(
          e.name, e.value.primaryKeyColumn().value);
    }
    if (e.value is List) {
      return MapEntry<String, dynamic>(
          e.name, e.value.map((e) => entityInstanceToMap(e)).toList());
    }
    return MapEntry<String, dynamic>(e.name, entityInstanceToMap(e.value));
  });

  final Map<String, dynamic> instanceMap = {
    ...Map.fromEntries(internalColumnsInstancesMapEntries),
    ...Map.fromEntries(foreignColumnsInstancesMapEntries)
  };

  print("instanceMap $instanceMap");

  return instanceMap;
}

T entityInstanceToModel<T>(EntityInstance entityInstance, {Type? type}) =>
    ConversionService.mapToObject<T>(entityInstanceToMap(entityInstance),
        type: type);
