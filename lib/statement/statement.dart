import 'package:dart_store/utility/dart_store_utility.dart';

abstract class Statement with DartStoreUtility {
  const Statement();
  String define();
}
