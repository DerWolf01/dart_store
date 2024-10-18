class NotNullableException implements Exception {
  final String columnName;
  final Type columnType;
  NotNullableException({
    required this.columnName,
    required this.columnType,
  });
  @override
  String toString() {
    return 'NotNullableException: Column $columnName of type $columnType cannot be nullable. Mark it as nullable by adding the nullabe parameter to the @SQLDataType() anotation. Example: @VarChar(nullable: true)';
  }
}

class NotNullException implements Exception {
  final String columnName;
  final Type columnType;
  NotNullException({
    required this.columnName,
    required this.columnType,
  });
  @override
  String toString() {
    return 'NotNullException: Column $columnName of type $columnType cannot be null';
  }
}

class PrimaryKeyException implements Exception {
  final String columnName;
  final Type columnType;
  final dynamic value;
  PrimaryKeyException({
    required this.columnName,
    required this.columnType,
    required this.value,
  });
  @override
  String toString() {
    return 'AutoIncrementException: Column $columnName of type $columnType cannot be null if not anotated with @AutoIncrement() or @PrimaryKey(autoIncrement: true)';
  }
}

class UniqueException implements Exception {
  final String columnName;
  final Type columnType;
  final dynamic value;
  UniqueException({
    required this.columnName,
    required this.columnType,
    required this.value,
  });
  @override
  String toString() {
    return 'UniqueException: An column of value ($value) with name $columnName of $columnType exists already. Remove the @Unique() anotation or change the value';
  }
}
