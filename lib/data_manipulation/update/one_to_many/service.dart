import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';
import 'package:dart_store/data_manipulation/update/service.dart';

class OneToManyUpdateService {
  Future<EntityInstance> postUpdate(EntityInstance entityInstance) async {
    for (final foreignColumnInstance in entityInstance.oneToManyColumns()) {
      final List<dynamic> values = foreignColumnInstance.value;
      final List newValues = [];
      for (final oneOfManyItems in values) {
        final EntityInstance oneOfManyItemsInstance = EntityInstanceService()
            .entityInstanceByValueInstance(oneOfManyItems);
        newValues.add(await UpdateService().update(oneOfManyItemsInstance));
      }
      entityInstance.setField(foreignColumnInstance.name, newValues);
    }

    return entityInstance;
  }
}
