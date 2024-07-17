import 'dart:mirrors';

import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql/declarations/entity_decl.dart';
import 'package:dart_store/sql/sql_anotations/constraints/constraint.dart';

class ConstraintService {
  List<String> getConstraints(EntityDecl entityDecl) {
    final List<String> constraintStatements = [];

    for (final column in entityDecl.column) {
      final constraints = column.constraints;
      constraints.removeWhere(
        (element) => element is PrimaryKey,
      );
      for (final constraint in constraints) {
        final constraintStatement = _generateConstraintStatement(
            entityDecl.name, column.name, constraint);
        constraintStatements.add(constraintStatement);
      }
    }
    return constraintStatements;
  }

  _generateConstraintStatement(
      String tableName, String columnName, SQLConstraint constraint) {
    if (constraint is NotNull) {
      return 'ALTER TABLE $tableName ALTER COLUMN $columnName SET NOT NULL';
    } else if (constraint is ForeignKey) {
      return 'ALTER TABLE $tableName ADD FOREIGN KEY ($columnName) REFERENCES ${reflect(constraint).type.typeArguments.first}';
    }
  }

  Future<void> setCoinstraints(EntityDecl entityDecl) async {
    final constraints = getConstraints(entityDecl);
    print(constraints);
    for (final constraint in constraints) {
      await dartStore.execute(constraint);
    }

    return;
  }
}
