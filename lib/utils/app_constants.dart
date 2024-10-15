import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/UserModel.dart';
import 'colour_resources.dart';

class AppConstants {
  static const String APP_NAME = '';
  static const String COMPANY_NAME = '';
  static String? appLanguageCode;
  static String? dialcode = "+91 ";

  static const String fontFamilyName = 'Euclid Circular B';
  static UserModel? loggedUser;
  static bool? welcomeScreen = true;

  static String fcmToken = '';
  //shared key
  static const String USERMODEL_STRING = 'usermodel';
  static const String WELCOME_SCREEN = "welcomeScreen";
  static const String FCM_TOKEN = 'fcmToken';

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void showSnackError(BuildContext context, String string) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: ColorResources.red,
      duration: const Duration(seconds: 3),
      content: Text(
        string,
        textAlign: TextAlign.start,
        maxLines: 2,
      ),
    ));
  }

  static void showSnackSuccess(BuildContext context, String string) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: ColorResources.green,
      duration: const Duration(seconds: 3),
      content: Text(
        string,
        textAlign: TextAlign.start,
        maxLines: 2,
      ),
    ));
  }

  static showLoadingPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),

                Text("Loading"),
                SizedBox(
                  height: 10.0,
                ),
                // Text("Address details"),
                // SizedBox(
                //   height: 32,
                // ),
              ],
            ),
          );
        });
  }
}
