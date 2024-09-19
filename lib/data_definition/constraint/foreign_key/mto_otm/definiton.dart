import 'package:dart_store/data_definition/constraint/foreign_key/mto_otm/description.dart';
import 'package:dart_store/data_definition/data_definition.dart';

class OneToManyAndManyToOneDefinition extends DataDefinition {
  final OneToManyAndManyToOneDescription description;

  OneToManyAndManyToOneDefinition({required this.description});

  String get connectionName =>
      "${description.oneToManyTableDescription.tableName}_${description.manyToOneTableDescription.tableName}";

  SQLDataType get manyToOneIdDataType =>
      description.manyToOneTableDescription.primaryKeyColumn().dataType;

  String get manyToOneTableName =>
      description.manyToOneTableDescription.tableName;

  SQLDataType get oneToManyIdDataType =>
      description.oneToManyTableDescription.primaryKeyColumn().dataType;

  String get oneToManyTableName =>
      description.oneToManyTableDescription.tableName;

  @override
  String define() {
    final res =
        "CREATE TABLE IF NOT EXISTS $connectionName (id SERIAL PRIMARY KEY, $manyToOneTableName ${manyToOneIdDataType.sqlTypeName()} NOT NULL UNIQUE, $oneToManyTableName ${oneToManyIdDataType.sqlTypeName()} NOT NULL, FOREIGN KEY ($oneToManyTableName) REFERENCES $oneToManyTableName(id) ON DELETE CASCADE, FOREIGN KEY ($manyToOneTableName) REFERENCES $manyToOneTableName(id))";

    return res;
  }
}
