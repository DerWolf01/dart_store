import 'package:dart_store/dart_store.dart';

class UpdatedAt extends SQLDataType<DateTime> {
  const UpdatedAt();

  @override
  convert(DateTime? value) {
    return "'${super.convert(value)}'";
  }
}
