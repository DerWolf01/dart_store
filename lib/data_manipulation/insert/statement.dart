import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';

class InsertStatement {
  InsertStatement({required this.entityInstance});
  final EntityInstance entityInstance;

  String define() {
    final insertIntoColumns = this.insertIntoColumns;
    final sqlConformColumnNameString = {
      insertIntoColumns
          .map(
            (e) => e.name,
          )
          .join(", ")
    };
    final sqlConformValues = insertIntoColumns.map(
      (e) => e.sqlConformValue,
    );

    final String sqlConformValuesString = sqlConformValues.join(', ');

    final String sqlConformOnConflictString = insertIntoColumns
        .map(
          (e) => "${e.name} = ${e.sqlConformValue}",
        )
        .join(", ");
    return "INSERT INTO $sqlConformColumnNameString VALUES ($sqlConformValuesString) ON CONFLICt (id) SET $sqlConformOnConflictString ";
  }

  List<InternalColumnInstance> get insertIntoColumns => entityInstance.columns
      .where(
        (element) =>
            !element.isAutoIncrement && element is InternalColumnInstance,
      )
      .toList() as List<InternalColumnInstance>;
}
