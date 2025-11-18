import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:timeless/screen/job_recomandation_search/job_recomadation_search.dart';

class SearchJobController extends GetxController{
  TextEditingController searchJobControllerNew = TextEditingController();

  String location = "";
  String skills = "";
  String skillError = "";
  String locationError = "";

  skillsValidation() {
    // ignore: unnecessary_null_comparison
    if (skills == null || skills == "") {
      skillError = "Please Enter Designation,Companies";
      update(['popup']);
    } else {
      skillError = "";
      update(['popup']);
    }
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

  searchJob() {
    skillsValidation();
    locationValidation();

    if (skillError == "" && locationError == "") {
      Get.to(() => JobRecomandationSearch());
    }
    update(['popup']);
  }

}