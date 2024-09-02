import 'package:dart_store/data_definition/data_types/data_type.dart';

class UpdatedAt extends SQLDataType<DateTime> {
  const UpdatedAt();

  @override
  convert(DateTime? value) {
    return "'${super.convert(value)}'";
  }
}
