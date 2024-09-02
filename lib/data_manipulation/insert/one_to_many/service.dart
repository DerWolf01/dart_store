import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';
import 'package:dart_store/data_manipulation/insert/service.dart';

class OneToManyInsertService {
  Future<EntityInstance> postInsert(EntityInstance entityInstance) async {
    for (final foreignColumnInstance in entityInstance.oneToManyColumns()) {
      final List<dynamic> values = foreignColumnInstance.value;
      final List newValues = [];
      for (final oneOfManyItems in values) {
        final EntityInstance oneOfManyItemsInstance = EntityInstanceService()
            .entityInstanceByValueInstance(oneOfManyItems);
        newValues.add(await InsertService().insert(oneOfManyItemsInstance));
      }
      entityInstance.setField(foreignColumnInstance.name, newValues);
    }

    return entityInstance;
  }
}
