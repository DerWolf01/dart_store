import 'dart:mirrors';

import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';

class EntityInstanceService {
  dynamic byMappedIdField({
    required InstanceMirror holderInstanceMirror,
    required String fieldName,
  }) {
    final declarations =
        ConversionService.declarations(holderInstanceMirror.type).map(
      (key, value) => MapEntry(MirrorSystem.getName(key), value),
    );
    final fieldVariableMirror = declarations[fieldName];
    if (fieldVariableMirror == null || fieldVariableMirror is! VariableMirror) {
      throw Exception(
          "No VariableMirror found for Field $fieldName in ${holderInstanceMirror.type}. Found: $fieldVariableMirror");
    }
    final foreignKey = fieldVariableMirror.metadata
        .where(
          (element) => element.reflectee is ForeignKey,
        )
        .firstOrNull
        ?.reflectee as ForeignKey?;
    if (foreignKey == null) {
      throw Exception(
          "No foreign key found in $fieldVariableMirror anotated with @MapId");
    }
    final Type referencedEntity = foreignKey.referencedEntity;
    final TableDescription tableDescription =
        TableService().findTable(referencedEntity);
    final primaryKeyColumn = tableDescription.primaryKeyColumn();
    final id = holderInstanceMirror.getField(Symbol(fieldName)).reflectee;
    if (!checkId(primaryKeyColumn.dataType, id)) {
      throw Exception(
          "Id $id of type ${id.runtimeType} is not compatible with sql type ${primaryKeyColumn.dataType}");
    }
    if (id is List) {
      return id
          .map(
            (e) => EntityInstance(
                objectType: referencedEntity,
                entity: tableDescription.entity,
                columns: <ColumnInstance>[
                  InternalColumnInstance.fromColumn(
                      column: primaryKeyColumn,
                      value: e,
                      dataType: primaryKeyColumn.dataType)
                ]),
          )
          .toList();
    }
    return EntityInstance(
        objectType: referencedEntity,
        entity: tableDescription.entity,
        columns: [
          InternalColumnInstance.fromColumn(
              column: primaryKeyColumn,
              value: id,
              dataType: primaryKeyColumn.dataType)
        ]);
  }

  bool checkId(SQLDataType idDataType, dynamic id) =>
      idDataType.compareToValue(id);

  dynamic entityInstanceByValueInstance(
    InstanceMirror instanceMirror,
  ) {
    final value = instanceMirror.reflectee;

    if (value is List) {
      return value
          .map((e) {
            entityInstanceByValueInstance(reflect(e));
          })
          .whereType<EntityInstance>()
          .toList();
    }
    final List<ColumnInstance> columnsInstances =
        ColumnInstanceService().extractColumnInstances(instanceMirror);
    final table = TableService().findTable(value.runtimeType);
    return EntityInstance(
        entity: table.entity,
        objectType: value.runtimeType,
        columns: columnsInstances);
  }
}
