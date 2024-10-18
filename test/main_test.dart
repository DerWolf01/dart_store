import 'package:dart_store/dart_store.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import 'data_manipulation/save.dart';

void main() async {
  setUpAll(() async => DartStore.init(
        await PostgresConnection.init(
          settings: ConnectionSettings(sslMode: SslMode.disable),
          endpoint: Endpoint(
            host: 'localhost',
            database: 'ebay_watcher',
            username: 'ebay_watcher',
            password: 'ebay_watcher',
          ),
        ),
      ));

  group("DML:test", () {
    testSavingAutoIncrement();
    testSavingSpecificPrimaryKey();
  });

  tearDownAll(() async => dartStore.close());
}
