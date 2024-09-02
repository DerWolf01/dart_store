export 'bool.dart';
export 'double.dart';
export 'integer.dart';
export './integer_list.dart';
export './text_list.dart';
export 'serial.dart';
export 'varchar.dart';
export './bytea.dart';
export './created_at.dart';
export './updated_at.dart';

abstract class SQLDataType<PrimtiveType> {
  const SQLDataType({this.isNullable = false});

  final bool? isNullable;

  String sqlTypeName() => runtimeType.toString();

  convert(PrimtiveType? value) {
    if (value == null && isNullable == false) {
      throw Exception('Value cannot be null for $runtimeType');
    } else if (value == null && isNullable == true) {
      return null;
    }
    return value;
  }

  bool compareToType(Type type) => PrimtiveType == type;
  bool compareToValue(dynamic value) => value is PrimtiveType;

  Type get primitiveType => PrimtiveType;
}
