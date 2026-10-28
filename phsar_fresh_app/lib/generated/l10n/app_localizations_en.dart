// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authServicesPaused =>
      'Account services are temporarily unavailable. You can still browse and try checkout.';

  @override
  String get marketChat => 'AI Chat';

  @override
  String get chatTitle => 'Ming Sros';

  @override
  String get chatSubtitle => 'Your food companion';

  @override
  String get chatWelcomeTitle => 'A fresh idea\nstarts here.';

  @override
  String get chatWelcomeBody =>
      'Fresh picks, simple meals, and a little shopping help.';

  @override
  String get chatSuggestionsTitle => 'A little inspiration to get started';

  @override
  String get chatFreshLabel => 'Fresh picks';

  @override
  String get chatMealsLabel => 'Meal ideas';

  @override
  String get chatFreshPrompt => 'What’s fresh today?';

  @override
  String get chatMealsPrompt => 'Help me plan a meal';

  @override
  String get chatInputHint => 'Message Ming Sros…';

  @override
  String get chatSend => 'Send message';

  @override
  String get chatReplyReceived => 'Reply received';

  @override
  String get chatNewConversation => 'New conversation';

  @override
  String get chatServiceUnavailable =>
      'Chat is temporarily unavailable. Please try again later.';

  @override
  String get chatConnectionError =>
      'Couldn\'t connect. Check your connection and try again.';

  @override
  String get chatRequestError => 'I couldn\'t get a reply. Please try again.';

  @override
  String get chatRateLimited =>
      'You\'re sending messages too fast. Please wait a moment and try again.';

  @override
  String get chatInvalidResponse =>
      'The reply couldn\'t be displayed. Please try again.';

  @override
  String get chatRetry => 'Try again';

  @override
  String get chatThinking => 'Ming Sros is thinking…';

  @override
  String get chatOutOfStock => 'Out of stock';

  @override
  String chatRecipeTitle(String dish) {
    return 'Ingredients for $dish';
  }

  @override
  String chatRecipeServings(int count) {
    return 'For $count people';
  }

  @override
  String get chatRecipeNotSold => 'Not sold at Phsar Fresh';

  @override
  String get chatDemoNotice => 'Demo · Sample replies and products';

  @override
  String get chatDemoGreeting =>
      'Hi, I’m Ming Sros! I can show you meal ideas, ingredient lists, and simple recipes. What would you like to try?';

  @override
  String get chatDemoMealReply =>
      'How about rice with stir-fried greens and an egg? Here are the ingredients. Tap one to browse sample products, or ask me for the recipe.';

  @override
  String get chatDemoIngredientsReply =>
      'For rice with stir-fried greens and an egg, you’ll need:';

  @override
  String get chatDemoFreshReply =>
      'Here are a few sample picks from our market. Tap an item to see its product details and try adding it to your basket.';

  @override
  String get chatDemoRecipeReply =>
      'Rice with stir-fried greens & egg\nServes 2\n\n1. Rinse 1 cup of rice and cook according to the packet instructions.\n2. Wash and chop the greens. Heat a little oil in a pan and stir-fry until tender. Season to taste.\n3. Fry or scramble 2 eggs until cooked through.\n4. Serve the greens and eggs over the rice. Enjoy!';

  @override
  String get chatDemoLokLakReply =>
      'For beef lok lak, you’ll need:\n\n• Beef (sirloin or ribeye)\n• Soy sauce\n• Oyster sauce\n• Garlic\n• Black pepper\n• Lettuce\n• Tomato\n• Onion\n• Lime\n\nAsk me for the recipe next!';

  @override
  String get chatDemoLokLakRecipe =>
      'Beef lok lak\nServes 2\n\n1. Cut 300 g of beef into bite-size pieces. Mix with 1 tbsp soy sauce, 1 tbsp oyster sauce, 2 minced garlic cloves, and black pepper. Marinate for 15 minutes.\n2. Arrange washed lettuce, sliced tomato, and onion on a plate.\n3. Heat a little oil in a pan. Stir-fry the beef in small batches until cooked to your liking.\n4. Serve over the vegetables with rice. Mix lime juice and black pepper for a dipping sauce.';

  @override
  String get chatDemoThanks =>
      'You’re welcome! Would you like another meal idea, some fresh picks, or a recipe?';

  @override
  String get chatDeliveryReply =>
      'Open Explore or Categories and tap the location in the header to choose your delivery address. Use the map, search, or enter an address, then save it. You can review your address and delivery choices in the checkout preview.';

  @override
  String get chatOrdersReply =>
      'Tap Orders in the navigation bar to see your active orders and order history. This preview cannot look up or change an order. For general shopping questions, you can also find help in Profile.';

  @override
  String get chatFallbackReply =>
      'In this demo, I can help with meal ideas, ingredients, recipes, fresh picks, and shopping questions. Try “Help me plan a meal” or “What ingredients do I need?”';

  @override
  String get appName => 'PHSAR FRESH';

  @override
  String get appNameKhmer => 'ផ្សារស្រស់';

  @override
  String get farmFresh => '100% Farm Fresh';

  @override
  String get heroDescription =>
      'Directly harvested from Battambang, Kandal & Kampot';

  @override
  String get mainTitle => 'Phsar Fresh';

  @override
  String get mainSubtitle => 'Freshness from\nCambodia’s Rich Soil';

  @override
  String get khmerTagline => 'ផ្សារស្រស់ • កសិផលខ្មែរស្រស់ៗពីចម្ការ';

  @override
  String get mainDescription =>
      'Handpicked organic vegetables, Battambang fruits, and Kampot specialties delivered fresh to your door in 30 mins.';

  @override
  String get organicTitle => '100% Organic & GAP Certified';

  @override
  String get organicDescription =>
      'Guaranteed chemical-free greens, rigorously tested and certified by the Ministry of Agriculture.';

  @override
  String get gapBadge => 'Cambodia GAP';

  @override
  String get deliveryTitle => 'Farm-to-Door Delivery';

  @override
  String get deliveryDescription =>
      'Packed in eco-insulated woven containers to preserve garden crispness directly to your table.';

  @override
  String get deliveryTime => '30 Mins';

  @override
  String get fairTradeTitle => 'Direct Fair Trade with Local Farmers';

  @override
  String get fairTradeDescription =>
      '100% of fair profits support smallholder farming communities across Cambodia.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get alreadyAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get farmFooter => 'Proudly empowering 450+ Khmer family farms';

  @override
  String get authEyebrow => 'Farm-to-table gourmet';

  @override
  String get authWelcome => 'Welcome to Phsar Fresh';

  @override
  String get authFreshProduce => 'Fresh Local Produce';

  @override
  String get authKhmerName => 'ផ្សារស្រស់';

  @override
  String get authDescription =>
      'Discover fresh organic harvests, Kampot peppers & artisanal treasures delivered fresh to your kitchen.';

  @override
  String get authRegister => 'Register';

  @override
  String get authPhoneNumber => 'Phone Number';

  @override
  String get authPhoneHint => 'Enter mobile number';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHint => 'Enter password';

  @override
  String get authUseOtp => 'Use OTP';

  @override
  String get authUsePassword => 'Use password';

  @override
  String get authOtpCode => 'Verification code';

  @override
  String get authOtpHint => 'Enter 6-digit code';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authVerifyCode => 'Verify & Log In';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authConfirmPasswordHint => 'Re-enter password';

  @override
  String get authRememberMe => 'Remember me';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authLoginToShop => 'Log In to Shop';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authContinueWith => 'Or continue with';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authContinueFacebook => 'Continue with Facebook';

  @override
  String get authContinueApple => 'Continue with Apple';

  @override
  String get authAgreementPrefix => 'By continuing, you agree to the';

  @override
  String get authAgreementAnd => 'and';

  @override
  String get authAgreementSuffix => 'of Phsar Fresh Cambodia.';

  @override
  String get authTerms => 'Terms of Service';

  @override
  String get authPrivacy => 'Privacy Policy';

  @override
  String get authSupport => 'Need help? Contact Telegram Customer Support';

  @override
  String get authInvalidPhone => 'Enter a valid Cambodian mobile number.';

  @override
  String get authRequiredPassword => 'Enter your password.';

  @override
  String get authShortPassword =>
      'Use at least 8 characters for your password.';

  @override
  String get authPasswordMismatch => 'The passwords do not match.';

  @override
  String get authInvalidOtp => 'Enter a 6-digit verification code.';

  @override
  String get authUnavailable =>
      'This service is currently unavailable. Please try again later.';

  @override
  String get authOtpSignInHelp =>
      'Use an SMS code to sign in without your password.';

  @override
  String get authServiceError =>
      'The authentication service couldn’t complete your request. Please try again later.';

  @override
  String get authUnexpectedError => 'Something went wrong. Please try again.';

  @override
  String get authConnectionError =>
      'Unable to connect. Check your internet connection and try again.';

  @override
  String get authNoSession =>
      'Sign-in could not be completed. Please try again.';

  @override
  String get authInvalidCredentials => 'Wrong phone number or password.';

  @override
  String get authInvalidCode =>
      'That code is wrong or has expired. Check the SMS or request a new code.';

  @override
  String get authPhoneInUse =>
      'This phone number is already registered. Log in instead.';

  @override
  String get authTooManyAttempts =>
      'Too many attempts. Please wait a minute and try again.';

  @override
  String get authPhoneConfirmationRequired =>
      'Verify your phone number to continue. Tap Send code to receive a new SMS.';

  @override
  String get authCheckoutTitle => 'Continue to checkout';

  @override
  String get authCheckoutDescription =>
      'Sign in or create an account with your phone number. Your basket is saved.';

  @override
  String get authOtpWelcome => 'One more step to your fresh local finds.';

  @override
  String get authOtpInstructions =>
      'Enter the 6-digit code sent to your phone to continue.';

  @override
  String get authDidNotReceiveCode => 'Didn’t receive a code?';

  @override
  String get authEnterVerificationCode => 'Enter your verification code';

  @override
  String get authResendCode => 'Resend code';

  @override
  String get authChangeNumber => 'Change phone number';

  @override
  String get authVerifyPhone => 'Verify your phone number';

  @override
  String authCodeSent(String phone) {
    return 'We sent a verification code to $phone. Enter it below to continue.';
  }

  @override
  String authResendIn(int seconds) {
    return 'Send again in ${seconds}s';
  }

  @override
  String get authAccountDescription => 'You are signed in to Phsar Fresh.';

  @override
  String get authSignOut => 'Sign Out';

  @override
  String get marketBrowseGuest => 'Browse as guest';

  @override
  String get marketBrand => 'Phsar Fresh';

  @override
  String get marketNotifications => 'Notifications';

  @override
  String get notificationsEmptyTitle => 'You\'re all caught up';

  @override
  String get notificationsEmptyBody =>
      'Order updates and new promotions will show up here.';

  @override
  String get notificationsPromotion => 'New promotion';

  @override
  String get notificationOrderPlacedTitle => 'Order placed';

  @override
  String notificationOrderPlacedBody(String code) {
    return 'We received order $code. We\'ll let you know when it\'s being prepared.';
  }

  @override
  String get notificationOrderPaidTitle => 'Payment received';

  @override
  String notificationOrderPaidBody(String code) {
    return 'Order $code is paid. The market team will start preparing it.';
  }

  @override
  String get notificationOrderPreparingTitle => 'Preparing your order';

  @override
  String notificationOrderPreparingBody(String code) {
    return 'Order $code is being packed with fresh produce.';
  }

  @override
  String get notificationOrderDeliveringTitle => 'On the way';

  @override
  String notificationOrderDeliveringBody(String code) {
    return 'Your rider is bringing order $code.';
  }

  @override
  String get notificationOrderDeliveredTitle => 'Delivered';

  @override
  String notificationOrderDeliveredBody(String code) {
    return 'Order $code has arrived. Enjoy!';
  }

  @override
  String notificationMessageTitle(String code) {
    return 'Update on order $code';
  }

  @override
  String notificationMessageProblemTitle(String code) {
    return 'Problem with order $code';
  }

  @override
  String notificationMessageCancelledTitle(String code) {
    return 'Order $code was cancelled';
  }

  @override
  String get notificationOrderCancelledTitle => 'Order cancelled';

  @override
  String notificationOrderCancelledBody(String code) {
    return 'Order $code was cancelled.';
  }

  @override
  String get marketSearchHint => 'Search fresh vegetables, fruits, spices.';

  @override
  String get marketClearSearch => 'Clear search';

  @override
  String get marketVoiceSearchHelp =>
      'Type a product or origin in the search field.';

  @override
  String get marketFilters => 'Filters';

  @override
  String get marketAllItems => 'All Items';

  @override
  String get marketFlashDeal => 'Flash harvest deal';

  @override
  String get marketDealTitle => 'Special 20% off Battambang Citrus';

  @override
  String get marketClaimDeal => 'Claim Deal';

  @override
  String get marketAddedToCart => 'Added to cart';

  @override
  String get marketDealEnded => 'Deal ended';

  @override
  String marketItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get marketExplore => 'Explore';

  @override
  String get marketCategories => 'Categories';

  @override
  String get marketOrders => 'Orders';

  @override
  String get marketViewCart => 'View cart';

  @override
  String get marketCart => 'Cart';

  @override
  String get marketProfile => 'Profile';

  @override
  String get marketSortBy => 'Sort by';

  @override
  String get marketInStockOnly => 'In stock only';

  @override
  String get catalogLoadError => 'Couldn\'t load products';

  @override
  String get catalogLoadErrorBody => 'Check your connection and try again.';

  @override
  String get catalogRetry => 'Try again';

  @override
  String get catalogLoadMore => 'Load more';

  @override
  String get catalogOutOfStock => 'Out of stock';

  @override
  String get catalogAllProducts => 'All products';

  @override
  String get catalogNoProductsInCategory => 'No products in this category yet.';

  @override
  String get marketSortCurated => 'Curated';

  @override
  String get marketSortName => 'Name';

  @override
  String get marketSortCount => 'Most items';

  @override
  String get marketApplyFilters => 'Apply filters';

  @override
  String get marketResetFilters => 'Reset filters';

  @override
  String get marketClose => 'Close';

  @override
  String get marketNoResults => 'No matching pantries';

  @override
  String get marketNoResultsDescription =>
      'Try another search or choose a different category.';

  @override
  String get marketNoOrders => 'No orders yet';

  @override
  String get marketNoOrdersDescription =>
      'Your orders will appear here once you start shopping.';

  @override
  String get marketContinueShopping => 'Continue shopping';

  @override
  String get marketEmptyCart => 'Your basket is empty';

  @override
  String get marketEmptyCartDescription =>
      'Explore fresh local collections to fill your basket.';

  @override
  String get marketYourBasket => 'Your Basket';

  @override
  String get marketSubtotal => 'Subtotal';

  @override
  String get marketDecreaseQuantity => 'Decrease quantity';

  @override
  String get marketIncreaseQuantity => 'Increase quantity';

  @override
  String get marketGuest => 'Welcome, Guest';

  @override
  String get marketGuestDescription =>
      'Browse fresh collections as a guest. Sign in to manage your account.';

  @override
  String get marketLanguage => 'Language';

  @override
  String get marketDeliveryLocation => 'Delivery location';

  @override
  String get marketLocationLabel => 'City, district or address';

  @override
  String get marketSaveLocation => 'Save location';

  @override
  String get exploreTodayHarvest => 'Today\'s harvest deals';

  @override
  String get exploreWelcome =>
      'Fresh finds from Cambodian farms, ready for your kitchen.';

  @override
  String get exploreShopCategories => 'Shop by category';

  @override
  String get exploreFreshArrivals => 'Fresh arrivals';

  @override
  String get exploreFreshSubtitle =>
      'Discover seasonal produce and fresh local picks.';

  @override
  String get explorePopular => 'Popular this week';

  @override
  String get explorePopularSubtitle =>
      'Local favorites for your everyday basket.';

  @override
  String get exploreMingSrosTitle => 'Meet Ming Sros, your AI kitchen helper';

  @override
  String get exploreMingSrosBody =>
      'Ask what to cook tonight and get a ready shopping list.';

  @override
  String get exploreMingSrosAction => 'Ask Ming Sros';

  @override
  String get exploreSeeAll => 'See all';

  @override
  String get exploreProducts => 'Shop fresh products';

  @override
  String get exploreDiscover => 'Back to discovery';

  @override
  String get exploreNoProducts => 'No matching products';

  @override
  String get exploreAddToCart => 'Add to Cart';

  @override
  String get exploreOrganic => 'Organic';

  @override
  String get explorePopularFirst => 'Popular first';

  @override
  String get marketGreensPromotion => '20% off organic greens';

  @override
  String get marketFruitsPromotion => '20% off tropical fruits';

  @override
  String marketPromotionPosition(int index, int count) {
    return 'Promotion $index of $count';
  }

  @override
  String get productOrganicFresh => 'Organic & farm fresh';

  @override
  String get productOrigin => 'Origin';

  @override
  String get productViewFarm => 'View Farm';

  @override
  String get productPackSize => 'Pack Size';

  @override
  String get productPopular => 'Popular';

  @override
  String get product250g => '250g Pack';

  @override
  String get product500g => '500g Bundle';

  @override
  String get product1kg => '1kg Family Pack';

  @override
  String get productSinglePack => '1 Pack';

  @override
  String get productDoublePack => '2 Packs';

  @override
  String get productSixEggs => '6 Eggs';

  @override
  String get productDozenEggs => '12 Eggs';

  @override
  String get productMoreLikeThis => 'You may also like';

  @override
  String get productQuantity => 'Quantity';

  @override
  String get productAddBasket => 'Add to Basket';

  @override
  String get productSaved => 'Save to favorites';

  @override
  String get productUnsaved => 'Remove from favorites';

  @override
  String get productCopy => 'Copy product details';

  @override
  String get productCopied => 'Product details copied';

  @override
  String get productFarmStory => 'From the farm to your kitchen';

  @override
  String get productFarmDescription =>
      'Our local catalog highlights Cambodian growers and cooperatives, with fresh harvests selected for everyday cooking.';

  @override
  String get cartEyebrow => 'Fresh from local farms';

  @override
  String get cartSubtitle => 'A little local goodness, ready for your kitchen.';

  @override
  String get cartItemRemoved => 'Removed from basket';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonUndo => 'Undo';

  @override
  String cartRemoveItem(String name) {
    return 'Remove $name from basket';
  }

  @override
  String get cartVoucherCode => 'Voucher code';

  @override
  String cartVoucherHint(String code, String amount) {
    return 'Use $code to save up to $amount on your basket.';
  }

  @override
  String get cartApplyVoucher => 'Apply voucher';

  @override
  String get cartInvalidVoucher =>
      'This code is not valid. Check it and try again.';

  @override
  String cartVoucherApplied(String code, String amount) {
    return '$code applied (−$amount)';
  }

  @override
  String get cartRemoveVoucher => 'Remove voucher';

  @override
  String get cartPackagingTitle => 'Thoughtfully packed, naturally fresh';

  @override
  String get cartPackagingDescription =>
      'Banana leaf & recycled kraft packaging included.';

  @override
  String get cartOrderSummary => 'Order Summary';

  @override
  String get cartVoucherDiscount => 'Voucher discount';

  @override
  String get cartDelivery => 'Eco-friendly delivery';

  @override
  String get cartTotalPayable => 'Total payable';

  @override
  String get cartFarmerSupport => 'Every basket supports Cambodian farmers.';

  @override
  String get cartCheckout => 'Proceed to Checkout';

  @override
  String get marketCurrency => 'Currency';

  @override
  String get currencyUsd => 'US Dollar (\$)';

  @override
  String get currencyKhr => 'Cambodian Riel (៛)';

  @override
  String get currencyExchangeRate =>
      'Display rate: \$1 = 4,100៛ (fixed demo rate).';

  @override
  String get currencyConvertedNote => 'Approximate converted price';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutDeliveryAddress => 'Delivery address';

  @override
  String get checkoutChange => 'Change ›';

  @override
  String get checkoutAddRecipient => 'Add recipient name and phone number';

  @override
  String get checkoutLocalFresh =>
      'Thoughtfully packed, fresh from local farms';

  @override
  String get checkoutEditAddress => 'Delivery details';

  @override
  String get checkoutRecipientName => 'Recipient name';

  @override
  String get checkoutNameRequired => 'Enter the recipient’s name.';

  @override
  String get checkoutStreetAddress => 'Street, house number & delivery area';

  @override
  String get checkoutAddressRequired => 'Enter a delivery address.';

  @override
  String get checkoutDeliveryWindow => 'Delivery Window';

  @override
  String get checkoutFreshlyPrepared => 'Freshly prepared';

  @override
  String get checkoutExpress => 'Express (30 mins)';

  @override
  String checkoutExpressArrives(String time) {
    return 'Arrives by $time';
  }

  @override
  String get checkoutSchedule => 'Schedule for later';

  @override
  String get checkoutScheduleDescription =>
      'Pick a day and time that suits you';

  @override
  String checkoutScheduledSlot(String day, String start, String end) {
    return '$day, $start – $end';
  }

  @override
  String get checkoutChooseDay => 'Choose a day';

  @override
  String get checkoutChooseTime => 'Choose a time';

  @override
  String get checkoutFastest => 'FASTEST';

  @override
  String get checkoutToday => 'Today';

  @override
  String get checkoutTomorrow => 'Tomorrow';

  @override
  String get checkoutInstructions => 'Special instructions';

  @override
  String get checkoutInstructionsHint =>
      'e.g. Leave at the front gate security';

  @override
  String get checkoutInstructionsHelp =>
      'A little note for your delivery driver';

  @override
  String get checkoutPaymentMethod => 'Payment Method';

  @override
  String get checkoutAbaPay => 'ABA KHQR';

  @override
  String get checkoutAbaPayDescription => 'Pay with KHQR code';

  @override
  String get checkoutAbaPayHint =>
      'Scan the QR code to pay with any banking app.';

  @override
  String get checkoutCard => 'Credit/Debit Card';

  @override
  String get checkoutCardDescription => 'Pay with a debit or credit card';

  @override
  String get checkoutCash => 'Cash on delivery';

  @override
  String get checkoutCashDescription => 'Pay in cash when your order arrives';

  @override
  String checkoutItemQuantity(int count, String pack) {
    return 'Qty: $count · $pack';
  }

  @override
  String get checkoutDeliveryFee => 'Delivery fee';

  @override
  String get checkoutPackaging => 'Packaging & eco box';

  @override
  String get checkoutIncluded => 'Included';

  @override
  String get checkoutTotalDue => 'Total amount due';

  @override
  String get checkoutPayable => 'Payable in USD & KHR';

  @override
  String checkoutPayAbaPay(String amount) {
    return 'Place order & pay with ABA PAY · $amount';
  }

  @override
  String checkoutPayCard(String amount) {
    return 'Place order & pay by card · $amount';
  }

  @override
  String checkoutPlaceCashOrder(String amount) {
    return 'Place order · Pay on delivery · $amount';
  }

  @override
  String get checkoutComingSoon => 'Checkout is coming soon';

  @override
  String get checkoutUnavailable =>
      'Order placement and payments are not available yet. Your basket and checkout choices are saved for this session.';

  @override
  String get ordersEyebrow => 'Your farm-fresh journey';

  @override
  String get ordersTitle => 'My orders';

  @override
  String get ordersSubtitle =>
      'Follow your delivery. Find your favourites again.';

  @override
  String ordersActiveCount(int count) {
    return '$count active';
  }

  @override
  String ordersActiveTab(int count) {
    return 'Active ($count)';
  }

  @override
  String ordersHistoryTab(int count) {
    return 'History ($count)';
  }

  @override
  String get ordersSampleNotice => 'Sample orders · Tracking preview';

  @override
  String get ordersTrackingPreview => 'Tracking preview';

  @override
  String get ordersDeliveryUpdate => 'Delivery update';

  @override
  String ordersReference(String id) {
    return 'Order #$id';
  }

  @override
  String ordersPlacedAt(String day, String time) {
    return 'Placed $day, $time';
  }

  @override
  String get ordersYesterday => 'Yesterday';

  @override
  String get ordersConfirmed => 'Confirmed';

  @override
  String get ordersPacked => 'Packed';

  @override
  String get ordersOnTheWay => 'On the way';

  @override
  String get ordersDelivered => 'Delivered';

  @override
  String get ordersCancelled => 'Cancelled';

  @override
  String ordersStepComplete(String step) {
    return '$step, complete';
  }

  @override
  String ordersArrivingIn(int minutes) {
    return 'Arriving in about $minutes mins';
  }

  @override
  String get ordersDeliveryInProgress => 'Your delivery is in progress';

  @override
  String get ordersCourierPending => 'Finding your delivery partner';

  @override
  String get ordersDeliveryPartner => 'Your delivery partner';

  @override
  String get ordersViewDetails => 'View order details';

  @override
  String get ordersDetailsTitle => 'Order details';

  @override
  String get ordersReceipt => 'Receipt';

  @override
  String ordersDeliveredOn(String day) {
    return 'Delivered · $day';
  }

  @override
  String ordersMoreItems(int count) {
    return '+$count more';
  }

  @override
  String get ordersLeftAtReception => 'Delivered to front desk reception';

  @override
  String get ordersHandedToCustomer => 'Handed to the recipient with care';

  @override
  String get ordersReorder => 'Reorder items';

  @override
  String get ordersReorderAdded =>
      'Items added to your basket. Review before checkout.';

  @override
  String get ordersHistoryTitle => 'Order history';

  @override
  String get ordersRecentPurchases => 'Recent purchases';

  @override
  String get ordersSeeAll => 'See all';

  @override
  String get ordersNoActive => 'All caught up';

  @override
  String get ordersNoActiveDescription =>
      'Your next fresh delivery will appear here.';

  @override
  String get ordersNoHistory => 'Your story starts with a basket';

  @override
  String get ordersNoHistoryDescription =>
      'Your past orders will be saved here for easy reordering.';

  @override
  String get ordersHelpTitle => 'Need a hand with an order?';

  @override
  String get ordersHelpSubtitle =>
      'Delivery, items or payment — find a little guidance.';

  @override
  String get ordersGetHelp => 'Get help';

  @override
  String get ordersHelpDelivery => 'Where is my delivery?';

  @override
  String get ordersHelpDeliveryAnswer =>
      'Open order details to review the delivery address and the latest available status. The progress steps show when your basket is confirmed, packed, on the way and delivered.';

  @override
  String get ordersHelpItems => 'An item is missing or damaged';

  @override
  String get ordersHelpItemsAnswer =>
      'Check the item list in your receipt first. Keep your order number and a photo of any affected items ready when contacting the store.';

  @override
  String get ordersHelpPayment => 'I have a payment question';

  @override
  String get ordersHelpPaymentAnswer =>
      'Your receipt shows the payment method, item total, delivery fee and any discount recorded for the order. Reordering adds items to your basket so you can review current prices before checkout.';

  @override
  String get ordersItemsUnavailable =>
      'These items are no longer available in the current catalog.';

  @override
  String get profileCustomer => 'Fresh food lover';

  @override
  String get profileGuestBadge => 'A little fresher, every day';

  @override
  String get profileMemberBadge => 'Supporting local, together';

  @override
  String get profileOrdersMade => 'Orders made';

  @override
  String get profileSavedFavorites => 'Saved favorites';

  @override
  String get profileCommunity => 'Shopping & community';

  @override
  String get profileFavorites => 'My favorite products';

  @override
  String get profileFavoritesHint => 'Your fresh finds, all in one place';

  @override
  String get profileFavoritesEmpty => 'Your next favorite is waiting';

  @override
  String get profileFavoritesEmptyHint =>
      'Tap the heart on a product to keep it here for your next visit.';

  @override
  String get profileExplore => 'Explore fresh finds';

  @override
  String get profileRemoveFavorite => 'Remove from favorites';

  @override
  String get profileDelivery => 'Delivery details';

  @override
  String get profileDeliveryHint =>
      'Set your address and recipient for checkout';

  @override
  String get profilePayment => 'Preferred payment';

  @override
  String get profilePaymentHint =>
      'Choose your default for this visit. Payment is completed at checkout when ordering is available.';

  @override
  String get profilePreferences => 'Preferences & language';

  @override
  String get profileLanguageHint => 'Make yourself at home';

  @override
  String get profileSupport => 'Support & peace of mind';

  @override
  String get profileHelp => 'Help & support';

  @override
  String get profileHelpHint => 'Answers about delivery, products & payments';

  @override
  String get profileSourcing => 'From farm to your table';

  @override
  String get profileSourcingHint => 'Get to know your fresh food';

  @override
  String get profileSourcingBody =>
      'Explore each product to see its farm origin, pack sizes and product information. Supplier and certification details should be checked on the product listing when available. The current catalog includes demonstration content.';

  @override
  String get profilePrivacy => 'Your account & privacy';

  @override
  String get profilePrivacyHint => 'How sign-in and your basket work';

  @override
  String get profilePrivacyBody =>
      'You can browse and build a basket before signing in. Your basket is saved on this device. Sign-in is required at checkout. Remember me keeps your session across app restarts; signing out ends the session on this device. Favorites and delivery preferences currently last for this app session.';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileDisplayName => 'Display name';

  @override
  String get profileEditHint =>
      'Manage your personal details and the accounts you use to sign in.';

  @override
  String get profileNameRequired => 'Enter your name.';

  @override
  String get profileSave => 'Save changes';

  @override
  String get profileSaved => 'Your profile has been updated.';

  @override
  String get profileSaveError =>
      'We couldn’t save your profile. Please try again.';

  @override
  String get profileFooter => 'Fresh from Cambodian farms to your door';

  @override
  String profileVersion(String version) {
    return 'Phsar Fresh · Version $version';
  }

  @override
  String get profileGuestCta => 'Sign in to make it yours';

  @override
  String get profileEmail => 'Email address';

  @override
  String get profileNotAdded => 'Not added';

  @override
  String get profileChangePhone => 'Change phone number';

  @override
  String get profileChangeEmail => 'Change email address';

  @override
  String get profilePhoneChangeHint =>
      'Enter your new Cambodian mobile number. We’ll send a code to confirm it before changing your sign-in number.';

  @override
  String get profileEmailChangeHint =>
      'We’ll send a confirmation link to your new email. If you already have an email on this account, you may need to confirm from both inboxes.';

  @override
  String get profileInvalidEmail => 'Enter a valid email address.';

  @override
  String get profileSameContact => 'Enter a different phone number or email.';

  @override
  String get profileNewPhone => 'New phone number';

  @override
  String get profileNewEmail => 'New email address';

  @override
  String get profileSendConfirmation => 'Send confirmation';

  @override
  String get profileEmailSent =>
      'Check your email for the confirmation link. Return here after confirming to check the update.';

  @override
  String get profilePhoneSent =>
      'Enter the SMS code sent to your new phone number. Your current number stays active until verification is complete.';

  @override
  String get profileContactUpdated => 'Your contact details have been updated.';

  @override
  String get profileContactError =>
      'We couldn’t update your contact details. Please try again.';

  @override
  String get profileCodeError =>
      'We couldn’t verify this code. Check the code or request a new one.';

  @override
  String get profileCheckStatus => 'Check status';

  @override
  String get profileStillPending =>
      'Still waiting for confirmation. Check your messages and try again.';

  @override
  String get profilePending => 'Pending confirmation';

  @override
  String get profileVerifyPhone => 'Verify new number';

  @override
  String get profileUseDifferentContact => 'Use a different phone or email';

  @override
  String get profileResendConfirmation => 'Resend confirmation';

  @override
  String get profileLinkedAccounts => 'Linked accounts';

  @override
  String get profileLinkedAccountsHint =>
      'Link Google or Facebook to sign in to this same Phsar Fresh account.';

  @override
  String get profileLinkAccount => 'Link account';

  @override
  String get profileConnected => 'Connected';

  @override
  String get profileNotLinked => 'Not linked';

  @override
  String get profileFinishLinking =>
      'Complete the connection in your browser, then return here. An account is connected only after confirmation.';

  @override
  String get profileLinkError =>
      'We couldn’t link this account. Please try again.';

  @override
  String get profileLinkUnavailable =>
      'Account linking is currently unavailable. Please try again later.';

  @override
  String get profileIdentityInUse =>
      'This Google or Facebook account is already linked to another account.';

  @override
  String get profileLinkNotComplete =>
      'The connection isn’t complete yet. You can try linking again.';

  @override
  String get profileMoreVerification =>
      'This code was accepted. If another confirmation code was sent to your current number, enter that code to finish the change.';

  @override
  String get authSocialPending =>
      'Finish signing in in your browser, then return to the app.';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profileChoosePhoto => 'Choose from photos';

  @override
  String get profileTakePhoto => 'Take a photo';

  @override
  String get profileRemovePhoto => 'Remove photo';

  @override
  String get profilePhotoHint =>
      'Choose a clear photo. Your changes are saved when you tap Save changes.';

  @override
  String get profileCropPhoto => 'Adjust your photo';

  @override
  String get profileCropHint =>
      'Drag to position your photo and pinch or use the slider to zoom. The circle shows how it will appear on your profile.';

  @override
  String get profilePhotoZoom => 'Photo zoom';

  @override
  String get profileResetCrop => 'Reset crop';

  @override
  String get profileUsePhoto => 'Use this photo';

  @override
  String get profilePhotoInvalid =>
      'We couldn’t open this photo. Choose a different image under 10 MB.';

  @override
  String get profilePhotoPermission =>
      'Photo or camera access is unavailable. Allow access in your device settings, then try again.';

  @override
  String get profilePhotoUnavailable =>
      'Photo selection is unavailable. Close and reopen the app, then try again.';

  @override
  String get profilePhotoPickerError =>
      'We couldn’t open the photo picker. Please try again.';

  @override
  String get profileCameraUnavailable =>
      'No camera is available on this device. Choose a photo from your library.';

  @override
  String get profilePhotoSaveError =>
      'We couldn’t finish saving your photo. Please try again.';

  @override
  String get locationMapHint =>
      'Tap the map to place your delivery pin, or use your current location.';

  @override
  String get locationUseCurrent => 'Use my location';

  @override
  String get locationFinding => 'Finding your location…';

  @override
  String locationLiveAccuracy(int meters) {
    return 'Live location · accuracy about $meters m';
  }

  @override
  String get locationPermissionDenied =>
      'Location access was denied. You can try again or choose a pin on the map.';

  @override
  String get locationPermissionBlocked =>
      'Allow location access in your device settings, or choose a pin on the map.';

  @override
  String get locationServicesDisabled =>
      'Turn on your device’s location services, or choose a pin on the map.';

  @override
  String get locationUnavailable =>
      'We couldn’t get your location. Try again or choose a pin on the map.';

  @override
  String get locationOpenSettings => 'Open settings';

  @override
  String get locationSearch => 'Find address on map';

  @override
  String get locationSearchFailed =>
      'We couldn’t find this address. Try a nearby landmark or place the pin yourself.';

  @override
  String get locationChooseOnMap => 'Choose on map';

  @override
  String get locationSaveError =>
      'We couldn’t save your location. Please try again.';

  @override
  String get locationMapUnavailable =>
      'The map is unavailable right now. You can still use your location or enter an address.';

  @override
  String get addressDetailsTitle => 'Address details';

  @override
  String get addressDetailsHint =>
      'Optional details to help your driver find your door.';

  @override
  String get addressSaveAs => 'Label this address';

  @override
  String get addressHome => 'Home';

  @override
  String get addressWork => 'Work';

  @override
  String get addressPartner => 'Partner';

  @override
  String get addressOther => 'Other';

  @override
  String get addressCustomLabel => 'Custom label';

  @override
  String get addressCustomLabelRequired => 'Enter a name for this address.';

  @override
  String get addressHouseNumber => 'House / building no.';

  @override
  String get addressStreet => 'Street';

  @override
  String get addressNote => 'Address notes';

  @override
  String get addressNoteHint => 'Floor, gate, nearby landmark or directions';

  @override
  String get cartVoucherHintRemote =>
      'Have a promo code? Enter it to save on your basket.';

  @override
  String get cartVoucherExpired => 'This code has expired.';

  @override
  String get cartVoucherNotStarted => 'This code can\'t be used yet.';

  @override
  String cartVoucherMinOrder(String amount) {
    return 'This code needs a basket of at least $amount.';
  }

  @override
  String get cartVoucherCheckFailed =>
      'Couldn\'t check the code. Check your connection and try again.';

  @override
  String cartVoucherAddMore(String amount, String code) {
    return 'Add $amount more to use $code.';
  }

  @override
  String get cartVoucherLoginRequired => 'Sign in to use this code.';

  @override
  String get cartVoucherNotNewCustomer =>
      'This code is for your first order only.';

  @override
  String get cartVoucherAlreadyUsed => 'You\'ve already used this code.';

  @override
  String get checkoutPlacing => 'Placing your order…';

  @override
  String get checkoutNeedLocationTitle => 'Where should we deliver?';

  @override
  String get checkoutNeedLocation =>
      'Pin your delivery location on the map so the driver can find you.';

  @override
  String get orderSuccessTitle => 'Order placed!';

  @override
  String get orderSuccessBody =>
      'Thank you! The market team is getting your fresh basket ready.';

  @override
  String get orderSuccessCode => 'Order number';

  @override
  String get orderSuccessTrack => 'Track my order';

  @override
  String get checkoutOrderPlacedTitle => 'Order placed';

  @override
  String checkoutOrderPlaced(String code, String total) {
    return 'Thank you! Your order $code for $total is on its way to the market team.';
  }

  @override
  String get checkoutOrderFailedTitle => 'Couldn\'t place your order';

  @override
  String get checkoutOrderFailed =>
      'Something went wrong. Check your connection and try again.';

  @override
  String get checkoutSignInToOrder =>
      'Sign in to your account to place an order.';

  @override
  String checkoutVoucherRemoved(String reason) {
    return '$reason We removed the code — check your new total and place the order again.';
  }

  @override
  String get khqrTitle => 'Pay with ABA KHQR';

  @override
  String khqrOrder(String code) {
    return 'Order $code';
  }

  @override
  String get khqrScanHint =>
      'Scan with Bakong App or Mobile Banking app that supports KHQR';

  @override
  String get khqrOpenAba => 'Open ABA Mobile';

  @override
  String get khqrAbaMissing =>
      'ABA Mobile isn\'t installed on this phone. Scan the QR with another phone or bank app.';

  @override
  String get khqrWaiting => 'Waiting for payment';

  @override
  String khqrExpiresIn(String time) {
    return 'expires in $time';
  }

  @override
  String get khqrExpired => 'This QR has expired.';

  @override
  String get khqrFailed => 'The payment didn\'t go through.';

  @override
  String get khqrNewQr => 'Get a new QR';

  @override
  String get khqrError => 'Couldn\'t create the ABA KHQR.';

  @override
  String get khqrTryAgain => 'Try again';

  @override
  String get khqrPaidTitle => 'Payment received';

  @override
  String khqrPaidBody(String code) {
    return 'Thank you! Order $code is paid and the market team is preparing it.';
  }

  @override
  String get khqrDone => 'Done';

  @override
  String get khqrLeaveTitle => 'Leave without paying?';

  @override
  String get khqrLeaveBody =>
      'Your order is saved, but we only start preparing it once it\'s paid.';

  @override
  String get khqrStay => 'Stay and pay';

  @override
  String get khqrLeave => 'Leave';

  @override
  String get khqrTestModeNote =>
      'Test mode: this QR is not real and no money moves.';

  @override
  String get khqrSimulatePay => 'Simulate payment (test)';

  @override
  String get ordersAwaitingPayment => 'Waiting for payment';

  @override
  String get ordersPaymentNeeded =>
      'Pay with ABA KHQR and we\'ll start preparing it';

  @override
  String get ordersPayNow => 'Pay now';

  @override
  String get ordersSignInTitle => 'Sign in to see your orders';

  @override
  String get ordersSignInBody =>
      'Your orders and delivery updates show up here once you\'re signed in.';

  @override
  String get ordersLoadFailed => 'Couldn\'t load your orders';

  @override
  String get ordersLoadFailedBody =>
      'Check your connection, then try again or pull down to refresh.';

  @override
  String get ordersRetry => 'Try again';
}
