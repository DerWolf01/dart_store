import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/table_description.dart';

class ManyToOneReferencingMemberDefinition {
  ManyToOneReferencingMemberDefinition({
    required this.tableDescription,
    required this.column,
  });

  final TableDescription tableDescription;
  final Column column;

  String get tableName => tableDescription.tableName;
  String get columnName => column.name;
  SQLDataType primaryKeyType() {
    final dataType = tableDescription.primaryKeyColumn()?.dataType;
    if (dataType == null) {
      throw Exception(
          "Unable to define ManyToOne of defined on ${column.name} connection due to missing primary key for table $tableName");
    }
    return dataType;
  }
}
