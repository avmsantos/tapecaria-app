import 'package:get/get.dart';

import '../data/repositories/admin_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/funcionario_repository.dart';
import '../modules/auth/auth_controller.dart';
import 'api_client.dart';
import 'storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final api = ApiClient(Get.find<StorageService>());
    Get.put<ApiClient>(api, permanent: true);

    Get.put<AuthRepository>(AuthRepository(api), permanent: true);
    Get.put<FuncionarioRepository>(FuncionarioRepository(api), permanent: true);
    Get.put<AdminRepository>(AdminRepository(api), permanent: true);

    Get.put<AuthController>(
      AuthController(Get.find<AuthRepository>(), Get.find<StorageService>(), api),
      permanent: true,
    );
  }
}
