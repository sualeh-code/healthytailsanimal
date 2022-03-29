import 'package:nb_utils/nb_utils.dart';

const mOneSignalAPPKey = 'ONE_SIGNAL_KEY';

const AppName = 'Healthy Tails Animal Hospital';

/// SharedPreferences Keys
const IS_LOGGED_IN = 'IS_LOGGED_IN';
const IS_SOCIAL_LOGIN = 'IS_SOCIAL_LOGIN';
const IS_GUEST_USER = 'IS_GUEST_USER';
const THEME_COLOR = 'THEME_COLOR';
const DASHBOARD_DATA = 'DASHBOARD_DATA';
const SLIDER_DATA = 'SLIDER_DATA';
const CROSS_AXIS_COUNT = 'CROSS_AXIS_COUNT';
const CATEGORY_CROSS_AXIS_COUNT = 'CATEGORY_CROSS_AXIS_COUNT';
const msg = 'message';
const CART_DATA = 'CART_DATA';
const WISH_LIST_DATA = 'WISH_LIST_DATA';
const GUEST_USER_DATA = 'GUEST_USER_DATA';
const TOKEN = 'TOKEN';
const USERNAME = 'USERNAME';
const FIRST_NAME = 'FIRST_NAME';
const LAST_NAME = 'LAST_NAME';
const USER_DISPLAY_NAME = 'USER_DISPLAY_NAME';
const USER_ID = 'USER_ID';
const USER_EMAIL = 'USER_EMAIL';
const USER_ROLE = 'USER_ROLE';
const AVATAR = 'AVATAR';
const PASSWORD = 'PASSWORD';
const PROFILE_IMAGE = 'PROFILE_IMAGE';
const BILLING = 'BILLING';
const SHIPPING = 'SHIPPING';
const COUNTRIES = 'COUNTRIES';
const LANGUAGE = 'LANGUAGE';
const CARTCOUNT = 'CARTCOUNT';
const WHATSAPP = 'WHATSAPP';
const FACEBOOK = 'FACEBOOK';
const TWITTER = 'TWITTER';
const INSTAGRAM = 'INSTAGRAM';
const CONTACT = 'CONTACT';
const PRIVACY_POLICY = 'PRIVACY_POLICY';
const TERMS_AND_CONDITIONS = 'TERMS_AND_CONDITIONS';
const COPYRIGHT_TEXT = 'COPYRIGHT_TEXT';
const PAYMENTMETHOD = 'PAYMENTMETHOD';
const ENABLECOUPON = 'ENABLECOUPON';
const PAYMENT_METHOD_NATIVE = "native";
const DEFAULT_CURRENCY = 'DEFAULT_CURRENCY';
const CURRENCY_CODE = 'CURRENCY_CODE';
const IS_NOTIFICATION_ON = "IS_NOTIFICATION_ON";
const DETAIL_PAGE_VARIANT = 'DetailPageVariant';
const IS_REMEMBERED = "IS_REMEMBERED";
const IS_DOKAN_ACTIVE = 'IS_DOKAN_ACTIVE';
const PLAYER_ID = 'PLAYER_ID';
const WALLET = 'WALLET';

//Start AppSetup
const APP_NAME = 'appName';
const PRIMARY_COLOR = 'primaryColor';
const SECONDARY_COLOR = 'secondaryColor';
const TEXT_PRIMARY_COLOR = 'textPrimaryColor';
const TEXT_SECONDARY_COLOR = 'textSecondaryColor';
const BACKGROUND_COLOR = 'backgroundColor';
const CONSUMER_KEY = 'consumerKey';
const CONSUMER_SECRET = 'consumerSecret';
const APP_URL = 'appUrl';
//End AppSetup

//Date Format
const orderDateFormat = 'dd-MM-yyyy';
const reviewDateFormat = 'dd MMM yy  hh:mm a';
const CreateDateFormat = 'MMM dd, yyyy';

const accessAllowed = true;
const demoPurposeMsg = 'This action is not allowed in demo app.';

const COMPLETED = "completed";
const REFUNDED = "refunded";
const CANCELED = "cancelled";
const TRASH = "trash";
const FAILED = "failed";
const SUCCESS = 'Success';

const min_price = 0.0;
const max_price = 20000.0;

/* Theme Mode Type */
const ThemeModeLight = 0;
const ThemeModeDark = 1;
const ThemeModeSystem = 2;

const defaultLanguage = 'en';

const VideoTypeCustom = 'custom_url';
const VideoTypeYouTube = 'youtube';
const VideoTypeIFrame = 'iframe';

const bannerAdIdForAndroid = "ca-app-pub-3940256099942544/6300978111";
const bannerAdIdForIos = "ca-app-pub-3940256099942544/2934735716";
const InterstitialAdIdForAndroid = "ca-app-pub-3940256099942544/1033173712";
const interstitialAdIdForIos = "ca-app-pub-3940256099942544/4411468910";

const razorKey = "RAZORKEY";
const stripPaymentKey = 'STRIPE_PAYMENT_KEY';
const stripPaymentPublishKey = 'STRIPE_PUBLISH_KEY';

/// PAYMENT METHOD ENABLE/DISABLE
const IS_STRIPE = false;
const IS_RAZORPAY = false;
const IS_PAY_STACK = false;
const IS_FLUTTER_WAVE = false;
const IS_PAY_FROM_WALLET = false;

///FlutterWave
const flutterWavePublicKey = 'FLUTTER_WAVE_PUBLIC_KEY';
const flutterWaveSecretKey = 'FLUTTER_WAVE_SECRET_KEY';
const flutterWaveEncryptionKey = 'FLUTTER_WAVE_ENCRYPTION_KEY';

///PAY STACK DETAIL
const payStackPublicKey = 'PAYSTACK_PUBLIC_KEY';

const TERMS_CONDITION_URL = "https://anaslakhani.com";
const PRIVACY_POLICY_URL = "https://anaslakhani.com";

const enableSignWithGoogle = true;
const enableSignWithApple = false;
const enableSignWithOtp = false;
const enableSocialSign = true;
const enableAdsLoading = false;
const enableAds = false;

const enableBlog = false;
const enableMultiDemo = false;
const enableDashboardVariant = false;
// bool get enableTeraWallet => getBoolAsync(WALLET);
bool get enableTeraWallet => false;

// Set per page item
const TOTAL_ITEM_PER_PAGE = 50;
const TOTAL_CATEGORY_PER_PAGE = 50;
const TOTAL_SUB_CATEGORY_PER_PAGE = 50;
const TOTAL_DASHBOARD_ITEM = 4;
const TOTAL_BLOG_ITEM = 6;

const WISHLIST_ITEM_LIST = 'WISHLIST_ITEM_LIST';
const CART_ITEM_LIST = 'CART_ITEM_LIST';

const DASHBOARD_PAGE_VARIANT = 'DashboardPageVariant';
const PRODUCT_DETAIL_VARIANT = 'ProductDetailVariant';

const streamRefresh = "streamRefresh";

// Set Theme
bool get isHalloween => getBoolAsync(HALLOWEEN_ENABLE);
const HALLOWEEN_ENABLE = 'halloween_enable';

// Halloween Theme
const base_URL = "https://meetmighty.com/mobile/halloween/wp-json/";
const consumerKey = "ck_74b86eff5a9e8b495ea9bf13d352ab6d343e4293";
const consumerSecret = "cs_5d9a58c45b58e19f61054577f8d8ba6cab1e6e40";
