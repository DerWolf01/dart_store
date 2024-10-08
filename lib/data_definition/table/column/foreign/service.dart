import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_definition/constraint/constraint.dart';

class ForeignColumnService {
  ForeignColumn generateForeignColumn(
      {required ForeignKey foreignKey,
      required List<SQLConstraint> constraints,
      required String name,
      required bool mapId}) {
    return ForeignColumn(
        constraints: constraints,
        foreignKey: foreignKey,
        name: name,
        mapId: mapId);
  }

  TableDescription retrieveReferencedEntity(ForeignKey foreignKey) {
    return TableService().findTable(foreignKey.referencedEntity);
  }

  InternalColumn retrievePrimaryKeyColumn(ForeignKey foreignKey) =>
      retrieveReferencedEntity(foreignKey).primaryKeyColumn();
}
