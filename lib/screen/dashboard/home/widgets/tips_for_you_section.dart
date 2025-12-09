import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/asset_res.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';

Widget tipsForYouSection() {
  return Column(
    children: [
      const SizedBox(height: 27),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Text(
              Strings.tipsForYou,
              style: appTextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: ColorRes.textPrimary,
              ),
            ),
            const Spacer(),
            // Text(Strings.seeAll,
            //     style: appTextStyle(
            //         fontSize: 14,
            //         fontWeight: FontWeight.w500,
            //         color: ColorRes.containerColor))

            // Text("See all",style: GoogleFonts.poppins(fontSize: ),)
          ],
        ),
      ),
      const SizedBox(height: 18),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        height: 150,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          color: const Color(0xFF000647),
          border: Border.all(
            color: const Color(0xFF000647),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
                offset: const Offset(6, 6),
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 10),
            BoxShadow(
                offset: const Offset(0, 7),
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 20),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.howToFindAPerfectJob,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 32,
                      width: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: ColorRes.white,
                          border: Border.all(color: const Color(0xFF000647), width: 1.5),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Text(
                        Strings.readMore,
                        style: appTextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 120,
              width: 80,
              margin: const EdgeInsets.only(right: 10, top: 15, bottom: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  AssetRes.girlImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 27),
    ],
  );
}
