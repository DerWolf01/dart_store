import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/update/service.dart';
import 'package:dart_store/data_manipulation/update/statement.dart';

class InsertStatement {
  InsertStatement({required this.entityInstance});
  final EntityInstance entityInstance;

  String define() {
    final insertIntoColumns = this.insertIntoColumns;
    final sqlConformColumnNameString = insertIntoColumns
        .map(
          (e) => e.sqlName,
        )
        .join(", ");
    final sqlConformValues = insertIntoColumns.map(
      (e) => e.sqlConformValue,
    );

    final String sqlConformValuesString = sqlConformValues.join(', ');

    final res =
        "INSERT INTO ${entityInstance.tableName} ($sqlConformColumnNameString) VALUES ($sqlConformValuesString) ON CONFLICT(id) DO UPDATE SET ${insertIntoColumns.map(
              (e) => "${e.sqlName} = ${e.sqlConformValue}",
            ).join(", ")} RETURNING";
    print(res);
    return res;
  }

  List<InternalColumnInstance> get insertIntoColumns => entityInstance.columns
      .whereType<InternalColumnInstance>()
      .where((element) => !(element.isAutoIncrement &&
          (element.value == -1 || element.value == null)))
      .toList();
}
