# The Apple Sign In - Flutter Plugin

**NB! `the_apple_sign_in` is the revisited and updated version
of [flutter_apple_sign_in](https://github.com/tomgilder/flutter_apple_sign_in) by Tom Gilder (which
is not maintained anymore...).**
**Thus, `the_apple_sign_in` will be maintained and updated
by [beerstorm](https://github.com/beerstorm-net)**

Before beginning, read related docs
about [Sign In with Apple](https://developer.apple.com/sign-in-with-apple/).

## Platform support

This plugin currently supports only iOS platform. If needed, there's
a [JavaScript framework](https://developer.apple.com/documentation/signinwithapplejs) for Android.

## Implementing

1. [Configure your app](https://help.apple.com/developer-account/#/devde676e696) in Xcode to add
   the "Sign In with Apple" capability
2.

See [the example app](https://github.com/beerstorm-net/the_apple_sign_in/blob/master/example/lib/sign_in_page.dart)
to see how the API works

## FAQs

### User information is null after signing in

User details such as email and name are only provided the first time a user signs in to your app
with Sign in With Apple. This isn't a limitation of the plugin,
it's [how the native SDK functions](https://forums.developer.apple.com/thread/121496).

On signing in again, all the properties are null. You need to store them the first time you login.

For testing purposes you can revoke the credentials to sign in again:

1. Sign in to https://appleid.apple.com/account/manage
2. Go to "Apps & Websites Using Apple ID" and click "Manage"
3. Select your app
4. Click "Stop Using Apple ID"

### I'm getting errors when trying to build the project

Sign In with Apple requires Xcode 11, as it requires the iOS 13 SDK. Make sure you're up-to-date.

## To Do

* Support
  for [PasswordProvider](https://developer.apple.com/documentation/authenticationservices/asauthorizationpasswordprovider)
