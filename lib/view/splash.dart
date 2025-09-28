import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/assets.dart';
import '../config/constatnt.dart';
import '../config/global_widget.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('asset/img/app_logo.png'), context);
    Future.delayed(
      Duration(seconds: 3),
      () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool? openFirst = prefs.getBool('openFirst') ?? false;
        if (openFirst) {
          Get.offAndToNamed('/home');
        } else {
          Get.offAndToNamed('/onBoarding');
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.appLogo,
              height: 10.heightBox(),
              width: 30.widthBox(),
              fit: BoxFit.contain,
              // color: AppColors.primaryColor,
            ),
            10.height,
            Text(
              "UpTodo",
              style: commonStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
