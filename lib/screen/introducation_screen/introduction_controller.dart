import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class IntroductionController extends GetxController implements GetxService {
  RxInt selectedIndex = 0.obs;

  onChangeInd(index) {
    if (kDebugMode) {
      print(index);
    }
    selectedIndex.value = index;
  }
}
