import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/screen/DashBoardScreen.dart';
import 'package:mightystore/screen/ProductDetail/ProductDetailScreen1.dart';
import 'package:mightystore/utils/colors.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'ChristmasWalkThroughScreen.dart';

class ChristmasSplashScreen extends StatefulWidget {
  static String tag = '/HalloweenSplashScreen';

  @override
  ChristmasSplashScreenState createState() => ChristmasSplashScreenState();
}

class ChristmasSplashScreenState extends State<ChristmasSplashScreen> {
  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    setStatusBarColor(transparentColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark);
    await Future.delayed(Duration(seconds: 2));

    String productId = await getProductIdFromNative();
    print(productId);

    if (productId.isNotEmpty) {
      ProductDetailScreen1(mProId: productId.toInt()).launch(context);
    } else {
      checkFirstSeen();
    }
  }

  Future checkFirstSeen() async {
    bool _seen = (getBoolAsync('seen'));
    if (_seen) {
      DashBoardScreen().launch(context, isNewTask: true);
    } else {
      await setValue('seen', true);
      ChristmasWalkThroughScreen().launch(context, isNewTask: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              right: 0,
              child:
                  Image.asset(ic_christmas_bg, fit: BoxFit.cover, height: 400)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Merry Christmas",
                style: boldTextStyle(
                    color: mChristmasColor,
                    size: 44,
                    letterSpacing: 2,
                    fontFamily: GoogleFonts.pacifico().fontFamily),
              ),
              Text(
                appLocalization.translate('app_name')!,
                style: boldTextStyle(
                    color: mChristmasColor,
                    size: 44,
                    letterSpacing: 2,
                    fontFamily: GoogleFonts.pacifico().fontFamily),
              ),
            ],
          ).center(),
          Positioned(
              bottom: 10,
              right: 0,
              child: Image.asset(ic_christmas_santa,
                  height: 250, fit: BoxFit.cover))
        ],
      ),
    );
  }
}
