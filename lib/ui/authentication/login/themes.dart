// theme_settings.dart

import 'package:flutter/material.dart';

ValueNotifier<Color> globalThemeColorNotifier =
    ValueNotifier<Color>(Colors.blue);
ValueNotifier<double> globalFontSizeNotifier = ValueNotifier<double>(16.0);
ValueNotifier<String> globalFontFamilyNotifier =
    ValueNotifier<String>('Roboto');
