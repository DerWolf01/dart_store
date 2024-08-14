export './bool.dart';
export './double.dart';
export './integer.dart';
export './serial.dart';
export './varchar.dart';
export './pseudo_types.dart';

abstract class SQLDataType<PrimtiveType> {
  const SQLDataType({this.isNullable = false});

  final bool? isNullable;

  String sqlTypeName() => runtimeType.toString();

  convert(PrimtiveType? value) {
    if (value == null && isNullable == false) {
      throw Exception('Value cannot be null');
    } else if (value == null && isNullable == true) {
      return null;
    }
    return value;
  }
}
