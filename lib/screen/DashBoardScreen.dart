import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../utils/common.dart';

class DashBoardScreen extends StatefulWidget {
  static String tag = '/DashBoardScreen1';

  @override
  DashBoardScreenState createState() => DashBoardScreenState();

  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static toggleDrawer() async {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openEndDrawer();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }
}

class DashBoardScreenState extends State<DashBoardScreen> {
  bool mIsLoggedIn = false;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  init() async {
    setStatusBarColor(primaryColor!);
    setState(() {
      mIsLoggedIn = getBoolAsync(IS_LOGGED_IN);
    });
    setValue(CARTCOUNT, appStore.count);
    OneSignal.shared.setNotificationOpenedHandler(
        (OSNotificationOpenedResult notification) async {
      if (notification.notification.additionalData!.containsKey('ID')) {
        String? notId = notification.notification.additionalData!["ID"];

        if (notId.validate().isNotEmpty) {
          // String heroTag = '$notId${currentTimeStamp()}';
        }
      }
    });

    window.onPlatformBrightnessChanged = () {
      if (getIntAsync(THEME_MODE_INDEX) == ThemeModeSystem) {
        appStore.setDarkMode(
            aIsDarkMode:
                MediaQuery.of(context).platformBrightness == Brightness.light);
      }
    };
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    window.onPlatformBrightnessChanged = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return Observer(
      builder: (context) => Scaffold(
        key: DashBoardScreen._scaffoldKey,
        body: Column(
          children: [
            Expanded(child: appStore.dashboardScreeList[appStore.index]),
            appStore.index == 2
                ? Container()
                : InkWell(
                    onTap: () {
                      checkLoggedIn(context);
                    },
                    child: Container(
                      color: Theme.of(context).colorScheme.background,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: Container(
                            color: primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8), // Border width
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        shape: BoxShape.circle),
                                    child: ClipOval(
                                      child: Text(appStore.count.toString(),
                                          style: primaryTextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1!
                                                  .color)),
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    'View Your Cart',
                                    style: primaryTextStyle(color: white),
                                  ),
                                  Spacer(),
                                  Text(
                                    getStringAsync(DEFAULT_CURRENCY) +
                                        cartStore.cartTotalAmount.toString(),
                                    style: primaryTextStyle(color: white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).visible(
                        appStore.count! > 0 && cartStore.cartTotalAmount > 0),
                  ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Theme.of(context).colorScheme.background,
          child: ListView(
            children: [
              ListTile(
                onTap: () {
                  appStore.setBottomNavigationIndex(0);
                  DashBoardScreen.toggleDrawer();
                },
                leading: Icon(Ionicons.ios_home_outline,
                    color: isHalloween
                        ? white.withOpacity(0.6)
                        : Theme.of(context).textTheme.subtitle1!.color),
                title: Text("Home"),
              ),
              ListTile(
                  onTap: () {
                    appStore.setBottomNavigationIndex(1);
                    DashBoardScreen.toggleDrawer();
                  },
                  leading: Icon(Ionicons.ios_grid_outline,
                      color: isHalloween
                          ? white.withOpacity(0.6)
                          : Theme.of(context).textTheme.subtitle1!.color),
                  title: Text("Categories")),
              ListTile(
                onTap: () {
                  // toast(appStore.count!.toString() + "");
                  // if (cartStore.cartTotalAmount > 0 &&
                  //     appStore.count! > 0 &&
                  //     appStore.count != null) {
                  appStore.setBottomNavigationIndex(2);
                  // }
                  // else
                  // toast("Not Product Found");

                  DashBoardScreen.toggleDrawer();
                  // appStore.setBottomNavigationIndex(2);
                  // DashBoardScreen.toggleDrawer();
                },
                leading: Stack(
                  children: <Widget>[
                    Icon(Icons.shopping_bag_outlined,
                        color: isHalloween
                            ? white.withOpacity(0.6)
                            : Theme.of(context).textTheme.subtitle1!.color),
                    cartStore.cartTotalAmount > 0 &&
                            appStore.count! > 0 &&
                            appStore.count != null
                        ? Positioned(
                            top: 2,
                            left: 10,
                            child: CircleAvatar(
                              maxRadius: 7,
                              backgroundColor: context.cardColor,
                              child: FittedBox(
                                child: Text('${appStore.count}',
                                    style: secondaryTextStyle()),
                              ),
                            ),
                          ).visible(
                            mIsLoggedIn || getBoolAsync(IS_GUEST_USER) == true)
                        : SizedBox()
                  ],
                ),
                title: Text("Basket"),
              ),
              ListTile(
                onTap: () {
                  appStore.setBottomNavigationIndex(3);
                  DashBoardScreen.toggleDrawer();
                },
                leading: Icon(Icons.favorite_outline_sharp,
                    color: isHalloween
                        ? white.withOpacity(0.6)
                        : Theme.of(context).textTheme.subtitle1!.color),
                title: Text("Favourite"),
              ),
              ListTile(
                onTap: () {
                  appStore.setBottomNavigationIndex(4);
                  DashBoardScreen.toggleDrawer();
                },
                leading: Icon(Ionicons.person_outline,
                    color: isHalloween
                        ? white.withOpacity(0.6)
                        : Theme.of(context).textTheme.subtitle1!.color),
                title: Text("Account"),
              )
            ],
          ),
          // currentIndex: appStore.index,
          // unselectedItemColor: isHalloween ? white.withOpacity(0.6) : Theme.of(context).textTheme.subtitle1!.color,
          // unselectedLabelStyle: TextStyle(color: isHalloween ? white : Theme.of(context).textTheme.subtitle1!.color),
          // selectedItemColor: isHalloween ? white : primaryColor,
          // items: [
          //   BottomNavigationBarItem(
          //       icon: Icon(Ionicons.ios_home_outline, color: isHalloween ? white.withOpacity(0.6) : Theme.of(context).textTheme.subtitle1!.color),
          //       activeIcon: Icon(Ionicons.ios_home, color: isHalloween ? white : primaryColor),
          //       label: appLocalization.translate("lbl_home")),
          //   BottomNavigationBarItem(
          //       icon: Icon(Ionicons.ios_grid_outline, color: isHalloween ? white.withOpacity(0.6) : Theme.of(context).textTheme.subtitle1!.color),
          //       activeIcon: Icon(Ionicons.ios_grid, color: isHalloween ? white : primaryColor),
          //       label: appLocalization.translate("lbl_category")),
          //   BottomNavigationBarItem(
          //     icon: Stack(
          //       children: <Widget>[
          //         Icon(Icons.shopping_bag_outlined, color: isHalloween ? white.withOpacity(0.6) : Theme.of(context).textTheme.subtitle1!.color),
          //         appStore.count! > 0 && appStore.count != null
          //             ? Positioned(
          //                 top: 2,
          //                 left: 10,
          //                 child: CircleAvatar(
          //                   maxRadius: 7,
          //                   backgroundColor: context.cardColor,
          //                   child: FittedBox(
          //                     child: Text('${appStore.count}', style: secondaryTextStyle()),
          //                   ),
          //                 ),
          //               ).visible(mIsLoggedIn || getBoolAsync(IS_GUEST_USER) == true)
          //             : SizedBox()
          //       ],
          //     ),
          //     activeIcon: Stack(
          //       children: <Widget>[
          //         Icon(MaterialIcons.shopping_bag, color: isHalloween ? white : primaryColor),
          //         if (appStore.count.toString() != "0")
          //           Positioned(
          //             top: 2,
          //             left: 10,
          //             child: Observer(
          //               builder: (_) => CircleAvatar(
          //                 maxRadius: 7,
          //                 backgroundColor: isHalloween ? mChristmasColor : primaryColor,
          //                 child: FittedBox(
          //                   child: Text(
          //                     '${appStore.count}',
          //                     style: secondaryTextStyle(color: Colors.white),
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ).visible(mIsLoggedIn || getBoolAsync(IS_GUEST_USER) == true),
          //       ],
          //     ),
          //     label: appLocalization.translate("lbl_basket"),
          //   ),
          //   BottomNavigationBarItem(
          //     icon: Icon(Icons.favorite_outline_sharp, color: isHalloween ? white.withOpacity(0.6) : Theme.of(context).textTheme.subtitle1!.color),
          //     activeIcon: Icon(MaterialIcons.favorite, color: isHalloween ? white : primaryColor),
          //     label: appLocalization.translate("lbl_favourite"),
          //   ),
          //   BottomNavigationBarItem(
          //     icon: Icon(Ionicons.person_outline, color: isHalloween ? white.withOpacity(0.6) : Theme.of(context).textTheme.subtitle1!.color),
          //     activeIcon: Icon(Ionicons.person, color: isHalloween ? white : primaryColor),
          //     label: appLocalization.translate("lbl_account"),
          //   )
          // ],
          // onTap: appStore.setBottomNavigationIndex,
        ),
      ),
    );
  }
}
