import 'package:dart_store/data_definition/data_types/data_type.dart';

class CreatedAt extends SQLDataType<DateTime> {
  const CreatedAt();

  @override
  convert(DateTime? value) {
    return "'${super.convert(value)}'";
  }
}
