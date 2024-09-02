import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/table_description.dart';

class OneToOneMemberDefinition {
  OneToOneMemberDefinition({
    required this.tableDescription,
  });

  final TableDescription tableDescription;
  InternalColumn get column => tableDescription.primaryKeyColumn();

  String get tableName => tableDescription.tableName;
  String get columnName => column.name;
  SQLDataType primaryKeyType() => column.dataType;
}
