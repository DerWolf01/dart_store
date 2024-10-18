import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/exception.dart';
import 'package:test/test.dart';

void main() {
  group(
    "Varchar:",
    () {
      test("Convert value", () {
        final varchar = Varchar();
        final value = "test";
        final convertedValue = "'test'";
        expect(varchar.convert(value), convertedValue);
      });

      test("Convert null value without marking as nullable", () {
        try {
          Varchar().convert(null);
        } catch (e) {
          expect(e, e is NotNullableException);
        }
      });
    },
  );
}
