import 'package:get/get.dart';
import 'package:hasan2/controllers/auth_controller.dart';
import 'package:hasan2/controllers/debt_controller.dart';
import 'package:hasan2/controllers/products_controller.dart';
import 'package:hasan2/controllers/search_controller.dart';
import 'package:hasan2/controllers/statistics_controller.dart';
import 'package:hasan2/controllers/theme_controller.dart';

import '../controllers/brands_controller.dart';

class CustomBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(BrandsController(), permanent: true);
    Get.put(ProductsController(), permanent: true);
    Get.put(StatisticsController(), permanent: true);
    Get.put(ThemeController(), permanent: true);
    Get.put(SearchController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(DebtController(), permanent: true);
  }
}
