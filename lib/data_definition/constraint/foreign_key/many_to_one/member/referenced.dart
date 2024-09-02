import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/table_description.dart';

class ManyToOneReferencedMemberDefinition {
  ManyToOneReferencedMemberDefinition({
    required this.tableDescription,
  });

  final TableDescription tableDescription;

  String get tableName => tableDescription.tableName;
  InternalColumn get column {
    final column = tableDescription.primaryKeyColumn();
    if (column == null) {
      throw Exception(
          "Unable to define ManyToOne connection due to missing primary key definition for table $tableName");
    }
    return column;
  }

  SQLDataType primaryKeyType() {
    final dataType = tableDescription.primaryKeyColumn()?.dataType;
    if (dataType == null) {
      throw Exception(
          "Unable to define ManyToOne of defined on ${column.name} connection due to missing primary key for table $tableName");
    }
    return dataType;
  }
}
