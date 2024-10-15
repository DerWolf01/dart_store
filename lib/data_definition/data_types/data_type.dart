export './bytea.dart';
export './created_at.dart';
export './integer_list.dart';
export './text_list.dart';
export './updated_at.dart';
export 'bool.dart';
export 'decimal.dart';
export 'integer.dart';
export 'serial.dart';
export 'varchar.dart';

/// Every SQLDatatype to be applied to and model attribute extends this class.
abstract class SQLDataType<PrimtiveType> {
  final bool? isNullable;

  const SQLDataType({this.isNullable = false});

  Type get primitiveType => PrimtiveType;

  /// Compares the type of the value to the type of the SQLDataType.
  bool compareToType(Type type) => PrimtiveType == type;

  /// Compares the value to the type of the SQLDataType.
  bool compareToValue(dynamic value) => value is PrimtiveType;

  /// Converts the value to an SQL query conform value.
  convert(PrimtiveType? value) {
    if (value == null && isNullable == false) {
      throw Exception('Value cannot be null for $runtimeType');
    } else if (value == null && isNullable == true) {
      return null;
    }
    return value;
  }

  String sqlTypeName() => runtimeType.toString();
}
