import 'package:dart_store/data_manipulation/delete/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/insert/conflict.dart';
import 'package:dart_store/data_manipulation/insert/service.dart';
import 'package:dart_store/data_manipulation/update/service.dart';
import 'package:dart_store/where/statement.dart';

class DataManipulationService {
  Future<EntityInstance> update(EntityInstance entityInstance,
          {List<Where> where = const []}) async =>
      await UpdateService().update(entityInstance, where: where);

  Future<EntityInstance> insert(
          {required EntityInstance entityInstance,
          ConflictAlgorithm conflictAlgorithm =
              ConflictAlgorithm.replace}) async =>
      await InsertService()
          .insert(entityInstance, conflictAlgorithm: conflictAlgorithm);

  Future<void> delete(
    EntityInstance entityInstance,
  ) async =>
      DeleteService().delete(entityInstance);
}
