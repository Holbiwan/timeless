import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_style.dart';

Widget detailBox(text, values) {
  return Container(
    width: Get.width,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFF000647), width: 2),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF000647).withOpacity(0.1),
          spreadRadius: 0,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF000647),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: appTextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
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
