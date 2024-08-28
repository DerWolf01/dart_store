import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/table_description.dart';

class ManyToManyMemberDefinition {
  ManyToManyMemberDefinition({
    required this.tableDescription,
  });

  final TableDescription tableDescription;

  String get tableName => tableDescription.tableName;
  SQLDataType primaryKeyType() {
    final dataType = tableDescription.primaryKeyColumn()?.dataType;
    if (dataType == null) {
      throw Exception(
          "Unable to define ManyToMany connection due to missing primary key for table $tableName");
    }
    return dataType;
  }
}
