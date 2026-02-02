import 'package:get_it/get_it.dart';
import '../domain/services/purchase_service.dart';
import '../domain/services/qr_export_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton<IPurchaseService>(() => PurchaseService());
  sl.registerLazySingleton<IQrExportService>(() => QrExportService());

  // Wait for initializations if necessary
  await sl<IPurchaseService>().initialize();
}
