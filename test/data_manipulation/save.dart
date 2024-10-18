import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_manipulation/insert/conflict.dart';
import 'package:test/test.dart';

import '../test_model/user.dart';


/// Test saving a record with auto increment primary key.
/// Checks if the saved record has a non-negative primary key and the auto increament actually works.
void testSavingAutoIncrement() async => test(
      "Save: primary key auto increment",
      () async {
        final savedUser = await dartStore.save(
          User.init(id: -1, name: "John", age: 25),
        );
        expect(savedUser.id, isNonNegative);
        final savedUser0 = await dartStore.save(
          User.init(id: -1, name: "John", age: 25),
        );

        expect(savedUser0.id, isNonNegative);
        expect(savedUser0.id, isNot(savedUser.id));
      },
    );

void testSavingSpecificPrimaryKey() async => test(
      "Save: specific  primary key",
      () async {
        final savedUser = await dartStore.save(
            User.init(id: 4, name: "John", age: 25),
            conflictAlgorithm: ConflictAlgorithm.replace);
        expect(savedUser.id, 4);
      },
    );

void testSavingSpecificPrimaryKeyWithConflict() async => test(
      "Save: specific primary key with conflict",
      () async {
        final savedUser = await dartStore.save(
            User.init(id: 4, name: "John", age: 25),
            conflictAlgorithm: ConflictAlgorithm.replace);
        expect(savedUser.id, 4);
        final savedUser0 = await dartStore.save(
            User.init(id: 4, name: "John", age: 25),
            conflictAlgorithm: ConflictAlgorithm.ignore);
        expect(savedUser0.id, 4);
      },
    );

