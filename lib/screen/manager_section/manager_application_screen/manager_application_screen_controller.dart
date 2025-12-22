import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/common/widgets/date_sort_filter.dart';

class ManagerApplicationScreenController extends GetxController
    implements GetxService {
  TextEditingController searchController = TextEditingController();
  RxString searchText = ''.obs;
  bool isData = false;
  List<DocumentSnapshot> documentData = [];

  // Date sorting for job posts
  Rx<DateSortOption> selectedDateSort = DateSortOption.newest.obs;

  RxInt selectedJobs2 = 0.obs;
  RxList jobs2 = [
    "All Vacancies",
    "Active",
    "Inactive",
  ].obs;

  /*search(String value)async{
   var d=  await FirebaseFirestore.instance.collection('allPost').get();

   d.docs.forEach((element) {
     element.get("CompanyName").toString()
         .toLowerCase()
         .contains(value.toLowerCase());
   });
  }*/

  onTapJobs2(int index) {
    selectedJobs2.value = index;
    update(["status"]);
  }

  // Update date sorting
  void updateDateSort(DateSortOption sortOption) {
    selectedDateSort.value = sortOption;
    update(["search", "status"]);
    DateSortHelper.showSortingFeedback(sortOption);
    if (kDebugMode)
      print('Selected date sort for job posts: ${sortOption.label}');
  }

  // Refresh job postings data
  Future<void> refreshData() async {
    try {
      if (kDebugMode) {
        print('🔄 Refreshing Manager Applications screen...');
      }

      // Clear search to refresh all data
      searchController.clear();
      searchText.value = '';

      // Reset to show all vacancies
      selectedJobs2.value = 0;

      // Reset date sort to newest
      selectedDateSort.value = DateSortOption.newest;

      // Reset data state
      isData = false;
      documentData.clear();

      // Update UI to trigger StreamBuilder refresh
      update(["search"]);
      update(["status"]);

      if (kDebugMode) {
        print('✅ Manager Applications screen refreshed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing Manager Applications screen: $e');
      }
    }
  }
}
