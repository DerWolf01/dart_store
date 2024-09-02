import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/statement/statement.dart';

class UpdateStatement extends Statement {
  UpdateStatement({required this.entityInstance});
  final EntityInstance entityInstance;

  @override
  String define() {
    final String sqlSetColumnsString = internalColumns
        .map(
          (e) => "${e.name} = ${e.sqlConformValue}",
        )
        .join(", ");
    return "UPDATE ${entityInstance.tableName} SET $sqlSetColumnsString ";
  }

  List<InternalColumnInstance> get internalColumns =>
      entityInstance.columns.whereType<InternalColumnInstance>().toList();
}
