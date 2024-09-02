import 'package:dart_store/data_definition/table/column/foreign/external.dart';
import 'package:dart_store/data_definition/table/column/foreign/internal.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_definition/constraint/constraint.dart';

class ForeignColumnService {
  generateForeignColumn(
      {required ForeignKey foreignKey,
      required List<SQLConstraint> constraints,
      required String snakeCaseName}) {
    final isExternalColumn = foreignKey is ManyToMany ||
        foreignKey is OneToOne ||
        foreignKey is ManyToOne;
    if (isExternalColumn) {
      return ExternalForeignColumn(
          constraints: constraints,
          foreignKey: foreignKey,
          name: snakeCaseName);
    }
    return InternalForeignColumn(
        dataType: retrievePrimaryKeyColumn(foreignKey).dataType,
        constraints: constraints,
        foreignKey: foreignKey,
        name: snakeCaseName);
  }

  TableDescription retrieveReferencedEntity(ForeignKey foreignKey) {
    return TableService().findTable(foreignKey.referencedEntity);
  }

  InternalColumn retrievePrimaryKeyColumn(ForeignKey foreignKey) =>
      retrieveReferencedEntity(foreignKey).primaryKeyColumn();
}
