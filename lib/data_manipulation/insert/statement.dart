import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/insert/conflict.dart';
import 'package:dart_store/data_manipulation/update/service.dart';
import 'package:dart_store/data_manipulation/update/statement.dart';

class InsertStatement {
  InsertStatement(
      {required this.entityInstance,
      this.conflictAlgorithm = ConflictAlgorithm.ignore});
  final EntityInstance entityInstance;
  final ConflictAlgorithm conflictAlgorithm;

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
    final onConflict = conflictAlgorithm == ConflictAlgorithm.ignore
        ? " ON CONFLICT DO NOTHING"
        : " ON CONFLICT(id) DO UPDATE SET ${insertIntoColumns.map(
              (e) => "${e.sqlName} = ${e.sqlConformValue}",
            ).join(", ")}";
    final res =
        "INSERT INTO ${entityInstance.tableName} ($sqlConformColumnNameString) VALUES ($sqlConformValuesString) $onConflict RETURNING id;";
    print(res);
    return res;
  }

  List<InternalColumnInstance> get insertIntoColumns => entityInstance.columns
      .whereType<InternalColumnInstance>()
      .where((element) => !(element.isAutoIncrement &&
          (element.value == -1 || element.value == null)))
      .toList();
}
