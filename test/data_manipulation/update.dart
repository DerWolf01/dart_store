import 'package:dart_store/dart_store.dart';
import 'package:test/test.dart';

import '../test_model/user.dart';

void testUpdate() async {
  test(
    "Without id",
    () async {
      final savedUser = await dartStore.save(
        User.init(id: -1, name: "John", age: 25),
      );

      expect(savedUser.id, isNonNegative);
    },
  );
}
