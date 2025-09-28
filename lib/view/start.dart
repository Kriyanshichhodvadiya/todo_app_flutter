import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/assets.dart';
import '../config/colors.dart';
import '../config/constatnt.dart';
import '../config/global_widget.dart';

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          20.height,
          Text("Welcome to UpTodo",
              style: commonStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          20.height,
          // Text(
          //   'Please login to your account or create\nnew account to continue',
          //   style: Constant.myStyle(),
          //   textAlign: TextAlign.center,
          // ),
          // 40.height,
          Image.asset(
            Assets.start,
            height: 25.heightBox(),
            width: 60.widthBox(),
            fit: BoxFit.cover,
          ),
          40.height,
          Text(
            "What do you want to do Today?",
            style: commonStyle(fontSize: 20),
          ),
          Text("Tap Button to add your tasks",
              style: commonStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.w400,
              )),
          100.height,
          Padding(
            padding: 20.horizontal,
            child: ElevatedButton(
              onPressed: () {
                Get.offAll('home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'GET STARTED',
                style: commonStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
