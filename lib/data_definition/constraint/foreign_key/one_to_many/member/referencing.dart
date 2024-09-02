import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';

class OneToManyReferencingMemberDefinition {
  OneToManyReferencingMemberDefinition({
    required this.tableDescription,
  });

  final TableDescription tableDescription;

  String get tableName => tableDescription.tableName;
  
  InternalColumn get column => tableDescription.primaryKeyColumn();

  SQLDataType primaryKeyType() {
    final dataType = tableDescription.primaryKeyColumn()?.dataType;
    if (dataType == null) {
      throw Exception(
          "Unable to define OneToMany of defined on ${column.name} connection due to missing primary key for table $tableName");
    }
    return dataType;
  }
}
