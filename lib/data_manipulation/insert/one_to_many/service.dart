import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/insert/service.dart';

class OneToManyInsertService {
  Future<EntityInstance> postInsert(EntityInstance entityInstance) async {
    for (final foreignColumnInstance
        in entityInstance.oneToManyColumnsInstances()) {
      print("OneToManyInsertService.postInsert: ${foreignColumnInstance.name}");
      final List<dynamic> values = foreignColumnInstance.value;
      final List<EntityInstance> newValues = [];
      for (final oneOfManyItems in values) {
        newValues.add(await InsertService().insert(oneOfManyItems));
      }
      entityInstance.setField(foreignColumnInstance.name, newValues);
    }

    return entityInstance;
  }
}
