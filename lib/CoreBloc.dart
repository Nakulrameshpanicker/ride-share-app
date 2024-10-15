import 'package:flutter_projects/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/UserModel.dart';

class CoreBloc {
  Future<bool> initSharedData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    //settings default values

    if (sharedPreferences.containsKey(AppConstants.USERMODEL_STRING)) {
      AppConstants.loggedUser = userModelFromJson(sharedPreferences
          .getString(AppConstants.USERMODEL_STRING)
          .toString());
    }
    return Future.value(true);
  }
}
