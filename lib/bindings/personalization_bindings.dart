import 'package:get/get.dart';
import 'package:fast_food/features/personalization/controllers/user_controller.dart';
import 'package:fast_food/features/personalization/controllers/notification_controller.dart';
import 'package:fast_food/features/personalization/controllers/account_privacy_controller.dart';
import 'package:fast_food/features/personalization/controllers/update_name_controller.dart';
import 'package:fast_food/features/personalization/controllers/upload_product_controller.dart';
import 'package:fast_food/features/personalization/controllers/upload_poster_controller.dart';
import 'package:fast_food/features/personalization/controllers/coupon_list_controller.dart';
import 'package:fast_food/features/personalization/controllers/create_coupon_controller.dart';
import 'package:fast_food/features/personalization/controllers/edit_profile_field_controller.dart';

class PersonalizationBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
    Get.lazyPut<AccountPrivacyController>(() => AccountPrivacyController(), fenix: true);
    Get.lazyPut<UpdateNameController>(() => UpdateNameController(), fenix: true);
    Get.lazyPut<UploadProductController>(() => UploadProductController(), fenix: true);
    Get.lazyPut<UploadPosterController>(() => UploadPosterController(), fenix: true);
    Get.lazyPut<CouponListController>(() => CouponListController(), fenix: true);
    Get.lazyPut<CreateCouponController>(() => CreateCouponController(), fenix: true);
    Get.lazyPut<EditProfileFieldController>(
      () => EditProfileFieldController(
        title: '',
        label: '',
        fieldKey: '',
        initialValue: '',
      ),
      fenix: true,
    );
  }
}

