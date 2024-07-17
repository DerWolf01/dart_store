abstract class SQLDataType<PrimtiveType> {
  const SQLDataType();

  convert(PrimtiveType value) => value;
}
