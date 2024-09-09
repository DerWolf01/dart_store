import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/statement/statement.dart';

class DeleteStatement extends Statement {
  DeleteStatement({required this.entityInstance});
  final EntityInstance entityInstance;

  @override
  String define() {
    internalColumns
        .map(
          (e) => "${e.sqlName} = ${e.sqlConformValue}",
        )
        .join(", ");
    return "DELETE FROM ${entityInstance.tableName} CASCADE";
  }

  List<InternalColumnInstance> get internalColumns =>
      entityInstance.columns.whereType<InternalColumnInstance>().toList();
}
