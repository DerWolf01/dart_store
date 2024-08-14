import 'package:dart_store/sql/sql_anotations/sql_anotations.dart';
import 'package:postgres/postgres.dart';

class CreatedAt extends SQLDataType<Time> {
  const CreatedAt();
}
