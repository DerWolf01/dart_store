import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/column/internal_column.dart';
import 'package:dart_store/data_definition/table/table_description.dart';

class OneToManyReferencingMemberDefinition {
  OneToManyReferencingMemberDefinition({
    required this.tableDescription,
  });

  final TableDescription tableDescription;

  String get tableName => tableDescription.tableName;
  InternalColumn get column {
    final column = tableDescription.primaryKeyColumn();
    if (column == null) {
      throw Exception(
          "Unable to define OneToMany connection due to missing primary key definition for table $tableName");
    }
    return column;
  }

  SQLDataType primaryKeyType() {
    final dataType = tableDescription.primaryKeyColumn()?.dataType;
    if (dataType == null) {
      throw Exception(
          "Unable to define OneToMany of defined on ${column.name} connection due to missing primary key for table $tableName");
    }
    return dataType;
  }
}
