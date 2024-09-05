import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';
import 'package:dart_store/data_manipulation/update/service.dart';

class OneToManyUpdateService {
  Future<EntityInstance> postUpdate(EntityInstance entityInstance) async {
    for (final foreignColumnInstance
        in entityInstance.oneToManyColumnsInstances()) {
      if (foreignColumnInstance.mapId) {
        continue;
      }
      final List<EntityInstance> values = foreignColumnInstance.value;
      final List newValues = [];
      for (final oneOfManyItems in values) {
        newValues.add(await UpdateService().update(oneOfManyItems));
        continue;
      }

      entityInstance.setField(foreignColumnInstance.sqlName, newValues);
    }

    return entityInstance;
  }
}
