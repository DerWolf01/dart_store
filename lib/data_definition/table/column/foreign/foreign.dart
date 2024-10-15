import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/service.dart';
/// A column that define a foreign key decleration.
class ForeignColumn<T extends ForeignKey> extends Column {
  final T foreignKey;
  final bool mapId;

  ForeignColumn({
    required super.constraints,
    required this.foreignKey,
    required super.name,
    required this.mapId,
  });

  @override
  String get sqlName =>
      TableService().findTable(foreignKey.referencedEntity).tableName;
}
