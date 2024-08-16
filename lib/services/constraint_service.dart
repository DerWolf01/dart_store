import 'dart:async';
import 'dart:math';
import 'dart:mirrors';
import 'package:dart_store/dart_store.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/services/dml_service.dart';
import 'package:dart_store/sql/connection/many_to_many.dart';
import 'package:dart_store/sql/connection/one_to_many.dart';
import 'package:dart_store/sql/connection/one_to_one/one_to_one.dart';
import 'package:dart_store/sql/connection/one_to_one/one_to_one_instance.dart';
import 'package:dart_store/sql/mirrors/entity/entity_instance_mirror.dart';
import 'package:dart_store/sql/mirrors/entity/entity_mirror_with_id.dart';
import 'package:postgres/legacy.dart';
import 'package:postgres/postgres.dart';

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
  Future<int?> insertForeignFields(dynamic entity) async {
    final entityMirror = EntityInstanceMirror(
      instanceMirror: reflect(entity),
    );

    final foreignKeyColumns =
        entityMirror.column.where((element) => element.isForeignKey());
    for (final foreignKeyColumn in foreignKeyColumns) {
      final foreignKey = foreignKeyColumn.getForeignKey();

      if (foreignKey is OneToOne) {
        print("OneToOne");
        await dartStore.save(
            entityMirror.fieldInstanceMirror(foreignKeyColumn.name).reflectee);
        final connection = OneToOneConnectionInstance(
          entityMirror.entityMirrorWithId,
          EntityMirror.byType(
              type: reflect(foreignKey).type.typeArguments.first.reflectedType),
        );

        return await connection.insert(
            otherEntityWithid: EntityInstanceMirror(
                    instanceMirror:
                        entityMirror.fieldInstanceMirror(foreignKeyColumn.name))
                .entityMirrorWithId);
      } else if (foreignKey is OneToMany) {
        final connection = OneToManyConnection(
          entityMirror,
          EntityMirror.byType(
              type: reflect(foreignKey).type.typeArguments.first.reflectedType),
        );

        final modelMap = ConversionService.objectToMap(entity);

        final EntityMirror foreignFieldEntityDecl =
            EntityMirror.byType(type: entity.runtimeType);
        final List<ColumnMirror> foreignFieldEntityColumns =
            entityMirror.column;

        final Map<String, dynamic> values = {};
        for (final column in foreignFieldEntityColumns) {
          if (column.isForeignKey()) {
            final foreignField = column.getForeignKey();
            if (foreignField is ManyToOne) {
              final connection = OneToManyConnection(entityMirror,
                  EntityMirror.byType(type: foreignField.referencedEntity));

              values[connection.referencingColumn] = reflect(entity)
                  .getField(Symbol(column.name))
                  .getField(Symbol("id"));
            }
            continue;
          }
          values[column.name] =
              (column.dataType.convert(modelMap[column.name]));
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
            '''INSERT INTO ${entityMirror.name} ($fieldsStatement, ${connection.referencingColumn}) VALUES ($valuesStatement, ${reflect(entity).getField(Symbol("id"))}
ON CONFLICT (id) DO UPDATE 
SET ${values.entries.map((e) => "${e.key} = ${e.value}").join(', ')}, ${connection.referencingColumn} = ${reflect(entity).getField(Symbol("id"))}''';

        await executeSQL(query);
        await insertForeignFields(entity);
        if (_primaryKeyMirror.dataType is! Serial) {
          return entity.id;
        }
        return await lastInsertedId(entityMirror.name);
      }
    }
    return null;
  }

  Future<dynamic> query<T>(dynamic id) async {
    final entityMirror = EntityMirror<T>.byType();
    late dynamic queryResult;
    final foreignFields = entityMirror.column.where(
      (element) => element.dataType is ForeignField,
    );

    for (final foreignField in foreignFields) {
      final foreignKey = foreignField.getForeignKey();
      if (foreignKey is ManyToOne) {
        final connection = ManyToOneConnection(
            entityMirror,
            EntityMirror.byType(
                type: reflect(foreignKey)
                    .type
                    .typeArguments
                    .first
                    .reflectedType));
        final query =
            'SELECT (${connection.referencingColumn}) FROM ${entityMirror.name} WHERE id = $id';

        final result = await executeSQL(query);

        for (final row in result) {
          final Result foreignFieldsResult = await executeSQL(
              "SELECT * FROM ${connection.referencedEntity.name} WHERE id = ${row.first}");

          queryResult = ConversionService.mapToObject(
              foreignFieldsResult.first.toColumnMap(),
              type: reflect(foreignKey).type.typeArguments.first.reflectedType);
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
        return queryResult;
      } else if (foreignKey is OneToMany) {
        queryResult = [];
        final connection = OneToManyConnection(entityMirror,
            EntityMirror.byType(type: foreignKey.referencedEntity));
        final query =
            'SELECT * FROM ${connection.referencedEntity.name} WHERE ${connection.referencingColumn} = $id';
        final result = await executeSQL(query);
        for (final row in result) {
          queryResult.add(ConversionService.mapToObject(row.toColumnMap(),
              type:
                  reflect(foreignKey).type.typeArguments.first.reflectedType));
        }
      }
    }
    return queryResult;
  }
}
