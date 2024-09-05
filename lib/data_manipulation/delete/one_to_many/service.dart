import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';
import 'package:dart_store/data_manipulation/delete/service.dart';

class OneToManyDeleteService {
  Future<void> preDelete(EntityInstance entityInstance) async {
    for (final foreignColumnInstance
        in entityInstance.oneToManyColumnsInstances()) {
      final List<dynamic> values = foreignColumnInstance.value;

      for (final oneOfManyItems in values) {
        final EntityInstance oneOfManyItemsInstance = EntityInstanceService()
            .entityInstanceByValueInstance(oneOfManyItems);
        if (!foreignColumnInstance.mapId) {
          await DeleteService().delete(oneOfManyItemsInstance);
        }
      }
    }
  }
}
