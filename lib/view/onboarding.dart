import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/config/global_widget.dart';

import '../config/colors.dart';
import '../config/constatnt.dart';
import '../controller/onboarding_contr.dart';

class OnBoarding extends StatelessWidget {
  OnBoardingController controller = Get.put(OnBoardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: PageView.builder(
              itemCount: controller.pages.length,
              controller: controller.pageController,
              onPageChanged: (int page) {
                controller.selectedIndex.value = page;
              },
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    10.height,
                    Image.asset(
                      controller.pages[index]['img']!,
                      height: 40.heightBox(),
                      width: 50.widthBox(),
                      fit: BoxFit.contain,
                      // color: AppColors.primaryColor.withOpacity(0.5),
                    ),
                    10.height,
                    Text(
                      controller.pages[index]['text_1']!,
                      style: commonStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    30.height,
                    Text(
                      controller.pages[index]['text_2']!,
                      textAlign: TextAlign.center,
                      style: commonStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildPageIndicator(),
          ),
          Spacer(),
          // Buttons
          Padding(
            padding:20.symmetric,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    await controller.skipOnBoarding();
                  },
                  child: Text(
                    "SKIP",
                    style: commonStyle(color: Colors.grey),
                  ),
                ),
                primaryBtn(
                  onPressed: () {
                    controller.nextPage();
                  },
                  label: 'NEXT',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    return List.generate(
      controller.pages.length,
      (index) => Obx(() => Container(
        margin: 4.horizontal,
        height: 0.6.heightBox(),
        width: controller.selectedIndex.value == index ? 10.widthBox() : 5.widthBox(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: controller.selectedIndex.value == index ? Colors.black : AppColors.indicatorColor,
        ),
      )


        ),
    );
  }
}
