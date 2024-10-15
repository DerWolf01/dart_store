import 'package:dart_store/data_definition/data_types/data_type.dart';

/// A data type to define a decimal value.
class Decimal extends SQLDataType<double> {
  const Decimal({super.isNullable});
}
