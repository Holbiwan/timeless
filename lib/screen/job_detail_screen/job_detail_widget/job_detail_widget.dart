import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';

Widget detailBox(text, values) {
  return Container(
    // height: 50,
    width: Get.width,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.8),
      border: Border.all(color: Colors.grey.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(13),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: ColorRes.appleGreen,
          size: 30,
        ),
        const SizedBox(
          width: 20,
        ),
        SizedBox(
          width: Get.width * 0.57,
          child: Text(
            text,
            style: appTextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
     /*   PopupMenuButton(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topLeft: Radius.circular(20))),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,height: 18,
              child: Container(
                height: 18,
                width: 116,
                child: Row(
                  children: const [
                    Icon(
                      Icons.edit,
                      color: ColorRes.containerColor,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("edit")
                  ],
                ),
              ),
            ),
            PopupMenuItem(height: 1,
                child: Container(
              height: 1,
              width: 116,
                  color: Colors.grey,
            )),
            PopupMenuItem(
              value: 2,height: 18,
              child: Container(
                height: 18,
                width: 116,
                child: Row(
                  children: const [
                    Icon(
                      Icons.delete,
                      color: ColorRes.starColor,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("remove")
                  ],
                ),
              ),
            ),
          ],
          offset: const Offset(0, 50),
          color: Colors.white,
          elevation: 1,
        ),*/
      ],
    ),
  );
}
