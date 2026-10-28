import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @authServicesPaused.
  ///
  /// In en, this message translates to:
  /// **'Account services are temporarily unavailable. You can still browse and try checkout.'**
  String get authServicesPaused;

  /// No description provided for @marketChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get marketChat;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Ming Sros'**
  String get chatTitle;

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your food companion'**
  String get chatSubtitle;

  /// No description provided for @chatWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'A fresh idea\nstarts here.'**
  String get chatWelcomeTitle;

  /// No description provided for @chatWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Fresh picks, simple meals, and a little shopping help.'**
  String get chatWelcomeBody;

  /// No description provided for @chatSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'A little inspiration to get started'**
  String get chatSuggestionsTitle;

  /// No description provided for @chatFreshLabel.
  ///
  /// In en, this message translates to:
  /// **'Fresh picks'**
  String get chatFreshLabel;

  /// No description provided for @chatMealsLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal ideas'**
  String get chatMealsLabel;

  /// No description provided for @chatFreshPrompt.
  ///
  /// In en, this message translates to:
  /// **'What’s fresh today?'**
  String get chatFreshPrompt;

  /// No description provided for @chatMealsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Help me plan a meal'**
  String get chatMealsPrompt;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Message Ming Sros…'**
  String get chatInputHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get chatSend;

  /// No description provided for @chatReplyReceived.
  ///
  /// In en, this message translates to:
  /// **'Reply received'**
  String get chatReplyReceived;

  /// No description provided for @chatNewConversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get chatNewConversation;

  /// No description provided for @chatServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Chat is temporarily unavailable. Please try again later.'**
  String get chatServiceUnavailable;

  /// No description provided for @chatConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect. Check your connection and try again.'**
  String get chatConnectionError;

  /// No description provided for @chatRequestError.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t get a reply. Please try again.'**
  String get chatRequestError;

  /// No description provided for @chatRateLimited.
  ///
  /// In en, this message translates to:
  /// **'You\'re sending messages too fast. Please wait a moment and try again.'**
  String get chatRateLimited;

  /// No description provided for @chatInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'The reply couldn\'t be displayed. Please try again.'**
  String get chatInvalidResponse;

  /// No description provided for @chatRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get chatRetry;

  /// No description provided for @chatThinking.
  ///
  /// In en, this message translates to:
  /// **'Ming Sros is thinking…'**
  String get chatThinking;

  /// No description provided for @chatOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get chatOutOfStock;

  /// No description provided for @chatRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients for {dish}'**
  String chatRecipeTitle(String dish);

  /// No description provided for @chatRecipeServings.
  ///
  /// In en, this message translates to:
  /// **'For {count} people'**
  String chatRecipeServings(int count);

  /// No description provided for @chatRecipeNotSold.
  ///
  /// In en, this message translates to:
  /// **'Not sold at Phsar Fresh'**
  String get chatRecipeNotSold;

  /// No description provided for @chatDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo · Sample replies and products'**
  String get chatDemoNotice;

  /// No description provided for @chatDemoGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, I’m Ming Sros! I can show you meal ideas, ingredient lists, and simple recipes. What would you like to try?'**
  String get chatDemoGreeting;

  /// No description provided for @chatDemoMealReply.
  ///
  /// In en, this message translates to:
  /// **'How about rice with stir-fried greens and an egg? Here are the ingredients. Tap one to browse sample products, or ask me for the recipe.'**
  String get chatDemoMealReply;

  /// No description provided for @chatDemoIngredientsReply.
  ///
  /// In en, this message translates to:
  /// **'For rice with stir-fried greens and an egg, you’ll need:'**
  String get chatDemoIngredientsReply;

  /// No description provided for @chatDemoFreshReply.
  ///
  /// In en, this message translates to:
  /// **'Here are a few sample picks from our market. Tap an item to see its product details and try adding it to your basket.'**
  String get chatDemoFreshReply;

  /// No description provided for @chatDemoRecipeReply.
  ///
  /// In en, this message translates to:
  /// **'Rice with stir-fried greens & egg\nServes 2\n\n1. Rinse 1 cup of rice and cook according to the packet instructions.\n2. Wash and chop the greens. Heat a little oil in a pan and stir-fry until tender. Season to taste.\n3. Fry or scramble 2 eggs until cooked through.\n4. Serve the greens and eggs over the rice. Enjoy!'**
  String get chatDemoRecipeReply;

  /// No description provided for @chatDemoLokLakReply.
  ///
  /// In en, this message translates to:
  /// **'For beef lok lak, you’ll need:\n\n• Beef (sirloin or ribeye)\n• Soy sauce\n• Oyster sauce\n• Garlic\n• Black pepper\n• Lettuce\n• Tomato\n• Onion\n• Lime\n\nAsk me for the recipe next!'**
  String get chatDemoLokLakReply;

  /// No description provided for @chatDemoLokLakRecipe.
  ///
  /// In en, this message translates to:
  /// **'Beef lok lak\nServes 2\n\n1. Cut 300 g of beef into bite-size pieces. Mix with 1 tbsp soy sauce, 1 tbsp oyster sauce, 2 minced garlic cloves, and black pepper. Marinate for 15 minutes.\n2. Arrange washed lettuce, sliced tomato, and onion on a plate.\n3. Heat a little oil in a pan. Stir-fry the beef in small batches until cooked to your liking.\n4. Serve over the vegetables with rice. Mix lime juice and black pepper for a dipping sauce.'**
  String get chatDemoLokLakRecipe;

  /// No description provided for @chatDemoThanks.
  ///
  /// In en, this message translates to:
  /// **'You’re welcome! Would you like another meal idea, some fresh picks, or a recipe?'**
  String get chatDemoThanks;

  /// No description provided for @chatDeliveryReply.
  ///
  /// In en, this message translates to:
  /// **'Open Explore or Categories and tap the location in the header to choose your delivery address. Use the map, search, or enter an address, then save it. You can review your address and delivery choices in the checkout preview.'**
  String get chatDeliveryReply;

  /// No description provided for @chatOrdersReply.
  ///
  /// In en, this message translates to:
  /// **'Tap Orders in the navigation bar to see your active orders and order history. This preview cannot look up or change an order. For general shopping questions, you can also find help in Profile.'**
  String get chatOrdersReply;

  /// No description provided for @chatFallbackReply.
  ///
  /// In en, this message translates to:
  /// **'In this demo, I can help with meal ideas, ingredients, recipes, fresh picks, and shopping questions. Try “Help me plan a meal” or “What ingredients do I need?”'**
  String get chatFallbackReply;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PHSAR FRESH'**
  String get appName;

  /// No description provided for @appNameKhmer.
  ///
  /// In en, this message translates to:
  /// **'ផ្សារស្រស់'**
  String get appNameKhmer;

  /// No description provided for @farmFresh.
  ///
  /// In en, this message translates to:
  /// **'100% Farm Fresh'**
  String get farmFresh;

  /// No description provided for @heroDescription.
  ///
  /// In en, this message translates to:
  /// **'Directly harvested from Battambang, Kandal & Kampot'**
  String get heroDescription;

  /// No description provided for @mainTitle.
  ///
  /// In en, this message translates to:
  /// **'Phsar Fresh'**
  String get mainTitle;

  /// No description provided for @mainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Freshness from\nCambodia’s Rich Soil'**
  String get mainSubtitle;

  /// No description provided for @khmerTagline.
  ///
  /// In en, this message translates to:
  /// **'ផ្សារស្រស់ • កសិផលខ្មែរស្រស់ៗពីចម្ការ'**
  String get khmerTagline;

  /// No description provided for @mainDescription.
  ///
  /// In en, this message translates to:
  /// **'Handpicked organic vegetables, Battambang fruits, and Kampot specialties delivered fresh to your door in 30 mins.'**
  String get mainDescription;

  /// No description provided for @organicTitle.
  ///
  /// In en, this message translates to:
  /// **'100% Organic & GAP Certified'**
  String get organicTitle;

  /// No description provided for @organicDescription.
  ///
  /// In en, this message translates to:
  /// **'Guaranteed chemical-free greens, rigorously tested and certified by the Ministry of Agriculture.'**
  String get organicDescription;

  /// No description provided for @gapBadge.
  ///
  /// In en, this message translates to:
  /// **'Cambodia GAP'**
  String get gapBadge;

  /// No description provided for @deliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Farm-to-Door Delivery'**
  String get deliveryTitle;

  /// No description provided for @deliveryDescription.
  ///
  /// In en, this message translates to:
  /// **'Packed in eco-insulated woven containers to preserve garden crispness directly to your table.'**
  String get deliveryDescription;

  /// No description provided for @deliveryTime.
  ///
  /// In en, this message translates to:
  /// **'30 Mins'**
  String get deliveryTime;

  /// No description provided for @fairTradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Direct Fair Trade with Local Farmers'**
  String get fairTradeTitle;

  /// No description provided for @fairTradeDescription.
  ///
  /// In en, this message translates to:
  /// **'100% of fair profits support smallholder farming communities across Cambodia.'**
  String get fairTradeDescription;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @farmFooter.
  ///
  /// In en, this message translates to:
  /// **'Proudly empowering 450+ Khmer family farms'**
  String get farmFooter;

  /// No description provided for @authEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Farm-to-table gourmet'**
  String get authEyebrow;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Phsar Fresh'**
  String get authWelcome;

  /// No description provided for @authFreshProduce.
  ///
  /// In en, this message translates to:
  /// **'Fresh Local Produce'**
  String get authFreshProduce;

  /// No description provided for @authKhmerName.
  ///
  /// In en, this message translates to:
  /// **'ផ្សារស្រស់'**
  String get authKhmerName;

  /// No description provided for @authDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover fresh organic harvests, Kampot peppers & artisanal treasures delivered fresh to your kitchen.'**
  String get authDescription;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneNumber;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get authPhoneHint;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get authPasswordHint;

  /// No description provided for @authUseOtp.
  ///
  /// In en, this message translates to:
  /// **'Use OTP'**
  String get authUseOtp;

  /// No description provided for @authUsePassword.
  ///
  /// In en, this message translates to:
  /// **'Use password'**
  String get authUsePassword;

  /// No description provided for @authOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get authOtpCode;

  /// No description provided for @authOtpHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit code'**
  String get authOtpHint;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// No description provided for @authVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify & Log In'**
  String get authVerifyCode;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get authConfirmPasswordHint;

  /// No description provided for @authRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRememberMe;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authLoginToShop.
  ///
  /// In en, this message translates to:
  /// **'Log In to Shop'**
  String get authLoginToShop;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get authContinueWith;

  /// No description provided for @authContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueGoogle;

  /// No description provided for @authContinueFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get authContinueFacebook;

  /// No description provided for @authContinueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueApple;

  /// No description provided for @authAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to the'**
  String get authAgreementPrefix;

  /// No description provided for @authAgreementAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get authAgreementAnd;

  /// No description provided for @authAgreementSuffix.
  ///
  /// In en, this message translates to:
  /// **'of Phsar Fresh Cambodia.'**
  String get authAgreementSuffix;

  /// No description provided for @authTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get authTerms;

  /// No description provided for @authPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacy;

  /// No description provided for @authSupport.
  ///
  /// In en, this message translates to:
  /// **'Need help? Contact Telegram Customer Support'**
  String get authSupport;

  /// No description provided for @authInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Cambodian mobile number.'**
  String get authInvalidPhone;

  /// No description provided for @authRequiredPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get authRequiredPassword;

  /// No description provided for @authShortPassword.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters for your password.'**
  String get authShortPassword;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match.'**
  String get authPasswordMismatch;

  /// No description provided for @authInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter a 6-digit verification code.'**
  String get authInvalidOtp;

  /// No description provided for @authUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This service is currently unavailable. Please try again later.'**
  String get authUnavailable;

  /// No description provided for @authOtpSignInHelp.
  ///
  /// In en, this message translates to:
  /// **'Use an SMS code to sign in without your password.'**
  String get authOtpSignInHelp;

  /// No description provided for @authServiceError.
  ///
  /// In en, this message translates to:
  /// **'The authentication service couldn’t complete your request. Please try again later.'**
  String get authServiceError;

  /// No description provided for @authUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authUnexpectedError;

  /// No description provided for @authConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect. Check your internet connection and try again.'**
  String get authConnectionError;

  /// No description provided for @authNoSession.
  ///
  /// In en, this message translates to:
  /// **'Sign-in could not be completed. Please try again.'**
  String get authNoSession;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong phone number or password.'**
  String get authInvalidCredentials;

  /// No description provided for @authInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'That code is wrong or has expired. Check the SMS or request a new code.'**
  String get authInvalidCode;

  /// No description provided for @authPhoneInUse.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered. Log in instead.'**
  String get authPhoneInUse;

  /// No description provided for @authTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a minute and try again.'**
  String get authTooManyAttempts;

  /// No description provided for @authPhoneConfirmationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number to continue. Tap Send code to receive a new SMS.'**
  String get authPhoneConfirmationRequired;

  /// No description provided for @authCheckoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue to checkout'**
  String get authCheckoutTitle;

  /// No description provided for @authCheckoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account with your phone number. Your basket is saved.'**
  String get authCheckoutDescription;

  /// No description provided for @authOtpWelcome.
  ///
  /// In en, this message translates to:
  /// **'One more step to your fresh local finds.'**
  String get authOtpWelcome;

  /// No description provided for @authOtpInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your phone to continue.'**
  String get authOtpInstructions;

  /// No description provided for @authDidNotReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn’t receive a code?'**
  String get authDidNotReceiveCode;

  /// No description provided for @authEnterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your verification code'**
  String get authEnterVerificationCode;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResendCode;

  /// No description provided for @authChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get authChangeNumber;

  /// No description provided for @authVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number'**
  String get authVerifyPhone;

  /// No description provided for @authCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to {phone}. Enter it below to continue.'**
  String authCodeSent(String phone);

  /// No description provided for @authResendIn.
  ///
  /// In en, this message translates to:
  /// **'Send again in {seconds}s'**
  String authResendIn(int seconds);

  /// No description provided for @authAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'You are signed in to Phsar Fresh.'**
  String get authAccountDescription;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get authSignOut;

  /// No description provided for @marketBrowseGuest.
  ///
  /// In en, this message translates to:
  /// **'Browse as guest'**
  String get marketBrowseGuest;

  /// No description provided for @marketBrand.
  ///
  /// In en, this message translates to:
  /// **'Phsar Fresh'**
  String get marketBrand;

  /// No description provided for @marketNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get marketNotifications;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Order updates and new promotions will show up here.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsPromotion.
  ///
  /// In en, this message translates to:
  /// **'New promotion'**
  String get notificationsPromotion;

  /// No description provided for @notificationOrderPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get notificationOrderPlacedTitle;

  /// No description provided for @notificationOrderPlacedBody.
  ///
  /// In en, this message translates to:
  /// **'We received order {code}. We\'ll let you know when it\'s being prepared.'**
  String notificationOrderPlacedBody(String code);

  /// No description provided for @notificationOrderPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get notificationOrderPaidTitle;

  /// No description provided for @notificationOrderPaidBody.
  ///
  /// In en, this message translates to:
  /// **'Order {code} is paid. The market team will start preparing it.'**
  String notificationOrderPaidBody(String code);

  /// No description provided for @notificationOrderPreparingTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing your order'**
  String get notificationOrderPreparingTitle;

  /// No description provided for @notificationOrderPreparingBody.
  ///
  /// In en, this message translates to:
  /// **'Order {code} is being packed with fresh produce.'**
  String notificationOrderPreparingBody(String code);

  /// No description provided for @notificationOrderDeliveringTitle.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get notificationOrderDeliveringTitle;

  /// No description provided for @notificationOrderDeliveringBody.
  ///
  /// In en, this message translates to:
  /// **'Your rider is bringing order {code}.'**
  String notificationOrderDeliveringBody(String code);

  /// No description provided for @notificationOrderDeliveredTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get notificationOrderDeliveredTitle;

  /// No description provided for @notificationOrderDeliveredBody.
  ///
  /// In en, this message translates to:
  /// **'Order {code} has arrived. Enjoy!'**
  String notificationOrderDeliveredBody(String code);

  /// No description provided for @notificationMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Update on order {code}'**
  String notificationMessageTitle(String code);

  /// No description provided for @notificationMessageProblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Problem with order {code}'**
  String notificationMessageProblemTitle(String code);

  /// No description provided for @notificationMessageCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Order {code} was cancelled'**
  String notificationMessageCancelledTitle(String code);

  /// No description provided for @notificationOrderCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get notificationOrderCancelledTitle;

  /// No description provided for @notificationOrderCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'Order {code} was cancelled.'**
  String notificationOrderCancelledBody(String code);

  /// No description provided for @marketSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search fresh vegetables, fruits, spices.'**
  String get marketSearchHint;

  /// No description provided for @marketClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get marketClearSearch;

  /// No description provided for @marketVoiceSearchHelp.
  ///
  /// In en, this message translates to:
  /// **'Type a product or origin in the search field.'**
  String get marketVoiceSearchHelp;

  /// No description provided for @marketFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get marketFilters;

  /// No description provided for @marketAllItems.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get marketAllItems;

  /// No description provided for @marketFlashDeal.
  ///
  /// In en, this message translates to:
  /// **'Flash harvest deal'**
  String get marketFlashDeal;

  /// No description provided for @marketDealTitle.
  ///
  /// In en, this message translates to:
  /// **'Special 20% off Battambang Citrus'**
  String get marketDealTitle;

  /// No description provided for @marketClaimDeal.
  ///
  /// In en, this message translates to:
  /// **'Claim Deal'**
  String get marketClaimDeal;

  /// No description provided for @marketAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get marketAddedToCart;

  /// No description provided for @marketDealEnded.
  ///
  /// In en, this message translates to:
  /// **'Deal ended'**
  String get marketDealEnded;

  /// No description provided for @marketItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 item} other{{count} items}}'**
  String marketItemCount(int count);

  /// No description provided for @marketExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get marketExplore;

  /// No description provided for @marketCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get marketCategories;

  /// No description provided for @marketOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get marketOrders;

  /// No description provided for @marketViewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get marketViewCart;

  /// No description provided for @marketCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get marketCart;

  /// No description provided for @marketProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get marketProfile;

  /// No description provided for @marketSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get marketSortBy;

  /// No description provided for @marketInStockOnly.
  ///
  /// In en, this message translates to:
  /// **'In stock only'**
  String get marketInStockOnly;

  /// No description provided for @catalogLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load products'**
  String get catalogLoadError;

  /// No description provided for @catalogLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get catalogLoadErrorBody;

  /// No description provided for @catalogRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get catalogRetry;

  /// No description provided for @catalogLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get catalogLoadMore;

  /// No description provided for @catalogOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get catalogOutOfStock;

  /// No description provided for @catalogAllProducts.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get catalogAllProducts;

  /// No description provided for @catalogNoProductsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No products in this category yet.'**
  String get catalogNoProductsInCategory;

  /// No description provided for @marketSortCurated.
  ///
  /// In en, this message translates to:
  /// **'Curated'**
  String get marketSortCurated;

  /// No description provided for @marketSortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get marketSortName;

  /// No description provided for @marketSortCount.
  ///
  /// In en, this message translates to:
  /// **'Most items'**
  String get marketSortCount;

  /// No description provided for @marketApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get marketApplyFilters;

  /// No description provided for @marketResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get marketResetFilters;

  /// No description provided for @marketClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get marketClose;

  /// No description provided for @marketNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching pantries'**
  String get marketNoResults;

  /// No description provided for @marketNoResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'Try another search or choose a different category.'**
  String get marketNoResultsDescription;

  /// No description provided for @marketNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get marketNoOrders;

  /// No description provided for @marketNoOrdersDescription.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here once you start shopping.'**
  String get marketNoOrdersDescription;

  /// No description provided for @marketContinueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue shopping'**
  String get marketContinueShopping;

  /// No description provided for @marketEmptyCart.
  ///
  /// In en, this message translates to:
  /// **'Your basket is empty'**
  String get marketEmptyCart;

  /// No description provided for @marketEmptyCartDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore fresh local collections to fill your basket.'**
  String get marketEmptyCartDescription;

  /// No description provided for @marketYourBasket.
  ///
  /// In en, this message translates to:
  /// **'Your Basket'**
  String get marketYourBasket;

  /// No description provided for @marketSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get marketSubtotal;

  /// No description provided for @marketDecreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get marketDecreaseQuantity;

  /// No description provided for @marketIncreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get marketIncreaseQuantity;

  /// No description provided for @marketGuest.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Guest'**
  String get marketGuest;

  /// No description provided for @marketGuestDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse fresh collections as a guest. Sign in to manage your account.'**
  String get marketGuestDescription;

  /// No description provided for @marketLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get marketLanguage;

  /// No description provided for @marketDeliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Delivery location'**
  String get marketDeliveryLocation;

  /// No description provided for @marketLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'City, district or address'**
  String get marketLocationLabel;

  /// No description provided for @marketSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save location'**
  String get marketSaveLocation;

  /// No description provided for @exploreTodayHarvest.
  ///
  /// In en, this message translates to:
  /// **'Today\'s harvest deals'**
  String get exploreTodayHarvest;

  /// No description provided for @exploreWelcome.
  ///
  /// In en, this message translates to:
  /// **'Fresh finds from Cambodian farms, ready for your kitchen.'**
  String get exploreWelcome;

  /// No description provided for @exploreShopCategories.
  ///
  /// In en, this message translates to:
  /// **'Shop by category'**
  String get exploreShopCategories;

  /// No description provided for @exploreFreshArrivals.
  ///
  /// In en, this message translates to:
  /// **'Fresh arrivals'**
  String get exploreFreshArrivals;

  /// No description provided for @exploreFreshSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover seasonal produce and fresh local picks.'**
  String get exploreFreshSubtitle;

  /// No description provided for @explorePopular.
  ///
  /// In en, this message translates to:
  /// **'Popular this week'**
  String get explorePopular;

  /// No description provided for @explorePopularSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local favorites for your everyday basket.'**
  String get explorePopularSubtitle;

  /// No description provided for @exploreMingSrosTitle.
  ///
  /// In en, this message translates to:
  /// **'Meet Ming Sros, your AI kitchen helper'**
  String get exploreMingSrosTitle;

  /// No description provided for @exploreMingSrosBody.
  ///
  /// In en, this message translates to:
  /// **'Ask what to cook tonight and get a ready shopping list.'**
  String get exploreMingSrosBody;

  /// No description provided for @exploreMingSrosAction.
  ///
  /// In en, this message translates to:
  /// **'Ask Ming Sros'**
  String get exploreMingSrosAction;

  /// No description provided for @exploreSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get exploreSeeAll;

  /// No description provided for @exploreProducts.
  ///
  /// In en, this message translates to:
  /// **'Shop fresh products'**
  String get exploreProducts;

  /// No description provided for @exploreDiscover.
  ///
  /// In en, this message translates to:
  /// **'Back to discovery'**
  String get exploreDiscover;

  /// No description provided for @exploreNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No matching products'**
  String get exploreNoProducts;

  /// No description provided for @exploreAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get exploreAddToCart;

  /// No description provided for @exploreOrganic.
  ///
  /// In en, this message translates to:
  /// **'Organic'**
  String get exploreOrganic;

  /// No description provided for @explorePopularFirst.
  ///
  /// In en, this message translates to:
  /// **'Popular first'**
  String get explorePopularFirst;

  /// No description provided for @marketGreensPromotion.
  ///
  /// In en, this message translates to:
  /// **'20% off organic greens'**
  String get marketGreensPromotion;

  /// No description provided for @marketFruitsPromotion.
  ///
  /// In en, this message translates to:
  /// **'20% off tropical fruits'**
  String get marketFruitsPromotion;

  /// No description provided for @marketPromotionPosition.
  ///
  /// In en, this message translates to:
  /// **'Promotion {index} of {count}'**
  String marketPromotionPosition(int index, int count);

  /// No description provided for @productOrganicFresh.
  ///
  /// In en, this message translates to:
  /// **'Organic & farm fresh'**
  String get productOrganicFresh;

  /// No description provided for @productOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get productOrigin;

  /// No description provided for @productViewFarm.
  ///
  /// In en, this message translates to:
  /// **'View Farm'**
  String get productViewFarm;

  /// No description provided for @productPackSize.
  ///
  /// In en, this message translates to:
  /// **'Pack Size'**
  String get productPackSize;

  /// No description provided for @productPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get productPopular;

  /// No description provided for @product250g.
  ///
  /// In en, this message translates to:
  /// **'250g Pack'**
  String get product250g;

  /// No description provided for @product500g.
  ///
  /// In en, this message translates to:
  /// **'500g Bundle'**
  String get product500g;

  /// No description provided for @product1kg.
  ///
  /// In en, this message translates to:
  /// **'1kg Family Pack'**
  String get product1kg;

  /// No description provided for @productSinglePack.
  ///
  /// In en, this message translates to:
  /// **'1 Pack'**
  String get productSinglePack;

  /// No description provided for @productDoublePack.
  ///
  /// In en, this message translates to:
  /// **'2 Packs'**
  String get productDoublePack;

  /// No description provided for @productSixEggs.
  ///
  /// In en, this message translates to:
  /// **'6 Eggs'**
  String get productSixEggs;

  /// No description provided for @productDozenEggs.
  ///
  /// In en, this message translates to:
  /// **'12 Eggs'**
  String get productDozenEggs;

  /// No description provided for @productMoreLikeThis.
  ///
  /// In en, this message translates to:
  /// **'You may also like'**
  String get productMoreLikeThis;

  /// No description provided for @productQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get productQuantity;

  /// No description provided for @productAddBasket.
  ///
  /// In en, this message translates to:
  /// **'Add to Basket'**
  String get productAddBasket;

  /// No description provided for @productSaved.
  ///
  /// In en, this message translates to:
  /// **'Save to favorites'**
  String get productSaved;

  /// No description provided for @productUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get productUnsaved;

  /// No description provided for @productCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy product details'**
  String get productCopy;

  /// No description provided for @productCopied.
  ///
  /// In en, this message translates to:
  /// **'Product details copied'**
  String get productCopied;

  /// No description provided for @productFarmStory.
  ///
  /// In en, this message translates to:
  /// **'From the farm to your kitchen'**
  String get productFarmStory;

  /// No description provided for @productFarmDescription.
  ///
  /// In en, this message translates to:
  /// **'Our local catalog highlights Cambodian growers and cooperatives, with fresh harvests selected for everyday cooking.'**
  String get productFarmDescription;

  /// No description provided for @cartEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Fresh from local farms'**
  String get cartEyebrow;

  /// No description provided for @cartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A little local goodness, ready for your kitchen.'**
  String get cartSubtitle;

  /// No description provided for @cartItemRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from basket'**
  String get cartItemRemoved;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @cartRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from basket'**
  String cartRemoveItem(String name);

  /// No description provided for @cartVoucherCode.
  ///
  /// In en, this message translates to:
  /// **'Voucher code'**
  String get cartVoucherCode;

  /// No description provided for @cartVoucherHint.
  ///
  /// In en, this message translates to:
  /// **'Use {code} to save up to {amount} on your basket.'**
  String cartVoucherHint(String code, String amount);

  /// No description provided for @cartApplyVoucher.
  ///
  /// In en, this message translates to:
  /// **'Apply voucher'**
  String get cartApplyVoucher;

  /// No description provided for @cartInvalidVoucher.
  ///
  /// In en, this message translates to:
  /// **'This code is not valid. Check it and try again.'**
  String get cartInvalidVoucher;

  /// No description provided for @cartVoucherApplied.
  ///
  /// In en, this message translates to:
  /// **'{code} applied (−{amount})'**
  String cartVoucherApplied(String code, String amount);

  /// No description provided for @cartRemoveVoucher.
  ///
  /// In en, this message translates to:
  /// **'Remove voucher'**
  String get cartRemoveVoucher;

  /// No description provided for @cartPackagingTitle.
  ///
  /// In en, this message translates to:
  /// **'Thoughtfully packed, naturally fresh'**
  String get cartPackagingTitle;

  /// No description provided for @cartPackagingDescription.
  ///
  /// In en, this message translates to:
  /// **'Banana leaf & recycled kraft packaging included.'**
  String get cartPackagingDescription;

  /// No description provided for @cartOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get cartOrderSummary;

  /// No description provided for @cartVoucherDiscount.
  ///
  /// In en, this message translates to:
  /// **'Voucher discount'**
  String get cartVoucherDiscount;

  /// No description provided for @cartDelivery.
  ///
  /// In en, this message translates to:
  /// **'Eco-friendly delivery'**
  String get cartDelivery;

  /// No description provided for @cartTotalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total payable'**
  String get cartTotalPayable;

  /// No description provided for @cartFarmerSupport.
  ///
  /// In en, this message translates to:
  /// **'Every basket supports Cambodian farmers.'**
  String get cartFarmerSupport;

  /// No description provided for @cartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get cartCheckout;

  /// No description provided for @marketCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get marketCurrency;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'US Dollar (\$)'**
  String get currencyUsd;

  /// No description provided for @currencyKhr.
  ///
  /// In en, this message translates to:
  /// **'Cambodian Riel (៛)'**
  String get currencyKhr;

  /// No description provided for @currencyExchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Display rate: \$1 = 4,100៛ (fixed demo rate).'**
  String get currencyExchangeRate;

  /// No description provided for @currencyConvertedNote.
  ///
  /// In en, this message translates to:
  /// **'Approximate converted price'**
  String get currencyConvertedNote;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get checkoutDeliveryAddress;

  /// No description provided for @checkoutChange.
  ///
  /// In en, this message translates to:
  /// **'Change ›'**
  String get checkoutChange;

  /// No description provided for @checkoutAddRecipient.
  ///
  /// In en, this message translates to:
  /// **'Add recipient name and phone number'**
  String get checkoutAddRecipient;

  /// No description provided for @checkoutLocalFresh.
  ///
  /// In en, this message translates to:
  /// **'Thoughtfully packed, fresh from local farms'**
  String get checkoutLocalFresh;

  /// No description provided for @checkoutEditAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery details'**
  String get checkoutEditAddress;

  /// No description provided for @checkoutRecipientName.
  ///
  /// In en, this message translates to:
  /// **'Recipient name'**
  String get checkoutRecipientName;

  /// No description provided for @checkoutNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the recipient’s name.'**
  String get checkoutNameRequired;

  /// No description provided for @checkoutStreetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street, house number & delivery area'**
  String get checkoutStreetAddress;

  /// No description provided for @checkoutAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a delivery address.'**
  String get checkoutAddressRequired;

  /// No description provided for @checkoutDeliveryWindow.
  ///
  /// In en, this message translates to:
  /// **'Delivery Window'**
  String get checkoutDeliveryWindow;

  /// No description provided for @checkoutFreshlyPrepared.
  ///
  /// In en, this message translates to:
  /// **'Freshly prepared'**
  String get checkoutFreshlyPrepared;

  /// No description provided for @checkoutExpress.
  ///
  /// In en, this message translates to:
  /// **'Express (30 mins)'**
  String get checkoutExpress;

  /// No description provided for @checkoutExpressArrives.
  ///
  /// In en, this message translates to:
  /// **'Arrives by {time}'**
  String checkoutExpressArrives(String time);

  /// No description provided for @checkoutSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule for later'**
  String get checkoutSchedule;

  /// No description provided for @checkoutScheduleDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a day and time that suits you'**
  String get checkoutScheduleDescription;

  /// No description provided for @checkoutScheduledSlot.
  ///
  /// In en, this message translates to:
  /// **'{day}, {start} – {end}'**
  String checkoutScheduledSlot(String day, String start, String end);

  /// No description provided for @checkoutChooseDay.
  ///
  /// In en, this message translates to:
  /// **'Choose a day'**
  String get checkoutChooseDay;

  /// No description provided for @checkoutChooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a time'**
  String get checkoutChooseTime;

  /// No description provided for @checkoutFastest.
  ///
  /// In en, this message translates to:
  /// **'FASTEST'**
  String get checkoutFastest;

  /// No description provided for @checkoutToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get checkoutToday;

  /// No description provided for @checkoutTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get checkoutTomorrow;

  /// No description provided for @checkoutInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special instructions'**
  String get checkoutInstructions;

  /// No description provided for @checkoutInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Leave at the front gate security'**
  String get checkoutInstructionsHint;

  /// No description provided for @checkoutInstructionsHelp.
  ///
  /// In en, this message translates to:
  /// **'A little note for your delivery driver'**
  String get checkoutInstructionsHelp;

  /// No description provided for @checkoutPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get checkoutPaymentMethod;

  /// No description provided for @checkoutAbaPay.
  ///
  /// In en, this message translates to:
  /// **'ABA KHQR'**
  String get checkoutAbaPay;

  /// No description provided for @checkoutAbaPayDescription.
  ///
  /// In en, this message translates to:
  /// **'Pay with KHQR code'**
  String get checkoutAbaPayDescription;

  /// No description provided for @checkoutAbaPayHint.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code to pay with any banking app.'**
  String get checkoutAbaPayHint;

  /// No description provided for @checkoutCard.
  ///
  /// In en, this message translates to:
  /// **'Credit/Debit Card'**
  String get checkoutCard;

  /// No description provided for @checkoutCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Pay with a debit or credit card'**
  String get checkoutCardDescription;

  /// No description provided for @checkoutCash.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get checkoutCash;

  /// No description provided for @checkoutCashDescription.
  ///
  /// In en, this message translates to:
  /// **'Pay in cash when your order arrives'**
  String get checkoutCashDescription;

  /// No description provided for @checkoutItemQuantity.
  ///
  /// In en, this message translates to:
  /// **'Qty: {count} · {pack}'**
  String checkoutItemQuantity(int count, String pack);

  /// No description provided for @checkoutDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get checkoutDeliveryFee;

  /// No description provided for @checkoutPackaging.
  ///
  /// In en, this message translates to:
  /// **'Packaging & eco box'**
  String get checkoutPackaging;

  /// No description provided for @checkoutIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get checkoutIncluded;

  /// No description provided for @checkoutTotalDue.
  ///
  /// In en, this message translates to:
  /// **'Total amount due'**
  String get checkoutTotalDue;

  /// No description provided for @checkoutPayable.
  ///
  /// In en, this message translates to:
  /// **'Payable in USD & KHR'**
  String get checkoutPayable;

  /// No description provided for @checkoutPayAbaPay.
  ///
  /// In en, this message translates to:
  /// **'Place order & pay with ABA PAY · {amount}'**
  String checkoutPayAbaPay(String amount);

  /// No description provided for @checkoutPayCard.
  ///
  /// In en, this message translates to:
  /// **'Place order & pay by card · {amount}'**
  String checkoutPayCard(String amount);

  /// No description provided for @checkoutPlaceCashOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order · Pay on delivery · {amount}'**
  String checkoutPlaceCashOrder(String amount);

  /// No description provided for @checkoutComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Checkout is coming soon'**
  String get checkoutComingSoon;

  /// No description provided for @checkoutUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Order placement and payments are not available yet. Your basket and checkout choices are saved for this session.'**
  String get checkoutUnavailable;

  /// No description provided for @ordersEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your farm-fresh journey'**
  String get ordersEyebrow;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get ordersTitle;

  /// No description provided for @ordersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow your delivery. Find your favourites again.'**
  String get ordersSubtitle;

  /// No description provided for @ordersActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String ordersActiveCount(int count);

  /// No description provided for @ordersActiveTab.
  ///
  /// In en, this message translates to:
  /// **'Active ({count})'**
  String ordersActiveTab(int count);

  /// No description provided for @ordersHistoryTab.
  ///
  /// In en, this message translates to:
  /// **'History ({count})'**
  String ordersHistoryTab(int count);

  /// No description provided for @ordersSampleNotice.
  ///
  /// In en, this message translates to:
  /// **'Sample orders · Tracking preview'**
  String get ordersSampleNotice;

  /// No description provided for @ordersTrackingPreview.
  ///
  /// In en, this message translates to:
  /// **'Tracking preview'**
  String get ordersTrackingPreview;

  /// No description provided for @ordersDeliveryUpdate.
  ///
  /// In en, this message translates to:
  /// **'Delivery update'**
  String get ordersDeliveryUpdate;

  /// No description provided for @ordersReference.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String ordersReference(String id);

  /// No description provided for @ordersPlacedAt.
  ///
  /// In en, this message translates to:
  /// **'Placed {day}, {time}'**
  String ordersPlacedAt(String day, String time);

  /// No description provided for @ordersYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get ordersYesterday;

  /// No description provided for @ordersConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get ordersConfirmed;

  /// No description provided for @ordersPacked.
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get ordersPacked;

  /// No description provided for @ordersOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get ordersOnTheWay;

  /// No description provided for @ordersDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get ordersDelivered;

  /// No description provided for @ordersCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersCancelled;

  /// No description provided for @ordersStepComplete.
  ///
  /// In en, this message translates to:
  /// **'{step}, complete'**
  String ordersStepComplete(String step);

  /// No description provided for @ordersArrivingIn.
  ///
  /// In en, this message translates to:
  /// **'Arriving in about {minutes} mins'**
  String ordersArrivingIn(int minutes);

  /// No description provided for @ordersDeliveryInProgress.
  ///
  /// In en, this message translates to:
  /// **'Your delivery is in progress'**
  String get ordersDeliveryInProgress;

  /// No description provided for @ordersCourierPending.
  ///
  /// In en, this message translates to:
  /// **'Finding your delivery partner'**
  String get ordersCourierPending;

  /// No description provided for @ordersDeliveryPartner.
  ///
  /// In en, this message translates to:
  /// **'Your delivery partner'**
  String get ordersDeliveryPartner;

  /// No description provided for @ordersViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View order details'**
  String get ordersViewDetails;

  /// No description provided for @ordersDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get ordersDetailsTitle;

  /// No description provided for @ordersReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get ordersReceipt;

  /// No description provided for @ordersDeliveredOn.
  ///
  /// In en, this message translates to:
  /// **'Delivered · {day}'**
  String ordersDeliveredOn(String day);

  /// No description provided for @ordersMoreItems.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String ordersMoreItems(int count);

  /// No description provided for @ordersLeftAtReception.
  ///
  /// In en, this message translates to:
  /// **'Delivered to front desk reception'**
  String get ordersLeftAtReception;

  /// No description provided for @ordersHandedToCustomer.
  ///
  /// In en, this message translates to:
  /// **'Handed to the recipient with care'**
  String get ordersHandedToCustomer;

  /// No description provided for @ordersReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder items'**
  String get ordersReorder;

  /// No description provided for @ordersReorderAdded.
  ///
  /// In en, this message translates to:
  /// **'Items added to your basket. Review before checkout.'**
  String get ordersReorderAdded;

  /// No description provided for @ordersHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get ordersHistoryTitle;

  /// No description provided for @ordersRecentPurchases.
  ///
  /// In en, this message translates to:
  /// **'Recent purchases'**
  String get ordersRecentPurchases;

  /// No description provided for @ordersSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get ordersSeeAll;

  /// No description provided for @ordersNoActive.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get ordersNoActive;

  /// No description provided for @ordersNoActiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Your next fresh delivery will appear here.'**
  String get ordersNoActiveDescription;

  /// No description provided for @ordersNoHistory.
  ///
  /// In en, this message translates to:
  /// **'Your story starts with a basket'**
  String get ordersNoHistory;

  /// No description provided for @ordersNoHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Your past orders will be saved here for easy reordering.'**
  String get ordersNoHistoryDescription;

  /// No description provided for @ordersHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Need a hand with an order?'**
  String get ordersHelpTitle;

  /// No description provided for @ordersHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery, items or payment — find a little guidance.'**
  String get ordersHelpSubtitle;

  /// No description provided for @ordersGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get ordersGetHelp;

  /// No description provided for @ordersHelpDelivery.
  ///
  /// In en, this message translates to:
  /// **'Where is my delivery?'**
  String get ordersHelpDelivery;

  /// No description provided for @ordersHelpDeliveryAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open order details to review the delivery address and the latest available status. The progress steps show when your basket is confirmed, packed, on the way and delivered.'**
  String get ordersHelpDeliveryAnswer;

  /// No description provided for @ordersHelpItems.
  ///
  /// In en, this message translates to:
  /// **'An item is missing or damaged'**
  String get ordersHelpItems;

  /// No description provided for @ordersHelpItemsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check the item list in your receipt first. Keep your order number and a photo of any affected items ready when contacting the store.'**
  String get ordersHelpItemsAnswer;

  /// No description provided for @ordersHelpPayment.
  ///
  /// In en, this message translates to:
  /// **'I have a payment question'**
  String get ordersHelpPayment;

  /// No description provided for @ordersHelpPaymentAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your receipt shows the payment method, item total, delivery fee and any discount recorded for the order. Reordering adds items to your basket so you can review current prices before checkout.'**
  String get ordersHelpPaymentAnswer;

  /// No description provided for @ordersItemsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'These items are no longer available in the current catalog.'**
  String get ordersItemsUnavailable;

  /// No description provided for @profileCustomer.
  ///
  /// In en, this message translates to:
  /// **'Fresh food lover'**
  String get profileCustomer;

  /// No description provided for @profileGuestBadge.
  ///
  /// In en, this message translates to:
  /// **'A little fresher, every day'**
  String get profileGuestBadge;

  /// No description provided for @profileMemberBadge.
  ///
  /// In en, this message translates to:
  /// **'Supporting local, together'**
  String get profileMemberBadge;

  /// No description provided for @profileOrdersMade.
  ///
  /// In en, this message translates to:
  /// **'Orders made'**
  String get profileOrdersMade;

  /// No description provided for @profileSavedFavorites.
  ///
  /// In en, this message translates to:
  /// **'Saved favorites'**
  String get profileSavedFavorites;

  /// No description provided for @profileCommunity.
  ///
  /// In en, this message translates to:
  /// **'Shopping & community'**
  String get profileCommunity;

  /// No description provided for @profileFavorites.
  ///
  /// In en, this message translates to:
  /// **'My favorite products'**
  String get profileFavorites;

  /// No description provided for @profileFavoritesHint.
  ///
  /// In en, this message translates to:
  /// **'Your fresh finds, all in one place'**
  String get profileFavoritesHint;

  /// No description provided for @profileFavoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your next favorite is waiting'**
  String get profileFavoritesEmpty;

  /// No description provided for @profileFavoritesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a product to keep it here for your next visit.'**
  String get profileFavoritesEmptyHint;

  /// No description provided for @profileExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore fresh finds'**
  String get profileExplore;

  /// No description provided for @profileRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get profileRemoveFavorite;

  /// No description provided for @profileDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery details'**
  String get profileDelivery;

  /// No description provided for @profileDeliveryHint.
  ///
  /// In en, this message translates to:
  /// **'Set your address and recipient for checkout'**
  String get profileDeliveryHint;

  /// No description provided for @profilePayment.
  ///
  /// In en, this message translates to:
  /// **'Preferred payment'**
  String get profilePayment;

  /// No description provided for @profilePaymentHint.
  ///
  /// In en, this message translates to:
  /// **'Choose your default for this visit. Payment is completed at checkout when ordering is available.'**
  String get profilePaymentHint;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences & language'**
  String get profilePreferences;

  /// No description provided for @profileLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Make yourself at home'**
  String get profileLanguageHint;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Support & peace of mind'**
  String get profileSupport;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get profileHelp;

  /// No description provided for @profileHelpHint.
  ///
  /// In en, this message translates to:
  /// **'Answers about delivery, products & payments'**
  String get profileHelpHint;

  /// No description provided for @profileSourcing.
  ///
  /// In en, this message translates to:
  /// **'From farm to your table'**
  String get profileSourcing;

  /// No description provided for @profileSourcingHint.
  ///
  /// In en, this message translates to:
  /// **'Get to know your fresh food'**
  String get profileSourcingHint;

  /// No description provided for @profileSourcingBody.
  ///
  /// In en, this message translates to:
  /// **'Explore each product to see its farm origin, pack sizes and product information. Supplier and certification details should be checked on the product listing when available. The current catalog includes demonstration content.'**
  String get profileSourcingBody;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your account & privacy'**
  String get profilePrivacy;

  /// No description provided for @profilePrivacyHint.
  ///
  /// In en, this message translates to:
  /// **'How sign-in and your basket work'**
  String get profilePrivacyHint;

  /// No description provided for @profilePrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'You can browse and build a basket before signing in. Your basket is saved on this device. Sign-in is required at checkout. Remember me keeps your session across app restarts; signing out ends the session on this device. Favorites and delivery preferences currently last for this app session.'**
  String get profilePrivacyBody;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @profileDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profileDisplayName;

  /// No description provided for @profileEditHint.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal details and the accounts you use to sign in.'**
  String get profileEditHint;

  /// No description provided for @profileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get profileNameRequired;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get profileSave;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Your profile has been updated.'**
  String get profileSaved;

  /// No description provided for @profileSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t save your profile. Please try again.'**
  String get profileSaveError;

  /// No description provided for @profileFooter.
  ///
  /// In en, this message translates to:
  /// **'Fresh from Cambodian farms to your door'**
  String get profileFooter;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'Phsar Fresh · Version {version}'**
  String profileVersion(String version);

  /// No description provided for @profileGuestCta.
  ///
  /// In en, this message translates to:
  /// **'Sign in to make it yours'**
  String get profileGuestCta;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get profileEmail;

  /// No description provided for @profileNotAdded.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get profileNotAdded;

  /// No description provided for @profileChangePhone.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get profileChangePhone;

  /// No description provided for @profileChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email address'**
  String get profileChangeEmail;

  /// No description provided for @profilePhoneChangeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your new Cambodian mobile number. We’ll send a code to confirm it before changing your sign-in number.'**
  String get profilePhoneChangeHint;

  /// No description provided for @profileEmailChangeHint.
  ///
  /// In en, this message translates to:
  /// **'We’ll send a confirmation link to your new email. If you already have an email on this account, you may need to confirm from both inboxes.'**
  String get profileEmailChangeHint;

  /// No description provided for @profileInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get profileInvalidEmail;

  /// No description provided for @profileSameContact.
  ///
  /// In en, this message translates to:
  /// **'Enter a different phone number or email.'**
  String get profileSameContact;

  /// No description provided for @profileNewPhone.
  ///
  /// In en, this message translates to:
  /// **'New phone number'**
  String get profileNewPhone;

  /// No description provided for @profileNewEmail.
  ///
  /// In en, this message translates to:
  /// **'New email address'**
  String get profileNewEmail;

  /// No description provided for @profileSendConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Send confirmation'**
  String get profileSendConfirmation;

  /// No description provided for @profileEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Check your email for the confirmation link. Return here after confirming to check the update.'**
  String get profileEmailSent;

  /// No description provided for @profilePhoneSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the SMS code sent to your new phone number. Your current number stays active until verification is complete.'**
  String get profilePhoneSent;

  /// No description provided for @profileContactUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your contact details have been updated.'**
  String get profileContactUpdated;

  /// No description provided for @profileContactError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t update your contact details. Please try again.'**
  String get profileContactError;

  /// No description provided for @profileCodeError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t verify this code. Check the code or request a new one.'**
  String get profileCodeError;

  /// No description provided for @profileCheckStatus.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get profileCheckStatus;

  /// No description provided for @profileStillPending.
  ///
  /// In en, this message translates to:
  /// **'Still waiting for confirmation. Check your messages and try again.'**
  String get profileStillPending;

  /// No description provided for @profilePending.
  ///
  /// In en, this message translates to:
  /// **'Pending confirmation'**
  String get profilePending;

  /// No description provided for @profileVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify new number'**
  String get profileVerifyPhone;

  /// No description provided for @profileUseDifferentContact.
  ///
  /// In en, this message translates to:
  /// **'Use a different phone or email'**
  String get profileUseDifferentContact;

  /// No description provided for @profileResendConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Resend confirmation'**
  String get profileResendConfirmation;

  /// No description provided for @profileLinkedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Linked accounts'**
  String get profileLinkedAccounts;

  /// No description provided for @profileLinkedAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'Link Google or Facebook to sign in to this same Phsar Fresh account.'**
  String get profileLinkedAccountsHint;

  /// No description provided for @profileLinkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link account'**
  String get profileLinkAccount;

  /// No description provided for @profileConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get profileConnected;

  /// No description provided for @profileNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get profileNotLinked;

  /// No description provided for @profileFinishLinking.
  ///
  /// In en, this message translates to:
  /// **'Complete the connection in your browser, then return here. An account is connected only after confirmation.'**
  String get profileFinishLinking;

  /// No description provided for @profileLinkError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t link this account. Please try again.'**
  String get profileLinkError;

  /// No description provided for @profileLinkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Account linking is currently unavailable. Please try again later.'**
  String get profileLinkUnavailable;

  /// No description provided for @profileIdentityInUse.
  ///
  /// In en, this message translates to:
  /// **'This Google or Facebook account is already linked to another account.'**
  String get profileIdentityInUse;

  /// No description provided for @profileLinkNotComplete.
  ///
  /// In en, this message translates to:
  /// **'The connection isn’t complete yet. You can try linking again.'**
  String get profileLinkNotComplete;

  /// No description provided for @profileMoreVerification.
  ///
  /// In en, this message translates to:
  /// **'This code was accepted. If another confirmation code was sent to your current number, enter that code to finish the change.'**
  String get profileMoreVerification;

  /// No description provided for @authSocialPending.
  ///
  /// In en, this message translates to:
  /// **'Finish signing in in your browser, then return to the app.'**
  String get authSocialPending;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

  /// No description provided for @profileChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose from photos'**
  String get profileChoosePhoto;

  /// No description provided for @profileTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profileTakePhoto;

  /// No description provided for @profileRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get profileRemovePhoto;

  /// No description provided for @profilePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a clear photo. Your changes are saved when you tap Save changes.'**
  String get profilePhotoHint;

  /// No description provided for @profileCropPhoto.
  ///
  /// In en, this message translates to:
  /// **'Adjust your photo'**
  String get profileCropPhoto;

  /// No description provided for @profileCropHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to position your photo and pinch or use the slider to zoom. The circle shows how it will appear on your profile.'**
  String get profileCropHint;

  /// No description provided for @profilePhotoZoom.
  ///
  /// In en, this message translates to:
  /// **'Photo zoom'**
  String get profilePhotoZoom;

  /// No description provided for @profileResetCrop.
  ///
  /// In en, this message translates to:
  /// **'Reset crop'**
  String get profileResetCrop;

  /// No description provided for @profileUsePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use this photo'**
  String get profileUsePhoto;

  /// No description provided for @profilePhotoInvalid.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t open this photo. Choose a different image under 10 MB.'**
  String get profilePhotoInvalid;

  /// No description provided for @profilePhotoPermission.
  ///
  /// In en, this message translates to:
  /// **'Photo or camera access is unavailable. Allow access in your device settings, then try again.'**
  String get profilePhotoPermission;

  /// No description provided for @profilePhotoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Photo selection is unavailable. Close and reopen the app, then try again.'**
  String get profilePhotoUnavailable;

  /// No description provided for @profilePhotoPickerError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t open the photo picker. Please try again.'**
  String get profilePhotoPickerError;

  /// No description provided for @profileCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No camera is available on this device. Choose a photo from your library.'**
  String get profileCameraUnavailable;

  /// No description provided for @profilePhotoSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t finish saving your photo. Please try again.'**
  String get profilePhotoSaveError;

  /// No description provided for @locationMapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place your delivery pin, or use your current location.'**
  String get locationMapHint;

  /// No description provided for @locationUseCurrent.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get locationUseCurrent;

  /// No description provided for @locationFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get locationFinding;

  /// No description provided for @locationLiveAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Live location · accuracy about {meters} m'**
  String locationLiveAccuracy(int meters);

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access was denied. You can try again or choose a pin on the map.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Allow location access in your device settings, or choose a pin on the map.'**
  String get locationPermissionBlocked;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on your device’s location services, or choose a pin on the map.'**
  String get locationServicesDisabled;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t get your location. Try again or choose a pin on the map.'**
  String get locationUnavailable;

  /// No description provided for @locationOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get locationOpenSettings;

  /// No description provided for @locationSearch.
  ///
  /// In en, this message translates to:
  /// **'Find address on map'**
  String get locationSearch;

  /// No description provided for @locationSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find this address. Try a nearby landmark or place the pin yourself.'**
  String get locationSearchFailed;

  /// No description provided for @locationChooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get locationChooseOnMap;

  /// No description provided for @locationSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t save your location. Please try again.'**
  String get locationSaveError;

  /// No description provided for @locationMapUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The map is unavailable right now. You can still use your location or enter an address.'**
  String get locationMapUnavailable;

  /// No description provided for @addressDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Address details'**
  String get addressDetailsTitle;

  /// No description provided for @addressDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Optional details to help your driver find your door.'**
  String get addressDetailsHint;

  /// No description provided for @addressSaveAs.
  ///
  /// In en, this message translates to:
  /// **'Label this address'**
  String get addressSaveAs;

  /// No description provided for @addressHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get addressHome;

  /// No description provided for @addressWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get addressWork;

  /// No description provided for @addressPartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get addressPartner;

  /// No description provided for @addressOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get addressOther;

  /// No description provided for @addressCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom label'**
  String get addressCustomLabel;

  /// No description provided for @addressCustomLabelRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for this address.'**
  String get addressCustomLabelRequired;

  /// No description provided for @addressHouseNumber.
  ///
  /// In en, this message translates to:
  /// **'House / building no.'**
  String get addressHouseNumber;

  /// No description provided for @addressStreet.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get addressStreet;

  /// No description provided for @addressNote.
  ///
  /// In en, this message translates to:
  /// **'Address notes'**
  String get addressNote;

  /// No description provided for @addressNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Floor, gate, nearby landmark or directions'**
  String get addressNoteHint;

  /// No description provided for @cartVoucherHintRemote.
  ///
  /// In en, this message translates to:
  /// **'Have a promo code? Enter it to save on your basket.'**
  String get cartVoucherHintRemote;

  /// No description provided for @cartVoucherExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired.'**
  String get cartVoucherExpired;

  /// No description provided for @cartVoucherNotStarted.
  ///
  /// In en, this message translates to:
  /// **'This code can\'t be used yet.'**
  String get cartVoucherNotStarted;

  /// No description provided for @cartVoucherMinOrder.
  ///
  /// In en, this message translates to:
  /// **'This code needs a basket of at least {amount}.'**
  String cartVoucherMinOrder(String amount);

  /// No description provided for @cartVoucherCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check the code. Check your connection and try again.'**
  String get cartVoucherCheckFailed;

  /// No description provided for @cartVoucherAddMore.
  ///
  /// In en, this message translates to:
  /// **'Add {amount} more to use {code}.'**
  String cartVoucherAddMore(String amount, String code);

  /// No description provided for @cartVoucherLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use this code.'**
  String get cartVoucherLoginRequired;

  /// No description provided for @cartVoucherNotNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'This code is for your first order only.'**
  String get cartVoucherNotNewCustomer;

  /// No description provided for @cartVoucherAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already used this code.'**
  String get cartVoucherAlreadyUsed;

  /// No description provided for @checkoutPlacing.
  ///
  /// In en, this message translates to:
  /// **'Placing your order…'**
  String get checkoutPlacing;

  /// No description provided for @checkoutNeedLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where should we deliver?'**
  String get checkoutNeedLocationTitle;

  /// No description provided for @checkoutNeedLocation.
  ///
  /// In en, this message translates to:
  /// **'Pin your delivery location on the map so the driver can find you.'**
  String get checkoutNeedLocation;

  /// No description provided for @orderSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Order placed!'**
  String get orderSuccessTitle;

  /// No description provided for @orderSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you! The market team is getting your fresh basket ready.'**
  String get orderSuccessBody;

  /// No description provided for @orderSuccessCode.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get orderSuccessCode;

  /// No description provided for @orderSuccessTrack.
  ///
  /// In en, this message translates to:
  /// **'Track my order'**
  String get orderSuccessTrack;

  /// No description provided for @checkoutOrderPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get checkoutOrderPlacedTitle;

  /// No description provided for @checkoutOrderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your order {code} for {total} is on its way to the market team.'**
  String checkoutOrderPlaced(String code, String total);

  /// No description provided for @checkoutOrderFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t place your order'**
  String get checkoutOrderFailedTitle;

  /// No description provided for @checkoutOrderFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Check your connection and try again.'**
  String get checkoutOrderFailed;

  /// No description provided for @checkoutSignInToOrder.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account to place an order.'**
  String get checkoutSignInToOrder;

  /// No description provided for @checkoutVoucherRemoved.
  ///
  /// In en, this message translates to:
  /// **'{reason} We removed the code — check your new total and place the order again.'**
  String checkoutVoucherRemoved(String reason);

  /// No description provided for @khqrTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay with ABA KHQR'**
  String get khqrTitle;

  /// No description provided for @khqrOrder.
  ///
  /// In en, this message translates to:
  /// **'Order {code}'**
  String khqrOrder(String code);

  /// No description provided for @khqrScanHint.
  ///
  /// In en, this message translates to:
  /// **'Scan with Bakong App or Mobile Banking app that supports KHQR'**
  String get khqrScanHint;

  /// No description provided for @khqrOpenAba.
  ///
  /// In en, this message translates to:
  /// **'Open ABA Mobile'**
  String get khqrOpenAba;

  /// No description provided for @khqrAbaMissing.
  ///
  /// In en, this message translates to:
  /// **'ABA Mobile isn\'t installed on this phone. Scan the QR with another phone or bank app.'**
  String get khqrAbaMissing;

  /// No description provided for @khqrWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get khqrWaiting;

  /// No description provided for @khqrExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'expires in {time}'**
  String khqrExpiresIn(String time);

  /// No description provided for @khqrExpired.
  ///
  /// In en, this message translates to:
  /// **'This QR has expired.'**
  String get khqrExpired;

  /// No description provided for @khqrFailed.
  ///
  /// In en, this message translates to:
  /// **'The payment didn\'t go through.'**
  String get khqrFailed;

  /// No description provided for @khqrNewQr.
  ///
  /// In en, this message translates to:
  /// **'Get a new QR'**
  String get khqrNewQr;

  /// No description provided for @khqrError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the ABA KHQR.'**
  String get khqrError;

  /// No description provided for @khqrTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get khqrTryAgain;

  /// No description provided for @khqrPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get khqrPaidTitle;

  /// No description provided for @khqrPaidBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Order {code} is paid and the market team is preparing it.'**
  String khqrPaidBody(String code);

  /// No description provided for @khqrDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get khqrDone;

  /// No description provided for @khqrLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave without paying?'**
  String get khqrLeaveTitle;

  /// No description provided for @khqrLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your order is saved, but we only start preparing it once it\'s paid.'**
  String get khqrLeaveBody;

  /// No description provided for @khqrStay.
  ///
  /// In en, this message translates to:
  /// **'Stay and pay'**
  String get khqrStay;

  /// No description provided for @khqrLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get khqrLeave;

  /// No description provided for @khqrTestModeNote.
  ///
  /// In en, this message translates to:
  /// **'Test mode: this QR is not real and no money moves.'**
  String get khqrTestModeNote;

  /// No description provided for @khqrSimulatePay.
  ///
  /// In en, this message translates to:
  /// **'Simulate payment (test)'**
  String get khqrSimulatePay;

  /// No description provided for @ordersAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get ordersAwaitingPayment;

  /// No description provided for @ordersPaymentNeeded.
  ///
  /// In en, this message translates to:
  /// **'Pay with ABA KHQR and we\'ll start preparing it'**
  String get ordersPaymentNeeded;

  /// No description provided for @ordersPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get ordersPayNow;

  /// No description provided for @ordersSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your orders'**
  String get ordersSignInTitle;

  /// No description provided for @ordersSignInBody.
  ///
  /// In en, this message translates to:
  /// **'Your orders and delivery updates show up here once you\'re signed in.'**
  String get ordersSignInBody;

  /// No description provided for @ordersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your orders'**
  String get ordersLoadFailed;

  /// No description provided for @ordersLoadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection, then try again or pull down to refresh.'**
  String get ordersLoadFailedBody;

  /// No description provided for @ordersRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get ordersRetry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
