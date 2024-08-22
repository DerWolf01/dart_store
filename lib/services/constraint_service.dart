import 'dart:async';
import 'dart:math';
import 'dart:mirrors';
import 'package:dart_store/dart_store.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/services/dml_service.dart';
import 'package:dart_store/sql/connection/many_to_many/many_to_many.dart';
import 'package:dart_store/sql/connection/many_to_many/many_to_many_instance.dart';
import 'package:dart_store/sql/connection/many_to_one.dart';
import 'package:dart_store/sql/connection/one_to_many.dart';
import 'package:dart_store/sql/connection/one_to_one/one_to_one.dart';
import 'package:dart_store/sql/connection/one_to_one/one_to_one_instance.dart';
import 'package:dart_store/sql/mirrors/entity/entity_instance_mirror.dart';
import 'package:dart_store/sql/mirrors/entity/entity_mirror_with_id.dart';

import 'package:postgres/postgres.dart' as pg;

class ConstraintService {
  List<String> getConstraints(EntityMirror entityMirror) {
    final List<String> constraintStatements = [];

    for (final column in entityMirror.column) {
      final constraints = column.constraints;
      constraints.removeWhere(
        (element) => element is PrimaryKey,
      );
      for (final constraint in constraints) {
        final constraintStatement =
            _generateConstraintStatement(entityMirror, column, constraint);

        if (constraintStatement == null) continue;
        constraintStatements.addAll(constraintStatement);
      }
    }

    return constraintStatements;
  }

  _generateConstraintStatement(EntityMirror entityMirror,
      ColumnMirror columnMirror, SQLConstraint constraint) {
    if (constraint is NotNull) {
      return 'ALTER TABLE ${entityMirror.name} ALTER COLUMN ${columnMirror.name} SET NOT NULL';
    } else if (constraint is OneToMany) {
      final pointsTo = reflect(constraint).type.typeArguments.firstOrNull;
      if (pointsTo == null) {
        throw Exception(
            "${constraint.runtimeType} of ${entityMirror.name}.${columnMirror.name} is not referring to any other entity and must have a type argument");
      }

      return OneToManyConnection(
        entityMirror,
        EntityMirror.byType(type: pointsTo.reflectedType),
      ).connectionStatements;
    } else if (constraint is OneToOne) {
      final pointsTo = reflect(constraint).type.typeArguments.firstOrNull;
      if (pointsTo == null) {
        throw Exception(
            "${constraint.runtimeType} of ${entityMirror.name}.${columnMirror.name} is not referring to any other entity and must have a type argument");
      }
      return OneToOneConnection(
        EntityMirror.byType(type: pointsTo.reflectedType),
        entityMirror,
      ).connectionStatements;
    } else if (constraint is ManyToMany) {
      final pointsTo = reflect(constraint).type.typeArguments.firstOrNull;
      if (pointsTo == null) {
        throw Exception(
            "${constraint.runtimeType} of ${entityMirror.name}.${columnMirror.name} is not referring to any other entity and must have a type argument");
      }
      return ManyToManyConnection(
        EntityMirror.byType(type: pointsTo.reflectedType),
        entityMirror,
      ).connectionStatements;
    } else if (constraint is ManyToOne) {
      final pointsTo = reflect(constraint).type.typeArguments.firstOrNull;
      if (pointsTo == null) {
        throw Exception(
            "${constraint.runtimeType} of ${entityMirror.name}.${columnMirror.name} is not referring to any other entity and must have a type argument");
      }
      return ManyToOneConnection(
        entityMirror,
        EntityMirror.byType(type: pointsTo.reflectedType),
      ).connectionStatements;
    }
  }

  Future<void> setCoinstraints(EntityMirror entityMirror) async {
    final constraints = getConstraints(entityMirror);
    print("Constraints: $constraints");
    for (final constraint in constraints) {
      print("Executing $constraint");
      await dartStore.execute(constraint);
    }

    return;
  }
}

class ForeignKeyService extends DMLService {
  Future<dynamic> insertForeignFields(dynamic entity) async {
    final entityInstanceMirror = EntityInstanceMirror(
      instanceMirror: reflect(entity),
    );

    final foreignKeyColumns =
        entityInstanceMirror.column.where((element) => element.isForeignKey());
    for (final foreignKeyColumn in foreignKeyColumns) {
      final foreignKey = foreignKeyColumn.getForeignKey();
      if (foreignKey is OneToOne) {
        return await insertOneToOne(
            entityInstanceMirror: entityInstanceMirror,
            foreignKey: foreignKey,
            foreignKeyColumn: foreignKeyColumn);
      } else if (foreignKey is ManyToMany) {
        return await insertManyToMany(
            entityInstanceMirror: entityInstanceMirror,
            foreignKey: foreignKey,
            foreignKeyColumn: foreignKeyColumn);
      } else if (foreignKey is OneToMany) {
        return await insertOneToMany(
            entityInstanceMirror: entityInstanceMirror,
            foreignKey: foreignKey,
            foreignKeyColumn: foreignKeyColumn);
      }
    }
    return null;
  }

  Future<dynamic> query<T>(dynamic id, {Type? type}) async {
    final entityMirror = EntityMirror<T>.byType(type: type);
    final EntityMirrorWithId entityMirrorWithId =
        EntityMirrorWithId<T>.byClassMirror(
            id: id, classMirror: entityMirror.classMirror);
    late dynamic queryResult;
    final foreignFields = entityMirror.column.where(
      (element) => element.dataType is ForeignField,
    );

    for (final foreignField in foreignFields) {
      final foreignKey = foreignField.getForeignKey();
      if (foreignKey is ManyToOne) {
        final connection = ManyToOneConnection(entityMirror,
            EntityMirror.byType(type: foreignKey.referencedEntity));
        final query =
            'SELECT (${connection.referencingColumn}) FROM ${entityMirror.name} WHERE id = $id';

        final result = await executeSQL(query);

        for (final row in result) {
          final pg.Result foreignFieldsResult = await executeSQL(
              "SELECT * FROM ${connection.referencedEntity.name} WHERE id = ${row.first}");
          if (foreignField.mapId) {
            queryResult = reflect(ConversionService.mapToObject(
                    foreignFieldsResult.first.toColumnMap(),
                    type: foreignKey.referencedEntity))
                .getField(#id)
                .reflectee;
            return queryResult;
          }
          queryResult = ConversionService.mapToObject(
              foreignFieldsResult.first.toColumnMap(),
              type: foreignKey.referencedEntity);
        }
      } else if (foreignKey is OneToOne) {
        print("OneToOne references ${foreignKey.referencedEntity}");
        final connectionInstance = OneToOneConnectionInstance(
            EntityMirrorWithId<T>.byType(
              id: id,
            ),
            EntityMirror.byType(type: foreignKey.referencedEntity));
        queryResult = await connectionInstance.query();
        print("OneToOne res: $queryResult");
        if (foreignField.mapId) {
          return reflect(queryResult).getField(#id).reflectee;
        }
        return queryResult;
      } else if (foreignKey is ManyToMany) {
        print("ManyToMany references ${foreignKey.referencedEntity}");
        final connectionInstance = ManyToManyConnectionInstance(
            entityMirrorWithId,
            EntityMirror.byType(type: foreignKey.referencedEntity));
        queryResult = await connectionInstance.query();
        print("ManyToMany res: $queryResult");
        if (foreignField.mapId) {
          return queryResult.map((e) => e.id).toList();
        }
        return queryResult;
      } else if (foreignKey is OneToMany) {
        queryResult = [];
        final connection = OneToManyConnection(entityMirror,
            EntityMirror.byType(type: foreignKey.referencedEntity));
        final query =
            'SELECT * FROM ${connection.referencedEntity.name} WHERE ${connection.referencingColumn} = $id';
        final result = await executeSQL(query);
        if (foreignField.mapId) {
          for (final row in result) {
            queryResult.add(reflect(ConversionService.mapToObject(
                    row.toColumnMap(),
                    type: foreignKey.referencedEntity))
                .getField(#id)
                .reflectee);
          }
        } else {
          for (final row in result) {
            queryResult.add(ConversionService.mapToObject(row.toColumnMap(),
                type: reflect(foreignKey)
                    .type
                    .typeArguments
                    .first
                    .reflectedType));
          }
        }
      }

      return queryResult;
    }
  }

  Future<List<int>> insertManyToMany(
      {required EntityInstanceMirror entityInstanceMirror,
      required ForeignKey<dynamic> foreignKey,
      required ColumnMirror foreignKeyColumn}) async {
    late List<InstanceMirror>? foreignFieldInstanceMirrors;
    late final List<int> foreignFieldIds;

    print("ManyToMany");
    if (!foreignKeyColumn.mapId) {
      foreignFieldIds = entityInstanceMirror
              .field(foreignKeyColumn.name)
              ?.map((e) => e.getField(#id).reflectee)
              .whereType<int>()
              .toList() ??
          [];
      final dynamic foreignFieldsList =
          entityInstanceMirror.field(foreignKeyColumn.name);
      if (foreignFieldsList == null) {
        return [];
      }
      if (foreignFieldsList is! List) {
        throw Exception(
            "Field ${entityInstanceMirror.name}.${foreignKeyColumn.name} must be a list when anotated with ManyToMany");
      }

      for (final foreignField in foreignFieldsList) {
        foreignFieldIds.add(await dartStore.save(foreignField));
      }
    } else {
      foreignFieldIds = entityInstanceMirror.field(foreignKeyColumn.name);
    }
    final connection = OneToOneConnectionInstance(
      entityInstanceMirror.entityMirrorWithId,
      EntityMirror.byType(type: foreignKey.referencedEntity),
    );

    if (foreignKeyColumn.mapId) {
      final queryByIds = foreignFieldIds
          .map((e) async => await dartStore.query(
              type: foreignKey.referencedEntity,
              where: WhereCollection(wheres: [
                Where(
                    field: "id", compareTo: e, comporator: WhereOperator.equals)
              ])))
          .toList();

      if (queryByIds.isEmpty) {
        throw Exception(
            "No entity of ${foreignKey.referencedEntity} found with id foreignFieldId");
      }
      foreignFieldInstanceMirrors = queryByIds.map((e) => reflect(e)).toList();
    }

    if (!foreignKeyColumn.mapId) {
      for (var fieldInstanceMirror
          in foreignFieldInstanceMirrors ?? <InstanceMirror>[]) {
        fieldInstanceMirror.setField(
            #id, await dartStore.save(fieldInstanceMirror.reflectee));
      }
    }

    final List<int> res = [];
    for (final foreignFieldId in foreignFieldIds) {
      res.add(await connection.insert(otherEntityid: foreignFieldId));
    }
    return res;
  }

  Future<int?> insertOneToOne(
      {required EntityInstanceMirror entityInstanceMirror,
      required ForeignKey<dynamic> foreignKey,
      required ColumnMirror foreignKeyColumn}) async {
    InstanceMirror? foreignFieldInstanceMirror;
    late final dynamic foreignFieldId;

    print("OneToOne");
    if (!foreignKeyColumn.mapId) {
      foreignFieldInstanceMirror =
          entityInstanceMirror.fieldInstanceMirror(foreignKeyColumn.name);
      foreignFieldId = entityInstanceMirror
          .fieldInstanceMirror(foreignKeyColumn.name)
          .getField(#id)
          .reflectee;
      await dartStore.save(entityInstanceMirror
          .fieldInstanceMirror(foreignKeyColumn.name)
          .reflectee);
    } else {
      foreignFieldId = entityInstanceMirror.field(foreignKeyColumn.name);
    }
    final connection = OneToOneConnectionInstance(
      entityInstanceMirror.entityMirrorWithId,
      EntityMirror.byType(type: foreignKey.referencedEntity),
    );

    if (foreignKeyColumn.mapId) {
      final queryById = await dartStore.query(
          type: foreignKey.referencedEntity,
          where: WhereCollection(wheres: [
            Where(
                field: "id",
                compareTo: foreignFieldId,
                comporator: WhereOperator.equals)
          ]));

      if (queryById.isEmpty) {
        throw Exception(
            "No entity of ${foreignKey.referencedEntity} found with id foreignFieldId");
      }
      foreignFieldInstanceMirror = reflect(queryById.first);
    } else {
      foreignFieldInstanceMirror =
          entityInstanceMirror.fieldInstanceMirror(foreignKeyColumn.name);
    }

    if (!foreignKeyColumn.mapId) {
      foreignFieldInstanceMirror.setField(
          #id, await dartStore.save(foreignFieldInstanceMirror.reflectee));
    }
    return await connection.insert(otherEntityid: foreignFieldId);
  }

  Future<int?> insertOneToMany(
      {required EntityInstanceMirror entityInstanceMirror,
      required ForeignKey<dynamic> foreignKey,
      required ColumnMirror foreignKeyColumn}) async {
    final entity = entityInstanceMirror.instanceMirror.reflectee;
    final connection = OneToManyConnection(
      entityInstanceMirror,
      EntityMirror.byType(type: foreignKey.referencedEntity),
    );

    final modelMap = ConversionService.objectToMap(
        entityInstanceMirror.instanceMirror.reflectee);

    final EntityMirror foreignFieldEntityDecl = EntityMirror.byClassMirror(
        classMirror: entityInstanceMirror.instanceMirror.type);
    final List<ColumnMirror> foreignFieldEntityColumns =
        entityInstanceMirror.column;

    final Map<String, dynamic> values = {};
    for (final column in foreignFieldEntityColumns) {
      if (column.isForeignKey()) {
        final foreignField = column.getForeignKey();
        if (foreignField is ManyToOne) {
          final connection = OneToManyConnection(entityInstanceMirror,
              EntityMirror.byType(type: foreignField.referencedEntity));

          values[connection.referencingColumn] = entityInstanceMirror
              .fieldInstanceMirror(foreignKeyColumn.name)
              .getField(Symbol("id"))
              .reflectee;
        }
        continue;
      }
      values[column.name] = (column.dataType.convert(modelMap[column.name]));
    }
    String fieldsStatement = "";
    String valuesStatement = "";

    final _primaryKeyMirror = foreignFieldEntityDecl.primaryKeyMirror;
    if (_primaryKeyMirror.primaryKey.autoIncrement == true) {
      values.remove(_primaryKeyMirror.name);
    }
    for (final valueEntry in values.entries) {
      if (fieldsStatement.isEmpty) {
        fieldsStatement += valueEntry.key;
        valuesStatement += valueEntry.value.toString();
        continue;
      }
      fieldsStatement += ", ${valueEntry.key}";

      valuesStatement += ", ${valueEntry.value}";
    }

    final query =
        '''INSERT INTO ${entityInstanceMirror.name} ($fieldsStatement, ${connection.referencingColumn}) VALUES ($valuesStatement, ${reflect(entity).getField(Symbol("id"))}
ON CONFLICT (id) DO UPDATE 
SET ${values.entries.map((e) => "${e.key} = ${e.value}").join(', ')}, ${connection.referencingColumn} = ${reflect(entity).getField(Symbol("id"))}''';

    await executeSQL(query);
    await insertForeignFields(entity);
    if (_primaryKeyMirror.dataType is! Serial) {
      return entity.id;
    }
    return await lastInsertedId(entityInstanceMirror.name);
  }
}
