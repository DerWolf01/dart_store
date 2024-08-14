import 'dart:mirrors';
import 'package:dart_store/dart_store.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/services/dml_service.dart';
import 'package:postgres/postgres.dart';

class ConstraintService {
  List<String> getConstraints(EntityDecl entityDecl) {
    final List<String> constraintStatements = [];

    for (final column in entityDecl.column) {
      final constraints = column.constraints;
      constraints.removeWhere(
        (element) => element is PrimaryKey,
      );
      for (final constraint in constraints) {
        final constraintStatement =
            _generateConstraintStatement(entityDecl, column, constraint);

        if (constraintStatement == null) continue;
        constraintStatements.addAll(constraintStatement);
      }
    }

    return constraintStatements;
  }

  _generateConstraintStatement(
      EntityDecl _entityDecl, ColumnDecl columnDecl, SQLConstraint constraint) {
    if (constraint is NotNull) {
      return 'ALTER TABLE ${_entityDecl.name} ALTER COLUMN ${columnDecl.name} SET NOT NULL';
    } else if (constraint is OneToMany) {
      return OneToManyConnection(
        _entityDecl,
        entityDecl(
            type: reflect(constraint).type.typeArguments.first.reflectedType),
      ).connectionStatements;
    } else if (constraint is OneToOne) {
      return OneToOneConnection(
        _entityDecl,
        entityDecl(
            type: reflect(constraint).type.typeArguments.first.reflectedType),
      ).connectionStatements;
    } else if (constraint is ManyToOne) {
      return ManyToOneConnection(
        _entityDecl,
        entityDecl(
            type: reflect(constraint).type.typeArguments.first.reflectedType),
      ).connectionStatements;
    }
  }

  Future<void> setCoinstraints(EntityDecl entityDecl) async {
    final constraints = getConstraints(entityDecl);
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
    final _entityDecl = entityDecl(type: entity.runtimeType);

    final foreignKeyColumns =
        _entityDecl.column.where((element) => element.isForeignKey());
    for (final foreignKeyColumn in foreignKeyColumns) {
      final foreignKey = foreignKeyColumn.getForeignKey();
      if (foreignKey is OneToMany) {
        final connection = OneToManyConnection(
          _entityDecl,
          entityDecl(
              type: reflect(foreignKey).type.typeArguments.first.reflectedType),
        );

        final modelMap = ConversionService.objectToMap(entity);

        final EntityDecl _foreignFieldEntityDecl =
            entityDecl(type: entity.runtimeType);
        final List<ColumnDecl> _foreignFieldEntityColumns = _entityDecl.column;

        final Map<String, dynamic> values = {};
        for (final column in _foreignFieldEntityColumns) {
          if (column.isForeignKey()) {
            final foreignField = column.getForeignKey();
            if (foreignField is ManyToOne) {
              final connection = OneToManyConnection(
                  _entityDecl,
                  entityDecl(
                      type: reflect(foreignField)
                          .type
                          .typeArguments
                          .first
                          .reflectedType));

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

        final _primaryKeyDecl = _foreignFieldEntityDecl.primaryKeyDecl;
        if (_primaryKeyDecl.primaryKey.autoIncrement == true) {
          values.remove(_primaryKeyDecl.name);
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
            '''INSERT INTO ${_entityDecl.name} ($fieldsStatement, ${connection.referencingColumn}) VALUES ($valuesStatement, ${reflect(entity).getField(Symbol("id"))}
ON CONFLICT (id) DO UPDATE 
SET ${values.entries.map((e) => "${e.key} = ${e.value}").join(', ')}, ${connection.referencingColumn} = ${reflect(entity).getField(Symbol("id"))}''';

        await executeSQL(query);
        await insertForeignFields(entity);
        if (_primaryKeyDecl.dataType is! Serial) {
          return entity.id;
        }
        return await lastInsertedId(_entityDecl.name);
      }
    }
  }

  @override
  Future<dynamic> query<T>(dynamic id) async {
    final _entityDecl = entityDecl<T>();
    late dynamic queryResult;
    final foreignFields = _entityDecl.column.where(
      (element) => element.dataType is ForeignField,
    );

    for (final foreignField in foreignFields) {
      final foreignKey = foreignField.getForeignKey();
      if (foreignKey is ManyToOne) {
        final connection = ManyToOneConnection(
            _entityDecl,
            entityDecl(
                type: reflect(foreignKey)
                    .type
                    .typeArguments
                    .first
                    .reflectedType));
        final query =
            'SELECT (${connection.referencingColumn}) FROM ${_entityDecl.name} WHERE id = $id';

        final result = await executeSQL(query);

        for (final row in result) {
          final Result foreignFieldsResult = await executeSQL(
              "SELECT * FROM ${connection.referencedEntity.name} WHERE id = ${row.first}");

          queryResult = ConversionService.mapToObject(
              foreignFieldsResult.first.toColumnMap(),
              type: reflect(foreignKey).type.typeArguments.first.reflectedType);
        }
      }
      if (foreignKey is OneToOne) {
        final connection = OneToOneConnection(
            _entityDecl,
            entityDecl(
                type: reflect(foreignKey)
                    .type
                    .typeArguments
                    .first
                    .reflectedType));
        final query =
            'SELECT (${connection.referencedEntity.name}_id) FROM ${connection.connectionTableName} WHERE ${connection.referencingEntity}_id = $id';
        final result = await executeSQL(query);
        for (final row in result) {
          final Result foreignFieldsResult = await executeSQL(
              "SELECT * FROM ${connection.referencedEntity.name} WHERE id = ${row.first}");
          queryResult = ConversionService.mapToObject(
              foreignFieldsResult.first.toColumnMap(),
              type: reflect(foreignKey).type.typeArguments.first.reflectedType);
        }
      }
      if (foreignKey is OneToMany) {
        queryResult = [];
        final connection = OneToManyConnection(
            _entityDecl,
            entityDecl(
                type: reflect(foreignKey)
                    .type
                    .typeArguments
                    .first
                    .reflectedType));
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

abstract class ForeignKeyConnection {
  List<String> get connectionStatements;
}

class OneToManyConnection extends ForeignKeyConnection {
  final EntityDecl referencingEntity;
  final EntityDecl referencedEntity;

  OneToManyConnection(this.referencingEntity, this.referencedEntity);

  String get referencingColumn => '${referencingEntity.name}_id';

  @override
  get connectionStatements => [
        "ALTER TABLE ${referencedEntity.name} ADD COLUMN IF NOT EXISTS $referencingColumn ${referencingEntity.primaryKeyType.runtimeType}",
        "ALTER TABLE ${referencedEntity.name} DROP CONSTRAINT IF EXISTS $referencingColumn",
        'ALTER TABLE ${referencedEntity.name} ADD FOREIGN KEY  ($referencingColumn) REFERENCES ${referencingEntity.name}(id)'
      ];
}

class ManyToOneConnection extends ForeignKeyConnection {
  final EntityDecl referencingEntity;
  final EntityDecl referencedEntity;

  ManyToOneConnection(this.referencingEntity, this.referencedEntity);

  String get referencingColumn => '${referencedEntity.name}_id';

  @override
  get connectionStatements => [
        "ALTER TABLE ${referencingEntity.name} ADD COLUMN IF NOT EXISTS $referencingColumn ${referencingEntity.primaryKeyType.runtimeType}",
        "ALTER TABLE  ${referencingEntity.name} DROP CONSTRAINT IF EXISTS $referencingColumn",
        'ALTER TABLE ${referencingEntity.name} ADD FOREIGN KEY  ($referencingColumn) REFERENCES ${referencedEntity.name}(id)'
      ];
}

class OneToOneConnection extends ForeignKeyConnection {
  final EntityDecl referencingEntity;
  final EntityDecl referencedEntity;

  OneToOneConnection(this.referencedEntity, this.referencingEntity);

  String get connectionTableName =>
      '${referencingEntity.name}_${referencedEntity.name}';

  @override
  List<String> get connectionStatements => [
        'CREATE TABLE IF NOT EXISTS $connectionTableName (${referencingEntity.name}_id ${referencingEntity.primaryKeyType.sqlTypeName()} REFERENCES ${referencingEntity.name}(id}), ${referencedEntity.name}_id ${referencedEntity.primaryKeyType.sqlTypeName()} REFERENCES ${referencedEntity.name}(id}), PRIMARY KEY(${referencingEntity.name}_id, ${referencedEntity.name}_id)'
      ];
}
