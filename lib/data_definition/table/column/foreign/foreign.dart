import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/service.dart';

import 'package:dart_store/mapping/map_id.dart';

class ForeignColumn<T extends ForeignKey> extends Column {
  final T foreignKey;
  @override
  String get sqlName =>
      TableService().findTable(foreignKey.referencedEntity).tableName;

  ForeignColumn({
    required super.constraints,
    required this.foreignKey,
    required super.name,
  });

  bool get mapId => hasConstraint<MapId>();
}
