import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/job_recommendation_screen/job_recommendation_controller.dart';
import 'package:timeless/service/pref_services.dart';
import 'package:timeless/utils/pref_keys.dart';

JobRecommendationController jcon = Get.put(JobRecommendationController());

class HomeController extends GetxController implements GetxService {
  TextEditingController searchNewController = TextEditingController();

  RxBool isBookMark = false.obs;

  /*RxList jobTypes = [
    "UI/UX Designer",
    "Financial planner",
    "UI/UX Designer",
    "Financial planner",
    "UI/UX Designer"
  ].obs;*/
  RxList jobTypesSaved = List.generate(2, (index) => false).obs;

/*  RxList jobTypesLogo = [
    AssetRes.airBnbLogo,
    AssetRes.twitterLogo,
    AssetRes.airBnbLogo,
    AssetRes.twitterLogo,
    AssetRes.airBnbLogo
  ].obs;*/
  String location = "";
  String locationError = "";
  String skills = "";
  String skillError = "";
  @override
  void onInit() {
    super.onInit();
    getfirstName();
    jobTypesSaved = List.generate(jcon.documents.length, (index) => false).obs;
  }

  onTapSave(index, field, docId) {
    if (jobTypesSaved[index] == true) {
      //   jobTypesSaved[index] = false;

      //  FirebaseFirestore.instance.collection("BookMark").doc(docId).delete();
    } else {
      jobTypesSaved[index] = true;

      Map<String, dynamic> map = {
        "Position": field['Position'],
        "CompanyName": field['CompanyName'],
        "salary": field['salary'],
        "location": field['location'],
        "type": field['type'],
        "imageUrl": field['imageUrl'],
      };

      List bookmark = [];
      bookmark = field['BookMarkUserList'];
      if (bookmark.isEmpty) {
        bookmark.add(PrefService.getString(PrefKeys.userId));
      }
      for (int i = 0; i < bookmark.length; i++) {
        if (bookmark[i] != PrefService.getString(PrefKeys.userId)) {
          bookmark.add(PrefService.getString(PrefKeys.userId));
        }
      }
      List<String> bookmarkList = List.generate(bookmark.length, (index) {
        return bookmark[index].toString();
      });
      Map<String, dynamic> map2 = {
        "BookMarkUserList": bookmarkList,
      };

      FirebaseFirestore.instance.collection('allPost').doc(docId).update(map2);

      // ignore: avoid_single_cascade_in_expression_statements
      FirebaseFirestore.instance
          .collection('BookMark')
          .doc(PrefService.getString(PrefKeys.userId))
          .collection("BookMark1")
        ..doc().set(map);
    }
  }

  RxInt selectedJobs2 = 0.obs;
  RxList jobs2 = [
    'All Job',
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
    //update(["hList"]);
  }

  String? firstNAme;

  getfirstName() async {
    firstNAme = PrefService.getString(PrefKeys.firstnameu);
  }

  locationValidation() {
    // ignore: unnecessary_null_comparison
    if (location == null || location == "") {
      locationError = "Please Enter Location";
      update(['popup']);
    } else {
      locationError = "";
      update(['popup']);
    }
  }
}
