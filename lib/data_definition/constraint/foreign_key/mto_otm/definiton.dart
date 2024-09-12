import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/description.dart';
import 'package:dart_store/data_definition/data_definition.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';

class OneToManyAndManyToOneDefinition extends DataDefinition {
  OneToManyAndManyToOneDefinition({required this.description});

  final OneToManyAndManyToOneDescription description;

  @override
  String define() {
    final res =
        "CREATE TABLE IF NOT EXISTS $connectionName (id SERIAL PRIMARY KEY, $manyToOneTableName ${manyToOneIdDataType.sqlTypeName()} NOT NULL UNIQUE, $oneToManyTableName ${oneToManyIdDataType.sqlTypeName()} NOT NULL, FOREIGN KEY ($oneToManyTableName) REFERENCES $oneToManyTableName(id) ON DELETE CASCADE, FOREIGN KEY ($manyToOneTableName) REFERENCES $manyToOneTableName(id) ON DELETE CASCADE)";

    return res;
  }

  String get oneToManyTableName =>
      description.oneToManyTableDescription.tableName;

  String get manyToOneTableName =>
      description.manyToOneTableDescription.tableName;

  SQLDataType get oneToManyIdDataType =>
      description.oneToManyTableDescription.primaryKeyColumn().dataType;

  SQLDataType get manyToOneIdDataType =>
      description.manyToOneTableDescription.primaryKeyColumn().dataType;

  String get connectionName =>
      "${description.oneToManyTableDescription.tableName}_${description.manyToOneTableDescription.tableName}";
}
