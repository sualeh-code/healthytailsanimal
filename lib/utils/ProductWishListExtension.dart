import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/screen/ProductDetail/ProductDetailScreen1.dart';
import 'package:mightystore/screen/ProductDetail/ProductDetailScreen2.dart';
import 'package:mightystore/screen/ProductDetail/ProductDetailScreen3.dart';
import 'package:mightystore/screen/SignInScreen.dart';
import 'package:mightystore/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'common.dart';
import 'constants.dart';

class ProductWishListExtension extends StatefulWidget {
  static String tag = '/ProductWishListExtension';
  final ProductResponse? mProductModel;

  ProductWishListExtension({Key? key, this.mProductModel}) : super(key: key);

  @override
  ProductWishListExtensionState createState() =>
      ProductWishListExtensionState();
}

class ProductWishListExtensionState extends State<ProductWishListExtension> {
  bool mIsInWishList = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Container(
        margin: EdgeInsets.all(6),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: isHalloween
                ? mHalloweenCard
                : Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(8)),
        child:
            wishListStore.isItemInWishlist(widget.mProductModel!.id!) == false
                ? Icon(Icons.favorite_border,
                    color: isHalloween
                        ? white
                        : Theme.of(context).textTheme.subtitle2!.color,
                    size: 16)
                : Icon(Icons.favorite, color: Colors.red, size: 16),
      )
          .visible(!widget.mProductModel!.type!.contains("grouped") &&
              !widget.mProductModel!.type!.contains("external") &&
              !widget.mProductModel!.type!.contains("variable"))
          .onTap(
        () {
          if (getBoolAsync(IS_LOGGED_IN)) {
            addItemToWishlist(data: widget.mProductModel!);
            setState(() {});
          } else
            SignInScreen().launch(context);
        },
      );
    });
  }
}

onClickProduct(BuildContext context, ProductResponse? mProductModel) async {
  var result;
  if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 1) {
    result = await ProductDetailScreen1(mProId: mProductModel!.id)
        .launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
  } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 2) {
    result = await ProductDetailScreen2(mProId: mProductModel!.id)
        .launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
  } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 3) {
    result = await ProductDetailScreen3(mProId: mProductModel!.id)
        .launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
  } else {
    result = await ProductDetailScreen1(mProId: mProductModel!.id)
        .launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
  }
/*  if (result == null) {
    mIsInWishList = mIsInWishList;
  } else {
    mIsInWishList = result;
  }*/
}
