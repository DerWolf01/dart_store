import 'package:dart_store/data_definition/data_types/data_type.dart';
/// A pseudo data type anotation to define the date and time when a record was updated.
class UpdatedAt extends SQLDataType<DateTime> {
  const UpdatedAt();

  @override
  convert(DateTime? value) {
    return "'${super.convert(value)}'";
  }
}
