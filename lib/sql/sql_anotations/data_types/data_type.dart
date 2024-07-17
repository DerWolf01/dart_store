export './bool.dart';
export './double.dart';
export './integer.dart';
export './serial.dart';
export './varchar.dart';


abstract class SQLDataType<PrimtiveType> {
  const SQLDataType();

  convert(PrimtiveType value) => value;
}
