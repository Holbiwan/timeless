import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:timeless/utils/asset_res.dart';

class SaveJobController extends GetxController implements GetxService {
  RxList jobTypes =
      ["UI/UX Designer", "Financial Planner", "UI/UX Designer"].obs;

  RxList jobTypesLogo =
      [AssetRes.airBnbLogo, AssetRes.twitterLogo, AssetRes.airBnbLogo].obs;
  // RxList jobTypesSaved = [true, true, true].obs;
  // onTapSave(index) {
  //   if (jobTypesSaved[index] == true) {
  //     jobTypesSaved.removeAt(index);
  //     jobTypesSaved.insert(index, false);
  //   } else {
  //     jobTypesSaved.removeAt(index);
  //     jobTypesSaved.insert(index, true);
  //   }
  // }

  RxInt selectedJobs2 = 0.obs;
  RxList jobs2 = [
    "All Job",
    
    "Design",
    "UX",
    'Software',
    'Database Manager',
    'Product Manager',
    'Full-Stack Developer',
    'Data Scientist',
    'Web Developers',
    'Networking',
    'Cyber Security'
  ].obs;

  onTapJobs2(int index) {
    selectedJobs2.value = index;
  }
}
