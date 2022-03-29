import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/CartModel.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/models/WishListResponse.dart';
import 'package:mightystore/screen/SignInScreen.dart';
import 'package:mightystore/screen/WebViewExternalProductScreen.dart';
import 'package:mightystore/utils/ProductWishListExtension.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class Dashboard1ProductComponent extends StatefulWidget {
  static String tag = '/Product';
  final double? width;
  final ProductResponse? mProductModel;

  Dashboard1ProductComponent({Key? key, this.width, this.mProductModel})
      : super(key: key);

  @override
  Dashboard1ProductComponentState createState() =>
      Dashboard1ProductComponentState();
}

class Dashboard1ProductComponentState
    extends State<Dashboard1ProductComponent> {
  bool mIsInWishList = false;

  bool isCard = false;

  var j = 0;

  void refresh() {
    j = 0;
    if (isCard)
      Timer.periodic(Duration(seconds: 3), (_) {
        if (isCard && j < 10) {
          j++;
          print("setState");
          // this code runs after every 5 second. Good to use for Stopwatches
          setState(() {});
        }
      });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    var productWidth = MediaQuery.of(context).size.width;

    String? img = widget.mProductModel!.images!.isNotEmpty
        ? widget.mProductModel!.images!.first.src
        : '';

    return GestureDetector(
      onTap: () async {
        setState(() {
          onClickProduct(context, widget.mProductModel!);
        });
      },
      child: Container(
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(8.0),
                  backgroundColor: Theme.of(context).colorScheme.background),
              child: Stack(
                children: [
                  commonCacheImageWidget(img.validate(),
                          height: 170, width: productWidth, fit: BoxFit.cover)
                      .cornerRadiusWithClipRRect(8),
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: InkWell(
                      onTap: () {
                        if (widget.mProductModel!.inStock == true) {
                          if (widget.mProductModel!.type == 'external') {
                            WebViewExternalProductScreen(
                                    mExternal_URL:
                                        widget.mProductModel!.externalUrl,
                                    title: appLocalization
                                        .translate('lbl_external_product'))
                                .launch(context);
                          } else if (!getBoolAsync(IS_LOGGED_IN)) {
                            SignInScreen().launch(context,
                                pageRouteAnimation: PageRouteAnimation.Slide);
                          } else {
                            // appStore.setLoading(true);
                            addCart(data: null, datum: widget.mProductModel);
                            isCard = true;
                            print("popp");
                            if (cartStore.isItemInCart(
                                widget.mProductModel!.id.validate())) {
                              // refresh();
                              // cartStore.ca
                              for (int i = 0;
                                  i < cartStore.cartList.length;
                                  i++) {
                                CartModel model = cartStore.cartList[i];
                                if (model.cartId == widget.mProductModel!.id) {
                                  cartStore.addToMyCart(model).then((value) {
                                    setState(() {});
                                  });
                                  log("data" + model.quantity);
                                  return;
                                }
                              }

                              // setState(() {});
                            } else {
                              setState(() {});
                            }
                          }
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(4),
                        padding: EdgeInsets.all(4), // Border width
                        decoration: BoxDecoration(
                            color: widget.mProductModel!.inStock == false
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle),
                        child: ClipOval(
                          child: Icon(
                            cartStore.isItemInCart(
                                    widget.mProductModel!.id.validate())
                                ? Icons.remove
                                : Icons.add,
                            // color: !cartStore.isItemInCart(
                            //         widget.mProductModel!.id.validate())
                            //     ? Colors.green
                            //     : Colors.black
                            color: white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  mSale(widget.mProductModel!),
                  Positioned(
                      top: 1,
                      right: 1,
                      child: ProductWishListExtension(
                          mProductModel: widget.mProductModel)),
                ],
              ),
            ),
            2.height,
            Text(widget.mProductModel!.name,
                style: primaryTextStyle(), maxLines: 1),
            Text(
                    parseHtmlString(
                        widget.mProductModel!.shortDescription!.isNotEmpty
                            ? widget.mProductModel!.shortDescription
                            : ''),
                    style: secondaryTextStyle(size: 12),
                    maxLines: 1)
                .visible(widget.mProductModel!.shortDescription!.isNotEmpty)
                .paddingTop(2),
            2.height,
            Row(
              children: [
                PriceWidget(
                  price: widget.mProductModel!.onSale == true
                      ? widget.mProductModel!.salePrice.validate().isNotEmpty
                          ? double.parse(
                                  widget.mProductModel!.salePrice.toString())
                              .toStringAsFixed(2)
                          : double.parse(widget.mProductModel!.price.validate())
                              .toStringAsFixed(2)
                      : widget.mProductModel!.regularPrice!.isNotEmpty
                          ? double.parse(widget.mProductModel!.regularPrice
                                  .validate()
                                  .toString())
                              .toStringAsFixed(2)
                          : double.parse(widget.mProductModel!.price
                                  .validate()
                                  .toString())
                              .toStringAsFixed(2),
                  size: 14,
                  color: primaryColor,
                ),
                4.width,
                PriceWidget(
                        price: widget.mProductModel!.regularPrice
                            .validate()
                            .toString(),
                        size: 12,
                        isLineThroughEnabled: true,
                        color: Theme.of(context).textTheme.subtitle1!.color)
                    .visible(
                        widget.mProductModel!.salePrice.validate().isNotEmpty &&
                            widget.mProductModel!.onSale == true),
              ],
            )
                .visible(!widget.mProductModel!.type!.contains("grouped") &&
                    !widget.mProductModel!.type!.contains("variable"))
                .paddingOnly(bottom: 8),
          ],
        ),
      ),
    );
  }

  Future<void> addToCart(
      {ProductResponse? data, WishListResponse? mData}) async {
    CartModel mCartModel = CartModel();
    if (data != null) {
      var proID = data.id;
      log("proID$proID");
      List<String?> mList = [];
      data.images.forEachIndexed((element, index) {
        mList.add(element.src);
      });

      mCartModel.name = data.name;
      mCartModel.proId = proID.toString().isEmptyOrNull ? data.id : proID;
      mCartModel.onSale = data.onSale;
      mCartModel.salePrice = data.salePrice;
      mCartModel.regularPrice = data.regularPrice;
      mCartModel.price = data.price;
      mCartModel.gallery = mList;

      mCartModel.stockQuantity = "1";
      mCartModel.stockStatus = "";
      mCartModel.thumbnail = "";
      mCartModel.full = data.images![0].src;
      mCartModel.cartId = data.id;
      mCartModel.sku = "";
      mCartModel.createdAt = "";

      if (cartStore.isItemInCart(data.id.validate())) {
        cartStore.removeFromCartList(mCartModel);
        appStore.decrement(qty: 1);
      } else {
        mCartModel.quantity = "1";
        cartStore.addToMyCart(mCartModel);
        appStore.increment();
      }
    }
/*
  var proID = mData!.proId;
    log("proID$proID");
    List<String?> mList = [];
    mData.gallery.forEachIndexed((element, index) {
      mList.add(element);
    });

    mCartModel.name = mData.name;
    mCartModel.proId = proID.toString().isEmptyOrNull ? mData.proId : proID;
    mCartModel.onSale = mData.salePrice;
    mCartModel.salePrice = mData.salePrice;
    mCartModel.regularPrice = mData.regularPrice;
    mCartModel.price = mData.price;
    mCartModel.gallery = mList;
    mCartModel.quantity = "1";
    mCartModel.stockQuantity = "1";
    mCartModel.stockStatus = "";
    mCartModel.thumbnail = "";
    mCartModel.full = mData.gallery;
    mCartModel.cartId = mData.proId;
    mCartModel.sku = "";
    mCartModel.createdAt = "";
    if (cartStore.isItemInCart(mData.proId.validate())) {
      appStore.decrement();
      cartStore.addToMyCart(mCartModel);
    } else {
      appStore.increment();
      cartStore.addToMyCart(mCartModel);
    }
  }*/
  }
}
