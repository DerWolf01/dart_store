import 'package:dart_store/sql/sql_anotations/sql_anotations.dart';
import 'package:postgres/postgres.dart';

class CreatedAt extends SQLDataType<DateTime> {
  const CreatedAt();

  @override
  convert(DateTime? value) {
    return "'${super.convert(value)}'";
  }
}
