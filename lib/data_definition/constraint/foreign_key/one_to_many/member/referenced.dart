import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/column/internal_column.dart';
import 'package:dart_store/data_definition/table/table_description.dart';

class OneToManyReferencedMemberDefinition {
  OneToManyReferencedMemberDefinition({
    required this.tableDescription,
  });

  final TableDescription tableDescription;

  String get tableName => tableDescription.tableName;
}
