library dart_store;

export 'package:dart_store/database/database_connection.dart';
import 'package:dart_store/converter/converter.dart';
import 'package:dart_store/data_definition/service.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';
import 'package:dart_store/data_manipulation/service.dart';
import 'package:dart_store/data_query/service.dart';
import 'dart:async';
import 'dart:mirrors';
import 'package:dart_store/database/database_connection.dart';
import 'package:dart_store/where/statement.dart';
//TODO: Remove before deployment
export 'package:change_case/change_case.dart';
export 'package:dart_store/data_definition/data_definition.dart';

DartStore get dartStore => DartStore();

class DartStore {
  static DartStore? _instance;
  DatabaseConnection connection;

  DartStore._internal(this.connection);

  execute(String statement) async => await connection.execute(statement);
  static Future<DartStore> init<ConnectionType extends DatabaseConnection>(
      ConnectionType connection) async {
    _instance ??= DartStore._internal(connection);
    await DataDefinitonService().defineData();
    return _instance!;
  }

  factory DartStore() {
    if (_instance == null) {
      throw Exception('DartStore not initialized');
    }

    return _instance!;
  }

  Future<List<T>> query<T>({List<Where> where = const [], Type? type}) async {
    final dynamic t = type ?? T;
    if (t == dynamic) {
      throw Exception('Generic Type T or type parameter is required');
    }
    final List<EntityInstance> entityInstances = await DataQueryService().query(
      description: TableService().findTable(t),
      where: where,
    );

    return entityInstances
        .map(
          (e) => entityInstanceToModel<T>(e, type: type),
        )
        .toList();
  }

  Future<T> save<T>(T model) async => entityInstanceToModel<T>(
      await DataManipulationService().insert(
          entityInstance: EntityInstanceService()
              .entityInstanceByValueInstance(reflect(model))),
      type: model.runtimeType);

  Future<T> update<T>(T model, {List<Where> where = const []}) async {
    return entityInstanceToModel<T>(
        await DataManipulationService().update(
          EntityInstanceService().entityInstanceByValueInstance(reflect(model)),
          where: where,
        ),
        type: model.runtimeType);
  }

  Future<void> delete(dynamic model) async =>
      await DataManipulationService().delete(EntityInstanceService()
          .entityInstanceByValueInstance(reflect(model)));
}

extension StringFormatter on String {
  String camelCaseToSnakeCase() {
    return replaceAllMapped(RegExp(r'[A-Z]'), (match) {
      return '_${match.group(0)!.toLowerCase()}';
    });
  }

  String snakeCaseToCamelCase() {
    return replaceAllMapped(RegExp(r'_[a-z]'), (match) {
      return match.group(0)!.toUpperCase().substring(1);
    });
  }
}

extension SymbolFormatter on Symbol {
  String name() => MirrorSystem.getName(this);
}
