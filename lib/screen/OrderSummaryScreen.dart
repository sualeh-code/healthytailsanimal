import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/CartModel.dart';
import 'package:mightystore/models/Coupon_lines.dart';
import 'package:mightystore/models/CreateOrderRequestModel.dart';
import 'package:mightystore/models/CustomerResponse.dart';
import 'package:mightystore/models/OrderModel.dart';
import 'package:mightystore/models/PaymentModel.dart';
import 'package:mightystore/models/ShippingMethodResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/PlaceOrderScreen.dart';
import 'package:mightystore/utils/AppBarWidget.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/colors.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/shared_pref.dart';
import 'package:nb_utils/nb_utils.dart';

// import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../app_localizations.dart';
import 'DashBoardScreen.dart';
import 'WebViewPaymentScreen.dart';

class OrderSummaryScreen extends StatefulWidget {
  static String tag = '/OrderSummaryScreen';

  final List<CartModel>? mCartProduct;
  final mCouponData;
  final mPrice;
  final bool isNativePayment = false;
  final ShippingLines? shippingLines;
  final Method? method;
  final double? subtotal;
  final double? mRPDiscount;
  final double? discount;

  OrderSummaryScreen(
      {Key? key,
      this.mCartProduct,
      this.mCouponData,
      this.mPrice,
      this.shippingLines,
      this.method,
      this.subtotal,
      this.mRPDiscount,
      this.discount})
      : super(key: key);

  @override
  OrderSummaryScreenState createState() => OrderSummaryScreenState();
}

class OrderSummaryScreenState extends State<OrderSummaryScreen> // implements
// TransactionCallBack
{
  // late NavigationController controller;
  final formKey = GlobalKey<FormState>();

  // final plugin = PaystackPlugin();
  // CheckoutMethod method = CheckoutMethod.card;

  var mOrderModel = OrderResponse();

  // late Razorpay _razorPay;
  List<PaymentClass>? paymentList = [];

  Shipping? shipping;
  Billing? billing;

  //Method? method;
  NumberFormat nf = NumberFormat('##.00');
  String? cardNumber;
  String? cvv;
  int? expiryMonth;
  int? expiryYear;

  String? mTotalBalance;

  bool isDisabled = false;
  bool isNativePayment = false;
  bool? selectedCashDelivery;

  var mUserId, mCurrency;

  var mBilling, mShipping;
  var id;
  var isEnableCoupon;

  int? paymentIndex;
  int? _currentTimeValue = 0;
  bool? isSelected = false;
  num mAmount = 0;

  @override
  void initState() {
    super.initState();
    addList();
    // _razorPay = Razorpay();
    // _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    init();
  }

  init() async {
    // plugin.initialize(publicKey: payStackPublicKey);
    selectedCashDelivery = true;
    _currentTimeValue = 0;
    paymentIndex = 0;
    setState(() {});
    fetchTotalBalance();
    if (getStringAsync(PAYMENTMETHOD) == PAYMENT_METHOD_NATIVE) {
      isNativePayment = true;
    } else {
      isNativePayment = false;
    }
    shipping = Shipping.fromJson(jsonDecode(getStringAsync(SHIPPING)));
    billing = Billing.fromJson(jsonDecode(getStringAsync(BILLING)));

    mUserId = getIntAsync(USER_ID);
    mCurrency = getStringAsync(DEFAULT_CURRENCY);
    setState(() {});
  }

  Future fetchTotalBalance() async {
    afterBuildCreated(() {
      appStore.setLoading(true);
    });
    await getBalance().then((res) {
      mTotalBalance = res;
      appStore.setLoading(false);
    }).catchError((error) {
      appStore.setLoading(false);
    });
    paymentCount();
  }

  addList() {
    //if (IS_PAY_FROM_WALLET) paymentList!.add(PaymentClass(paymentIndex: 5, paymentMethod: 'Pay From Wallet'));
    paymentList!
        .add(PaymentClass(paymentIndex: 0, paymentMethod: 'Cash On Delivery'));
    // if (IS_STRIPE) paymentList!.add(PaymentClass(paymentIndex: 1, paymentMethod: 'Stripe Payment'));
    // if (IS_RAZORPAY) paymentList!.add(PaymentClass(paymentIndex: 2, paymentMethod: 'RazorPay'));
    // if (IS_FLUTTER_WAVE) paymentList!.add(PaymentClass(paymentIndex: 3, paymentMethod: 'FlutterWave'));
    // if (IS_PAY_STACK) paymentList!.add(PaymentClass(paymentIndex: 4, paymentMethod: 'PayStack'));

    setState(() {});
  }

  void paymentCount() {
    if (widget.mPrice.toString().toDouble() <= mTotalBalance.toDouble()) {
      mAmount = mTotalBalance.toDouble();
      log("mAmount" + mAmount.toString());
    } else {
      mAmount = double.parse(widget.mPrice) - mTotalBalance.toDouble();
      log("amount" + mAmount.toString());
    }
  }

  void createNativeOrder(String mPaymethod,
      {bool isWallet = false, bool isPayment = false}) async {
    hideKeyboard(context);

    List<LineItemsRequest> lineItems = [];
    List<ShippingLines?> shippingLines = [];
    widget.mCartProduct!.forEach((item) {
      var lineItem = LineItemsRequest();
      lineItem.productId = item.proId;
      lineItem.quantity = item.quantity;
      lineItem.variationId = item.proId;
      lineItems.add(lineItem);
    });

    var couponCode = widget.mCouponData;
    List<CouponLines> mCouponItems = [];
    if (couponCode.isNotEmpty) {
      var mCoupon = CouponLines();
      mCoupon.code = couponCode;
      mCouponItems.clear();
      mCouponItems.add(mCoupon);
    }

    if (widget.shippingLines != null) {
      shippingLines.add(widget.shippingLines);
    }
    var request = {
      'billing': billing,
      'shipping': shipping,
      'line_items': lineItems,
      'payment_method': mPaymethod,
      'transaction_id': "",
      'customer_id': getIntAsync(USER_ID),
      'coupon_lines': couponCode.isNotEmpty ? mCouponItems : '',
      'status': "processing",
      'set_paid': false,
      'shipping_lines': shippingLines
    };
    appStore.setLoading(true);
    print("isWallet" + isWallet.toString());
    print("isPayment" + isPayment.toString());

    createOrderApi(request).then((response) async {
      if (!mounted) return;

      if (isWallet == true && isPayment == false) {
        var request = {
          "type": "debit",
          "amount": mAmount,
          "details": "",
        };

        await addTransaction(request).then((res) async {
          log("Done");
          appStore.setLoading(false);
          await PlaceOrderScreen(
            mOrderID: response['id'],
            total: mAmount,
            transactionId: response['transaction_id'],
            orderKey: response['order_key'],
            paymentMethod: response['payment_method'],
            dateCreated: response['date_created'],
          ).launch(context, pageRouteAnimation: PageRouteAnimation.Scale);
        }).catchError((error) {
          print("Error" + error.toString());
          toast(error.toString());
        });
      } else if (isPayment == true && isWallet == false) {
        appStore.setLoading(false);
        await PlaceOrderScreen(
          mOrderID: response['id'],
          total: widget.mPrice,
          transactionId: response['transaction_id'],
          orderKey: response['order_key'],
          paymentMethod: response['payment_method'],
          dateCreated: response['date_created'],
        ).launch(context, pageRouteAnimation: PageRouteAnimation.Scale);
      } else if (isWallet == true && isPayment == true) {
        log("both payments------------------------------->");
        var req = {
          "type": "debit",
          "amount": mTotalBalance,
          "details": "",
        };
        await addTransaction(req).then((res) async {
          log("Done");
          appStore.setLoading(false);
          await PlaceOrderScreen(
            mOrderID: response['id'],
            total: widget.mPrice,
            transactionId: response['transaction_id'],
            orderKey: response['order_key'],
            paymentMethod: response['payment_method'],
            dateCreated: response['date_created'],
          ).launch(context, pageRouteAnimation: PageRouteAnimation.Scale);
        }).catchError((error) {
          print("Error" + error.toString());
          toast(error.toString());
        });
      }
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  Future createWebViewOrder() async {
    if (!accessAllowed) {
      return;
    }

    var request = CreateOrderRequestModel();

    if (widget.shippingLines != null) {
      List<ShippingLines?> shippingLines = [];
      shippingLines.add(widget.shippingLines);
      request.shippingLines = shippingLines;
    }
    List<LineItemsRequest> lineItems = [];

    widget.mCartProduct!.forEach((item) {
      var lineItem = LineItemsRequest();
      lineItem.productId = item.proId;
      lineItem.quantity = item.quantity;
      lineItem.variationId = item.proId;
      lineItems.add(lineItem);
    });

    request.paymentMethod = "webview";
    request.transactionId = "";
    request.customerId = getIntAsync(USER_ID);
    request.status = "pending";
    request.setPaid = false;

    request.lineItems = lineItems;
    request.shipping = shipping;
    request.billing = billing;
    createOrder(request);
  }

  void createOrder(CreateOrderRequestModel mCreateOrderRequestModel) async {
    appStore.setLoading(true);
    await createOrderApi(mCreateOrderRequestModel.toJson()).then((response) {
      if (!mounted) return;
      processPaymentApi(response['id']);
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString(), print: true);
    });
  }

  processPaymentApi(var mOrderId) async {
    log(mOrderId);
    var request = {"order_id": mOrderId};
    getCheckOutUrl(request).then((res) async {
      if (!mounted) return;

      appStore.setLoading(false);
      bool isPaymentDone = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    WebViewPaymentScreen(checkoutUrl: res['checkout_url'])),
          ) ??
          false;
      if (isPaymentDone) {
        appStore.setLoading(true);
        if (!await isGuestUser()) {
          clearCartItems().then((response) {
            if (!mounted) return;

            appStore.setLoading(false);
            appStore.setCount(0);
            DashBoardScreen().launch(context, isNewTask: true);
          }).catchError((error) {
            appStore.setLoading(false);
            toast(error.toString());
          });
        } else {
          appStore.setCount(0);
          removeKey(CART_DATA);
          DashBoardScreen().launch(context, isNewTask: true);
        }
      } else {
        deleteOrder(mOrderId)
            .then((value) => {log(value)})
            .catchError((error) {});
        appStore.setCount(0);
      }
    }).catchError((error) {});
  }

  void onOrderNowClick() async {
    if (isSelected == true) {
      createNativeOrder("Cash On Delivery", isPayment: true, isWallet: true);
    } else {
      createNativeOrder("Cash On Delivery", isPayment: true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    // _razorPay.clear();
  }

  @override
  Widget build(BuildContext context) {
    // controller = NavigationController(Client(), style, this);
    var appLocalization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: mTop(context, appLocalization.translate('lbl_order_summary'),
          showBack: true) as PreferredSizeWidget?,
      body: BodyCornerWidget(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  if (shipping != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appLocalization.translate("lbl_shipping_address")!,
                                style: boldTextStyle())
                            .visible(shipping != null),
                        4.height,
                        Text(
                          "${shipping!.firstName.validate()} ${shipping!.lastName.validate()}\n${shipping!.address1.validate()}\n${shipping!.city.validate()}\n${shipping!.state.validate()}-${shipping!.country.validate()}-${shipping!.postcode.validate()}",
                          style: secondaryTextStyle(),
                        ).visible(shipping != null),
                        4.height
                      ],
                    ).paddingOnly(right: 16, left: 16),
                  // Divider(thickness: 6, color: Theme.of(context).textTheme.headline4!.color).visible(isNativePayment == true),
                  Divider(
                      thickness: 6,
                      color: Theme.of(context).textTheme.headline4!.color),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appLocalization.translate('lbl_payment_methods')!,
                              style: boldTextStyle())
                          .paddingLeft(16),
                      8.height,
                      // Row(
                      //   children: <Widget>[
                      //     Container(
                      //       width: 18,
                      //       height: 18,
                      //       padding: EdgeInsets.all(2),
                      //       decoration: boxDecorationWithRoundedCorners(
                      //         borderRadius: radius(4),
                      //         backgroundColor: context.cardColor,
                      //         border: Border.all(
                      //           color: isSelected == true ? primaryColor! : Theme.of(context).textTheme.subtitle2!.color!,
                      //         ),
                      //       ),
                      //       child: Icon(Icons.done, color: primaryColor, size: 12).visible(isSelected == true),
                      //     ),
                      //     12.width,
                      //     Expanded(
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text(
                      //             "Pay From Wallet",
                      //             style: secondaryTextStyle(size: 16, color: isSelected == true ? primaryColor : Theme.of(context).textTheme.subtitle1!.color),
                      //           ),
                      //           isSelected == true ? Text(appLocalization.translate("lbl_available_bal")! + ' $mTotalBalance', style: secondaryTextStyle()) : SizedBox(),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ).paddingOnly(left: 16, right: 16, top: 12, bottom: 12).onTap(() {
                      //   log(mTotalBalance);
                      //   if (mTotalBalance != "0.00") {
                      //     isSelected = !isSelected!;
                      //     if (widget.mPrice.toString().toDouble() <= mTotalBalance.toDouble() && isSelected == true) {
                      //       _currentTimeValue = null;
                      //     }
                      //   } else if (mTotalBalance == "0.00") {
                      //     toast(appLocalization.translate('msg_zero_bal')!);
                      //   }
                      //   setState(() {});
                      // }),
                      if (widget.mPrice.toString().toDouble() >=
                              mTotalBalance.toDouble() &&
                          isSelected == true)
                        Column(
                          children: [
                            4.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    appLocalization
                                        .translate("msg_remaining_amount")!,
                                    style: primaryTextStyle(size: 18)),
                                PriceWidget(
                                    price: mAmount.toString(),
                                    color: primaryColor,
                                    size: 16)
                              ],
                            ),
                            Divider(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .color)
                          ],
                        ).paddingOnly(left: 16, right: 16),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 12, bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: 20,
                                      height: 20,
                                      padding: EdgeInsets.all(2),
                                      decoration:
                                          boxDecorationWithRoundedCorners(
                                        borderRadius: radius(4),
                                        backgroundColor: context.cardColor,
                                        border: Border.all(
                                          color: _currentTimeValue == index
                                              ? primaryColor!
                                              : Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .color!,
                                        ),
                                      ),
                                      child: Icon(Icons.done,
                                              color: primaryColor, size: 14)
                                          .visible(_currentTimeValue == index),
                                    ),
                                    12.width,
                                    Expanded(
                                      child: Text(
                                        paymentList![index].paymentMethod!,
                                        style: secondaryTextStyle(
                                            size: 16,
                                            color: _currentTimeValue == index
                                                ? primaryColor
                                                : Theme.of(context)
                                                    .textTheme
                                                    .subtitle1!
                                                    .color),
                                      ),
                                    ),
                                  ],
                                ).onTap(
                                  () {
                                    if (widget.mPrice.toString().toDouble() >=
                                        mTotalBalance.toDouble()) {
                                      setState(() {
                                        log("value------>");
                                        _currentTimeValue = 0;
                                        _currentTimeValue = index;
                                        paymentIndex = paymentList![
                                                _currentTimeValue.validate()]
                                            .paymentIndex;
                                      });
                                    } else if (isSelected == false) {
                                      setState(() {
                                        log("value");
                                        _currentTimeValue = 0;
                                        _currentTimeValue = index;
                                        paymentIndex = paymentList![
                                                _currentTimeValue.validate()]
                                            .paymentIndex;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: paymentList!.length,
                      ),
                    ],
                  ).paddingOnly(top: 8).visible(isNativePayment == true),
                  Divider(
                      thickness: 6,
                      color: Theme.of(context).textTheme.headline4!.color),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appLocalization.translate("lbl_price_detail")!,
                          style: boldTextStyle()),
                      8.height,
                      Divider(),
                      8.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(appLocalization.translate("lbl_total_mrp")!,
                              style: secondaryTextStyle(size: 16)),
                          PriceWidget(
                              price: nf.format(widget.subtotal.validate()),
                              color:
                                  Theme.of(context).textTheme.subtitle1!.color,
                              size: 16)
                        ],
                      ),
                      4.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              appLocalization.translate("lbl_discount_on_mrp")!,
                              style: secondaryTextStyle(size: 16)),
                          Row(
                            children: [
                              Text("-",
                                  style: primaryTextStyle(color: primaryColor)),
                              PriceWidget(
                                  price: widget.mRPDiscount!.toStringAsFixed(2),
                                  color: primaryColor,
                                  size: 16),
                            ],
                          )
                        ],
                      ).paddingBottom(4).visible(widget.mRPDiscount != 0.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              appLocalization.translate('lbl_coupon_discount')!,
                              style: secondaryTextStyle(size: 16)),
                          Row(
                            children: [
                              Text("-",
                                  style: primaryTextStyle(color: primaryColor)),
                              PriceWidget(
                                price: widget.discount.validate(),
                                size: 16,
                                color: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .color,
                              ),
                            ],
                          ),
                        ],
                      ).paddingBottom(4).visible(
                          widget.discount != 0.0 && isEnableCoupon == true),
                      widget.method != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(appLocalization.translate("lbl_Shipping")!,
                                    style: secondaryTextStyle(size: 16)),
                                widget.method != null &&
                                        widget.method!.cost != null &&
                                        widget.method!.cost!.isNotEmpty
                                    ? PriceWidget(
                                        price: widget.method!.cost
                                            .toString()
                                            .validate(),
                                        color: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .color,
                                        size: 16)
                                    : Text(
                                        appLocalization.translate('lbl_free')!,
                                        style:
                                            boldTextStyle(color: Colors.green))
                              ],
                            )
                          : SizedBox(),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(appLocalization.translate('lbl_total_amount')!,
                              style: boldTextStyle(color: primaryColor)),
                          PriceWidget(
                              price: widget.mPrice,
                              size: 16,
                              color: primaryColor),
                        ],
                      ),
                    ],
                  ).paddingAll(16),
                ],
              ),
            ),
            Observer(
                builder: (context) =>
                    mProgress().center().visible(appStore.isLoading)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Theme.of(context).hoverColor.withOpacity(0.8),
                blurRadius: 15.0,
                offset: Offset(0.0, 0.75)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PriceWidget(
                    price: widget.mPrice,
                    size: 16,
                    color: Theme.of(context).textTheme.subtitle2!.color)
                .expand(),
            16.height,
            AppButton(
              text: appLocalization.translate('lbl_continue'),
              textStyle: primaryTextStyle(color: white),
              color: isHalloween ? mChristmasColor : primaryColor,
              onTap: () async {
                if (appStore.isLoading) {
                  return;
                }
                if (await isGuestUser()) {
                  toast(appLocalization.translate('lbl_guest_payment_msg'));
                } else {
                  // createWebViewOrder();
                  if (isNativePayment == false) {
                    createWebViewOrder();
                  } else {
                    log("hello");
                    if (paymentIndex == 0) {
                      log("IS_COD");
                      _cod();
                    } //
                    // else if (IS_STRIPE && paymentIndex == 1) {
                    //   log("IS_STRIPE");
                    //   _stripePayment(context);
                    // } //
                    // else if (IS_RAZORPAY && paymentIndex == 2) {
                    //   log("IS_RAZORPAY");
                    //   openCheckout();
                    // } //
                    //
                    // else if (IS_FLUTTER_WAVE && paymentIndex == 3) {
                    //   flutterWaveCheckout();
                    //   log("IS_FLUTTER_WAVE");
                    // } //
                    // else if (IS_PAY_STACK && paymentIndex == 4) {
                    //   payStackCheckOut(context);
                    //   log("IS_PAY_STACK");
                    // } //
                    // else if (IS_PAY_FROM_WALLET && isSelected == true) {
                    //   paymentCount();
                    //   log("IS_PAY_FROM_WALLET");
                    //   _wallet();
                    // }
                  }
                }
              },
            ).expand(),
          ],
        ).paddingAll(16),
      ),
    );
  }

  void checkFormWallet() {
    if (IS_PAY_FROM_WALLET && isSelected == true) {
      log("IS_PAY_FROM_WALLET");
      paymentCount();
      _wallet();
    }
  }

  // void _stripePayment(BuildContext context) async {
  //   paymentCount();
  //
  //   var request = {
  //     'apiKey': stripPaymentKey,
  //     'amount': mAmount * 100,
  //     'currency': "INR",
  //     'description': "556",
  //   };
  //   getStripeClientSecret(request).then(
  //     (res) async {
  //       await Stripe.instance.initPaymentSheet(
  //         paymentSheetParameters: SetupPaymentSheetParameters(
  //           paymentIntentClientSecret: res['client_secret'],
  //           style: ThemeMode.system,
  //           applePay: true,
  //           googlePay: true,
  //           testEnv: true,
  //           merchantCountryCode: 'IN',
  //           merchantDisplayName: 'Flutter Stripe Store Demo',
  //           customerId: '1',
  //           customerEphemeralKeySecret: res['client_secret'],
  //           setupIntentClientSecret: res['client_secret'],
  //         ),
  //       );
  //
  //       await Stripe.instance.presentPaymentSheet(parameters: PresentPaymentSheetParameters(clientSecret: res['client_secret'], confirmPayment: true)).then(
  //         (value) async {
  //           if (isSelected == true)
  //             createNativeOrder('Stripe Payment', isPayment: true, isWallet: true);
  //           else
  //             createNativeOrder('Stripe Payment', isPayment: true);
  //         },
  //       ).catchError((e) {
  //         toast("Payment Failed");
  //         log("presentPaymentSheet ${e.toString()}");
  //       });
  //     },
  //   ).catchError((e) {
  //     log("SetupPaymentSheetParameters ${e.toString()}");
  //   });
  // }

  void _cod() {
    paymentCount();
    onOrderNowClick();
  }

  void _wallet() {
    log("Total Balance" + mTotalBalance.toString());
    log("Product Price" + widget.mPrice.toString());
    log("Product Price" + mAmount.toString());

    if (widget.mPrice.toString().toDouble() <= mTotalBalance.toDouble()) {
      log("test");
      createNativeOrder("Wallet", isWallet: true);
    } else if (widget.mPrice.toString().toDouble() >=
        mTotalBalance.toDouble()) {
      toast(
          "Please select another payment method. Your balance is less compare to total");
    } else if (mTotalBalance.toDouble() == 0) {
      toast(
          "Your balance is zero. Please add money and try again otherwise choose different payment method");
    } else {
      toast("sorry");
    }
  }

  void openCheckout() async {
    paymentCount();
    var options = {
      'key': razorKey,
      'amount': mAmount * 100,
      'name': 'Healthy Tails Animal Hospital',
      'theme.color': '#4358DD',
      'description': 'Woocommerce Store',
      'image': 'https://razorpay.com/assets/razorpay-glyph.svg',
      'prefill': {'contact': billing!.phone, 'email': billing!.email},
      'external': {
        'wallets': ['paytm']
      }
    };
    //
    // try {
    //   _razorPay.open(options);
    // } catch (e) {
    //   debugPrint(e.toString());
    // }
  }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   log("Success:+$response");
  //   Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId!);
  //   if (!await isGuestUser()) {
  //     if (isSelected == true) {
  //       createNativeOrder("RazorPay", isPayment: true, isWallet: true);
  //       clearCartItems().then((response) {
  //         if (!mounted) return;
  //         appStore.setCount(0);
  //         DashBoardScreen().launch(context, isNewTask: true);
  //         setState(() {});
  //       }).catchError((error) {
  //         appStore.setLoading(false);
  //         toast(error.toString());
  //       });
  //     } else {
  //       createNativeOrder("RazorPay", isPayment: true);
  //       clearCartItems().then((response) {
  //         if (!mounted) return;
  //         appStore.setCount(0);
  //         DashBoardScreen().launch(context, isNewTask: true);
  //         setState(() {});
  //       }).catchError((error) {
  //         appStore.setLoading(false);
  //         toast(error.toString());
  //       });
  //     }
  //   } else {
  //     appStore.setCount(0);
  //     removeKey(CART_DATA);
  //     DashBoardScreen().launch(context, isNewTask: true);
  //   }
  // }
  //
  // void _handlePaymentError(PaymentFailureResponse response) {
  //   Fluttertoast.showToast(msg: "ERROR: " + response.code.toString() + " - " + response.message!);
  // }
  //
  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName!);
  // }

  // //PayStack Payment
  // void payStackCheckOut(BuildContext context) async {
  //   paymentCount();
  //   formKey.currentState?.save();
  //   Charge charge = Charge()
  //     ..amount = (mAmount.toInt() * 100) // In base currency
  //     ..email = billing!.email
  //     ..currency = mCurrency
  //     ..card = PaymentCard(number: cardNumber, cvc: cvv, expiryMonth: expiryMonth, expiryYear: expiryYear);
  //
  //   charge.reference = _getReference();
  //
  //   try {
  //     CheckoutResponse response = await plugin.checkout(context, method: method, charge: charge, fullscreen: false, logo: MyLogo());
  //     payStackUpdateStatus(response.reference, response.message);
  //     if (response.message == SUCCESS) {
  //       if (isSelected == true)
  //         createNativeOrder('Paystack', isPayment: true, isWallet: true);
  //       else
  //         createNativeOrder('Paystack', isPayment: true);
  //     } else {
  //       toast("Payment Failed");
  //     }
  //   } catch (e) {
  //     payStackShowMessage("Check console for error");
  //     rethrow;
  //   }
  // }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  void payStackUpdateStatus(String? reference, String message) {
    payStackShowMessage(message, const Duration(seconds: 7));
  }

  void payStackShowMessage(String message,
      [Duration duration = const Duration(seconds: 4)]) {
    toast(message);
    log(message);
  }

  // void flutterWaveCheckout() {
  //   paymentCount();
  //   if (isDisabled) return;
  //   _showConfirmDialog();
  // }

  // final style = FlutterwaveStyle(
  //     appBarText: "My Standard Blue",
  //     buttonColor: Color(0xffd0ebff),
  //     appBarIcon: Icon(Icons.message, color: Color(0xffd0ebff)),
  //     buttonTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
  //     appBarColor: Color(0xffd0ebff),
  //     dialogCancelTextStyle: TextStyle(color: Colors.redAccent, fontSize: 18),
  //     dialogContinueTextStyle: TextStyle(color: Colors.blue, fontSize: 18));
  //
  // void _showConfirmDialog() {
  //   FlutterwaveViewUtils.showConfirmPaymentModal(
  //     context,
  //     getStringAsync(CURRENCY_CODE),
  //     mAmount.toString(),
  //     style.getMainTextStyle(),
  //     style.getDialogBackgroundColor(),
  //     style.getDialogCancelTextStyle(),
  //     style.getDialogContinueTextStyle(),
  //     _handlePayment,
  //   );
  // }
  //
  // void _handlePayment() async {
  //   final Customer customer = Customer(
  //     name: billing!.firstName.toString() + " " + billing!.lastName.toString(),
  //     phoneNumber: billing!.phone.toString(),
  //     email: billing!.email.toString(),
  //   );
  //
  //   final request = StandardRequest(
  //     txRef: DateTime.now().millisecond.toString(),
  //     amount: mAmount.toString(),
  //     customer: customer,
  //     paymentOptions: "card, payattitude",
  //     customization: Customization(title: "Test Payment"),
  //     isTestMode: true,
  //     publicKey: flutterWavePublicKey,
  //     currency: getStringAsync(CURRENCY_CODE),
  //     redirectUrl: "https://www.google.com",
  //   );
  //
  //   try {
  //     Navigator.of(context).pop();
  //     _toggleButtonActive(false);
  //     controller.startTransaction(request);
  //     _toggleButtonActive(true);
  //   } catch (error) {
  //     _toggleButtonActive(true);
  //     _showErrorAndClose(error.toString());
  //   }
  // }

  void _toggleButtonActive(final bool shouldEnable) {
    setState(() {
      isDisabled = !shouldEnable;
    });
  }

// void _showErrorAndClose(final String errorMessage) {
//   FlutterwaveViewUtils.showToast(context, errorMessage);
// }

// @override
// onTransactionError() {
//   _showErrorAndClose("transaction error");
//   toast(errorMessage);
// }

// @override
// onCancelled() {
//   toast("Transaction Cancelled");
// }

// @override
// onTransactionSuccess(String id, String txRef) {
//   final ChargeResponse chargeResponse = ChargeResponse(status: "success", success: true, transactionId: id, txRef: txRef);
//   if (isSelected == true)
//     createNativeOrder('FlutterWave', isPayment: true, isWallet: true);
//   else
//     createNativeOrder('FlutterWave', isPayment: true);
//
//   toast("Payment Successfully");
// }
}
