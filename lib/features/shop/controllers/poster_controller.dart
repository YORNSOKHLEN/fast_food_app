import 'package:get/get.dart';
import '../../../data/repositories/posters/poster_repository.dart';
import '../models/poster_model.dart';

class PosterController extends GetxController {
  static PosterController get instance => Get.find();

  final isLoading = false.obs;
  final RxList<PosterModel> posters = <PosterModel>[].obs;
  final carouselCurrentIndex = 0.obs;

  final posterRepository = Get.put(PosterRepository());

  @override
  void onInit() {
    fetchPosters();
    super.onInit();
  }

  Future<void> fetchPosters() async {
    try {
      isLoading.value = true;
      final result = await posterRepository.fetchPosters();
      posters.assignAll(result);
    } catch (e) {
      print('Error fetching posters: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updatePageIndicator(int index) {
    carouselCurrentIndex.value = index;
  }
}

