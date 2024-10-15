import 'package:dart_store/data_definition/data_types/data_type.dart';

/// A pseudo data type anotation to define the date and time when a record was created.
class CreatedAt extends SQLDataType<DateTime> {
  const CreatedAt();

  @override
  convert(DateTime? value) {
    return "'${super.convert(value)}'";
  }
}
