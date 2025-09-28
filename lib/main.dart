import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_app/view/home.dart';
import 'package:todo_app/view/onboarding.dart';
import 'package:todo_app/view/splash.dart';
import 'package:todo_app/view/start.dart';

import 'config/assets.dart';

void main() {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      preLoadAsset();
    });
    super.initState();
  }

  Future<void> preLoadAsset() async {
    await precacheImage(AssetImage(Assets.splash), context);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
      ),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => Splash()),
          GetPage(name: '/onBoarding', page: () => OnBoarding()),
          GetPage(name: '/start', page: () => Start()),
          GetPage(name: '/home', page: () => Home()),
        ],
      ),
    );
  }
}

class ScaleSize {
  static double textScaleFactor(BuildContext context,
      {double maxTextScaleFactor = 2.5}) {
    final width = MediaQuery.of(context).size.width;
    double val = (width / 1400) * maxTextScaleFactor;
    return max(1, min(val, maxTextScaleFactor));
  }
}

// flutter version==>>3.24.5
