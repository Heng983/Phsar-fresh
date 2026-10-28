// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get authServicesPaused =>
      'សេវាគណនីមិនទាន់អាចប្រើបានទេ។ អ្នកនៅតែអាចមើលទំនិញ និងសាកល្បងការទូទាត់បាន។';

  @override
  String get marketChat => 'ជជែក AI';

  @override
  String get chatTitle => 'មីងស្រស់';

  @override
  String get chatSubtitle => 'ជំនួយការទិញទំនិញរបស់អ្នក';

  @override
  String get chatWelcomeTitle => 'គំនិតថ្មីៗ\nចាប់ផ្តើមនៅទីនេះ។';

  @override
  String get chatWelcomeBody => 'រកកសិផលស្រស់ គំនិតម្ហូប និងជំនួយទិញទំនិញ។';

  @override
  String get chatSuggestionsTitle => 'ចាប់ផ្តើមជាមួយគំនិតមួយ';

  @override
  String get chatFreshLabel => 'កសិផលស្រស់';

  @override
  String get chatMealsLabel => 'គំនិតម្ហូប';

  @override
  String get chatFreshPrompt => 'ថ្ងៃនេះមានអ្វីស្រស់ខ្លះ?';

  @override
  String get chatMealsPrompt => 'ជួយខ្ញុំរៀបចំមុខម្ហូប';

  @override
  String get chatInputHint => 'ផ្ញើសារទៅ មីងស្រស់…';

  @override
  String get chatSend => 'ផ្ញើសារ';

  @override
  String get chatReplyReceived => 'បានទទួលចម្លើយ';

  @override
  String get chatNewConversation => 'ការសន្ទនាថ្មី';

  @override
  String get chatServiceUnavailable =>
      'ការជជែកមិនទាន់អាចប្រើបានទេ។ សូមព្យាយាមម្ដងទៀតនៅពេលក្រោយ។';

  @override
  String get chatConnectionError =>
      'មិនអាចភ្ជាប់បានទេ។ សូមពិនិត្យអ៊ីនធឺណិត ហើយព្យាយាមម្ដងទៀត។';

  @override
  String get chatRequestError => 'មិនអាចទទួលចម្លើយបានទេ។ សូមព្យាយាមម្ដងទៀត។';

  @override
  String get chatRateLimited =>
      'អ្នកកំពុងផ្ញើសារលឿនពេក។ សូមរង់ចាំបន្តិច រួចព្យាយាមម្ដងទៀត។';

  @override
  String get chatInvalidResponse =>
      'មិនអាចបង្ហាញចម្លើយបានទេ។ សូមព្យាយាមម្ដងទៀត។';

  @override
  String get chatRetry => 'ព្យាយាមម្ដងទៀត';

  @override
  String get chatThinking => 'មីងស្រស់កំពុងគិត…';

  @override
  String get chatOutOfStock => 'អស់ពីស្តុក';

  @override
  String chatRecipeTitle(String dish) {
    return 'គ្រឿងផ្សំសម្រាប់ $dish';
  }

  @override
  String chatRecipeServings(int count) {
    return 'សម្រាប់ $count នាក់';
  }

  @override
  String get chatRecipeNotSold => 'មិនមានលក់នៅផ្សារស្រស់ទេ';

  @override
  String get chatDemoNotice => 'សាកល្បង · ចម្លើយ និងទំនិញគំរូ';

  @override
  String get chatDemoGreeting =>
      'សួស្តី! ខ្ញុំមីងស្រស់។ ខ្ញុំអាចណែនាំមុខម្ហូប បញ្ជីគ្រឿងផ្សំ និងរបៀបធ្វើម្ហូបងាយៗ។ តើអ្នកចង់សាកល្បងអ្វី?';

  @override
  String get chatDemoMealReply =>
      'តើអ្នកចង់ញ៉ាំបាយជាមួយបន្លែឆា និងស៊ុតទេ? នេះជាគ្រឿងផ្សំដែលត្រូវការ។ ចុចលើគ្រឿងផ្សំដើម្បីមើលទំនិញគំរូ ឬសួរខ្ញុំអំពីរបៀបធ្វើ។';

  @override
  String get chatDemoIngredientsReply =>
      'សម្រាប់បាយជាមួយបន្លែឆា និងស៊ុត អ្នកត្រូវការ៖';

  @override
  String get chatDemoFreshReply =>
      'នេះជាទំនិញគំរូមួយចំនួនពីផ្សាររបស់យើង។ ចុចលើទំនិញដើម្បីមើលព័ត៌មាន និងសាកល្បងបន្ថែមទៅកន្ត្រក។';

  @override
  String get chatDemoRecipeReply =>
      'បាយជាមួយបន្លែឆា និងស៊ុត\nសម្រាប់ ២ នាក់\n\n១. លាងអង្ករ ១ ពែង ហើយដាំតាមការណែនាំលើកញ្ចប់។\n២. លាង និងកាត់បន្លែ។ កម្ដៅប្រេងបន្តិចក្នុងខ្ទះ រួចឆាបន្លែឱ្យឆ្អិន។ បន្ថែមគ្រឿងទេសតាមចំណូលចិត្ត។\n៣. ចៀន ឬឆាស៊ុត ២ គ្រាប់ឱ្យឆ្អិនល្អ។\n៤. ដាក់បន្លែ និងស៊ុតលើបាយ រួចរីករាយជាមួយអាហារ!';

  @override
  String get chatDemoLokLakReply =>
      'សម្រាប់សាច់គោឡុកឡាក់ អ្នកត្រូវការ៖\n\n• សាច់គោ\n• ទឹកស៊ីអ៊ីវ\n• ទឹកប្រេងខ្យង\n• ខ្ទឹមស\n• ម្រេចខ្មៅ\n• សាឡាត់\n• ប៉េងប៉ោះ\n• ខ្ទឹមបារាំង\n• ក្រូចឆ្មារ\n\nសួរខ្ញុំអំពីរបៀបធ្វើបន្តបាន!';

  @override
  String get chatDemoLokLakRecipe =>
      'សាច់គោឡុកឡាក់\nសម្រាប់ ២ នាក់\n\n១. កាត់សាច់គោ ៣០០ ក្រាមជាដុំតូចៗ។ ប្រឡាក់ជាមួយទឹកស៊ីអ៊ីវ ១ ស្លាបព្រាបាយ ទឹកប្រេងខ្យង ១ ស្លាបព្រាបាយ ខ្ទឹមសចិញ្ច្រាំ ២ កំពឹស និងម្រេចខ្មៅ។ ទុកចោល ១៥ នាទី។\n២. រៀបសាឡាត់ ប៉េងប៉ោះ និងខ្ទឹមបារាំងដែលលាងរួចលើចាន។\n៣. កម្ដៅប្រេងបន្តិចក្នុងខ្ទះ ហើយឆាសាច់គោម្ដងបន្តិចៗឱ្យឆ្អិនតាមចំណូលចិត្ត។\n៤. ដាក់សាច់លើបន្លែ ហើយបរិភោគជាមួយបាយ។ លាយទឹកក្រូចឆ្មារជាមួយម្រេចសម្រាប់ជ្រលក់។';

  @override
  String get chatDemoThanks =>
      'មិនអីទេ! តើអ្នកចង់បានគំនិតម្ហូបផ្សេងទៀត កសិផលស្រស់ ឬរបៀបធ្វើម្ហូបទេ?';

  @override
  String get chatDeliveryReply =>
      'ចូលផ្នែករុករក ឬប្រភេទ រួចចុចទីតាំងនៅផ្នែកខាងលើ ដើម្បីជ្រើសរើសអាសយដ្ឋានដឹកជញ្ជូន។ ប្រើផែនទី ស្វែងរក ឬបញ្ចូលអាសយដ្ឋាន រួចរក្សាទុក។ អ្នកអាចពិនិត្យអាសយដ្ឋាន និងជម្រើសដឹកជញ្ជូនក្នុងការទូទាត់។';

  @override
  String get chatOrdersReply =>
      'ចុចការបញ្ជាទិញនៅរបាររុករក ដើម្បីមើលការបញ្ជាទិញកំពុងដំណើរការ និងប្រវត្តិការបញ្ជាទិញ។ ការសាកល្បងនេះមិនអាចស្វែងរក ឬកែប្រែការបញ្ជាទិញបានទេ។ សម្រាប់សំណួរទូទៅ អ្នកក៏អាចរកជំនួយនៅក្នុងប្រវត្តិរូប។';

  @override
  String get chatFallbackReply =>
      'ក្នុងការសាកល្បងនេះ ខ្ញុំអាចណែនាំមុខម្ហូប គ្រឿងផ្សំ របៀបធ្វើម្ហូប កសិផលស្រស់ និងជួយឆ្លើយសំណួរអំពីការទិញទំនិញ។ សាកល្បងសួរ «ជួយខ្ញុំរៀបចំមុខម្ហូប» ឬ «តើខ្ញុំត្រូវការគ្រឿងផ្សំអ្វីខ្លះ?»។';

  @override
  String get appName => 'ផ្សារស្រស់';

  @override
  String get appNameKhmer => 'Phsar Fresh';

  @override
  String get farmFresh => 'ស្រស់ និងក្នុងស្រុក';

  @override
  String get heroDescription =>
      'កសិផលស្រស់ និងទំនិញប្រចាំថ្ងៃ មកពីទូទាំងកម្ពុជា';

  @override
  String get mainTitle => 'ផ្សារស្រស់';

  @override
  String get mainSubtitle => 'ផ្សារស្រស់របស់អ្នក\nដឹកដល់ផ្ទះ';

  @override
  String get khmerTagline => 'ផ្សារស្រស់ • ស្រស់ៗ ដឹកដល់ផ្ទះ';

  @override
  String get mainDescription =>
      'បន្លែ ផ្លែឈើ សាច់ គ្រឿងសមុទ្រ និងទំនិញប្រចាំថ្ងៃ ជ្រើសរើសស្រស់ៗ ហើយដឹកដល់មាត់ទ្វារផ្ទះអ្នក។';

  @override
  String get organicTitle => 'ពិនិត្យគុណភាពគ្រប់ការបញ្ជាទិញ';

  @override
  String get organicDescription =>
      'ក្រុមការងាររបស់យើងជ្រើសរើស និងពិនិត្យទំនិញនីមួយៗ មុនវេចខ្ចប់ជូនអ្នក។';

  @override
  String get gapBadge => 'កម្ពុជា GAP';

  @override
  String get deliveryTitle => 'ដឹកជញ្ជូនដល់ផ្ទះ';

  @override
  String get deliveryDescription =>
      'វេចខ្ចប់យ៉ាងយកចិត្តទុកដាក់ ដើម្បីរក្សាភាពស្រស់ ហើយដឹកជូនអ្នកផ្ទាល់។';

  @override
  String get deliveryTime => '30 នាទី';

  @override
  String get fairTradeTitle => 'គាំទ្រកសិករក្នុងស្រុក';

  @override
  String get fairTradeDescription =>
      'យើងទិញពីកសិដ្ឋាន និងអ្នកផលិតកម្ពុជា នៅពេលណាដែលអាចធ្វើបាន។';

  @override
  String get getStarted => 'ចាប់ផ្តើម';

  @override
  String get alreadyAccount => 'មានគណនីរួចហើយ?';

  @override
  String get signIn => 'ចូលគណនី';

  @override
  String get farmFooter => 'ភាពស្រស់ពីកម្ពុជា ទិញបានយ៉ាងងាយស្រួល';

  @override
  String get authEyebrow => 'គ្រឿងទេសស្រស់ ដឹកដល់ផ្ទះ';

  @override
  String get authWelcome => 'សូមស្វាគមន៍មកកាន់ផ្សារស្រស់';

  @override
  String get authFreshProduce => 'កសិផលក្នុងស្រុកស្រស់ៗ';

  @override
  String get authKhmerName => 'ផ្សារស្រស់';

  @override
  String get authDescription =>
      'ទិញកសិផលស្រស់ ម្រេចកំពត និងទំនិញប្រចាំថ្ងៃ ដឹកដល់មាត់ទ្វារផ្ទះអ្នក។';

  @override
  String get authRegister => 'ចុះឈ្មោះ';

  @override
  String get authPhoneNumber => 'លេខទូរស័ព្ទ';

  @override
  String get authPhoneHint => 'បញ្ចូលលេខទូរស័ព្ទ';

  @override
  String get authPassword => 'ពាក្យសម្ងាត់';

  @override
  String get authPasswordHint => 'បញ្ចូលពាក្យសម្ងាត់';

  @override
  String get authUseOtp => 'ប្រើ OTP';

  @override
  String get authUsePassword => 'ប្រើពាក្យសម្ងាត់';

  @override
  String get authOtpCode => 'លេខកូដផ្ទៀងផ្ទាត់';

  @override
  String get authOtpHint => 'បញ្ចូលលេខកូដ 6 ខ្ទង់';

  @override
  String get authSendCode => 'ផ្ញើលេខកូដ';

  @override
  String get authVerifyCode => 'ផ្ទៀងផ្ទាត់ និងចូលគណនី';

  @override
  String get authShowPassword => 'បង្ហាញពាក្យសម្ងាត់';

  @override
  String get authHidePassword => 'លាក់ពាក្យសម្ងាត់';

  @override
  String get authConfirmPassword => 'បញ្ជាក់ពាក្យសម្ងាត់';

  @override
  String get authConfirmPasswordHint => 'បញ្ចូលពាក្យសម្ងាត់ម្ដងទៀត';

  @override
  String get authRememberMe => 'ចងចាំខ្ញុំ';

  @override
  String get authForgotPassword => 'ភ្លេចពាក្យសម្ងាត់?';

  @override
  String get authLoginToShop => 'ចូលគណនីដើម្បីទិញ';

  @override
  String get authCreateAccount => 'បង្កើតគណនី';

  @override
  String get authContinueWith => 'ឬបន្តជាមួយ';

  @override
  String get authContinueGoogle => 'បន្តជាមួយ Google';

  @override
  String get authContinueFacebook => 'បន្តជាមួយ Facebook';

  @override
  String get authContinueApple => 'បន្តជាមួយ Apple';

  @override
  String get authAgreementPrefix => 'ការបន្តមានន័យថាអ្នកយល់ព្រមនឹង';

  @override
  String get authAgreementAnd => 'និង';

  @override
  String get authAgreementSuffix => 'របស់ផ្សារស្រស់កម្ពុជា។';

  @override
  String get authTerms => 'លក្ខខណ្ឌសេវាកម្ម';

  @override
  String get authPrivacy => 'គោលការណ៍ឯកជនភាព';

  @override
  String get authSupport => 'ត្រូវការជំនួយ? ទាក់ទងសេវាអតិថិជនតាម Telegram';

  @override
  String get authInvalidPhone => 'សូមបញ្ចូលលេខទូរស័ព្ទកម្ពុជាដែលត្រឹមត្រូវ។';

  @override
  String get authRequiredPassword => 'សូមបញ្ចូលពាក្យសម្ងាត់។';

  @override
  String get authShortPassword => 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងតិច 8 តួអក្សរ។';

  @override
  String get authPasswordMismatch => 'ពាក្យសម្ងាត់មិនត្រូវគ្នាទេ។';

  @override
  String get authInvalidOtp => 'សូមបញ្ចូលលេខកូដផ្ទៀងផ្ទាត់ 6 ខ្ទង់។';

  @override
  String get authUnavailable =>
      'សេវានេះមិនទាន់អាចប្រើបានទេ។ សូមព្យាយាមម្ដងទៀតនៅពេលក្រោយ។';

  @override
  String get authOtpSignInHelp =>
      'ប្រើលេខកូដ SMS ដើម្បីចូលគណនីដោយមិនចាំបាច់ប្រើពាក្យសម្ងាត់។';

  @override
  String get authServiceError =>
      'សេវាផ្ទៀងផ្ទាត់គណនីមិនអាចបំពេញសំណើរបស់អ្នកបានទេ។ សូមព្យាយាមម្ដងទៀតនៅពេលក្រោយ។';

  @override
  String get authUnexpectedError => 'មានបញ្ហាកើតឡើង។ សូមព្យាយាមម្ដងទៀត។';

  @override
  String get authConnectionError =>
      'មិនអាចភ្ជាប់បានទេ។ សូមពិនិត្យការតភ្ជាប់អ៊ីនធឺណិត រួចព្យាយាមម្ដងទៀត។';

  @override
  String get authNoSession => 'មិនអាចចូលគណនីបានទេ។ សូមព្យាយាមម្ដងទៀត។';

  @override
  String get authInvalidCredentials =>
      'លេខទូរស័ព្ទ ឬពាក្យសម្ងាត់មិនត្រឹមត្រូវ។';

  @override
  String get authInvalidCode =>
      'លេខកូដមិនត្រឹមត្រូវ ឬផុតកំណត់ហើយ។ សូមពិនិត្យសារ SMS ឬស្នើលេខកូដថ្មី។';

  @override
  String get authPhoneInUse =>
      'លេខទូរស័ព្ទនេះបានចុះឈ្មោះរួចហើយ។ សូមចូលគណនីជំនួសវិញ។';

  @override
  String get authTooManyAttempts =>
      'ព្យាយាមច្រើនដងពេក។ សូមរង់ចាំមួយនាទី រួចព្យាយាមម្ដងទៀត។';

  @override
  String get authPhoneConfirmationRequired =>
      'សូមផ្ទៀងផ្ទាត់លេខទូរស័ព្ទដើម្បីបន្ត។ ចុចផ្ញើលេខកូដ ដើម្បីទទួល SMS ថ្មី។';

  @override
  String get authCheckoutTitle => 'បន្តទៅទូទាត់ប្រាក់';

  @override
  String get authCheckoutDescription =>
      'ចូលគណនី ឬបង្កើតគណនីដោយប្រើលេខទូរស័ព្ទរបស់អ្នក។ កន្ត្រករបស់អ្នកត្រូវបានរក្សាទុក។';

  @override
  String get authOtpWelcome => 'នៅសល់តែមួយជំហានទៀត អ្នកអាចចាប់ផ្តើមទិញបាន។';

  @override
  String get authOtpInstructions =>
      'សូមបញ្ចូលលេខកូដ 6 ខ្ទង់ដែលបានផ្ញើទៅទូរស័ព្ទរបស់អ្នក ដើម្បីបន្ត។';

  @override
  String get authDidNotReceiveCode => 'មិនបានទទួលលេខកូដមែនទេ?';

  @override
  String get authEnterVerificationCode => 'បញ្ចូលលេខកូដផ្ទៀងផ្ទាត់របស់អ្នក';

  @override
  String get authResendCode => 'ផ្ញើលេខកូដម្ដងទៀត';

  @override
  String get authChangeNumber => 'ប្ដូរលេខទូរស័ព្ទ';

  @override
  String get authVerifyPhone => 'ផ្ទៀងផ្ទាត់លេខទូរស័ព្ទរបស់អ្នក';

  @override
  String authCodeSent(String phone) {
    return 'យើងបានផ្ញើលេខកូដផ្ទៀងផ្ទាត់ទៅ $phone។ សូមបញ្ចូលលេខកូដខាងក្រោមដើម្បីបន្ត។';
  }

  @override
  String authResendIn(int seconds) {
    return 'ផ្ញើម្ដងទៀតក្នុង $seconds វិនាទី';
  }

  @override
  String get authAccountDescription => 'អ្នកបានចូលគណនីផ្សារស្រស់។';

  @override
  String get authSignOut => 'ចាកចេញពីគណនី';

  @override
  String get marketBrowseGuest => 'ទស្សនាជាភ្ញៀវ';

  @override
  String get marketBrand => 'ផ្សារស្រស់';

  @override
  String get marketNotifications => 'ការជូនដំណឹង';

  @override
  String get notificationsEmptyTitle => 'មិនទាន់មានការជូនដំណឹងថ្មីទេ';

  @override
  String get notificationsEmptyBody =>
      'ព័ត៌មានថ្មីៗអំពីការបញ្ជាទិញ និងប្រូម៉ូសិននឹងបង្ហាញនៅទីនេះ។';

  @override
  String get notificationsPromotion => 'ប្រូម៉ូសិនថ្មី';

  @override
  String get notificationOrderPlacedTitle => 'បានដាក់ការបញ្ជាទិញ';

  @override
  String notificationOrderPlacedBody(String code) {
    return 'យើងបានទទួលការបញ្ជាទិញ $code ហើយ។ យើងនឹងជូនដំណឹងនៅពេលចាប់ផ្តើមរៀបចំ។';
  }

  @override
  String get notificationOrderPaidTitle => 'បានទទួលការបង់ប្រាក់';

  @override
  String notificationOrderPaidBody(String code) {
    return 'ការបញ្ជាទិញ $code បានបង់រួច។ ក្រុមផ្សារនឹងចាប់ផ្តើមរៀបចំ។';
  }

  @override
  String get notificationOrderPreparingTitle => 'កំពុងរៀបចំការបញ្ជាទិញ';

  @override
  String notificationOrderPreparingBody(String code) {
    return 'ការបញ្ជាទិញ $code កំពុងត្រូវបានវេចខ្ចប់ជាមួយផលិតផលស្រស់ៗ។';
  }

  @override
  String get notificationOrderDeliveringTitle => 'កំពុងដឹកជញ្ជូន';

  @override
  String notificationOrderDeliveringBody(String code) {
    return 'អ្នកដឹកកំពុងនាំយកការបញ្ជាទិញ $code មកជូនអ្នក។';
  }

  @override
  String get notificationOrderDeliveredTitle => 'បានដឹកជញ្ជូនដល់';

  @override
  String notificationOrderDeliveredBody(String code) {
    return 'ការបញ្ជាទិញ $code បានមកដល់ហើយ។ សូមរីករាយ!';
  }

  @override
  String notificationMessageTitle(String code) {
    return 'ព័ត៌មានអំពីការបញ្ជាទិញ $code';
  }

  @override
  String notificationMessageProblemTitle(String code) {
    return 'មានបញ្ហាជាមួយការបញ្ជាទិញ $code';
  }

  @override
  String notificationMessageCancelledTitle(String code) {
    return 'ការបញ្ជាទិញ $code ត្រូវបានលុបចោល';
  }

  @override
  String get notificationOrderCancelledTitle => 'ការបញ្ជាទិញត្រូវបានលុបចោល';

  @override
  String notificationOrderCancelledBody(String code) {
    return 'ការបញ្ជាទិញ $code ត្រូវបានលុបចោល។';
  }

  @override
  String get marketSearchHint => 'ស្វែងរកបន្លែ ផ្លែឈើ និងគ្រឿងទេស';

  @override
  String get marketClearSearch => 'លុបការស្វែងរក';

  @override
  String get marketVoiceSearchHelp =>
      'វាយឈ្មោះផលិតផល ឬប្រភពនៅក្នុងប្រអប់ស្វែងរក។';

  @override
  String get marketFilters => 'តម្រង';

  @override
  String get marketAllItems => 'ទាំងអស់';

  @override
  String get marketFlashDeal => 'ការផ្តល់ជូនថ្ងៃនេះ';

  @override
  String get marketDealTitle => 'បញ្ចុះតម្លៃ 20% លើក្រូចបាត់ដំបង';

  @override
  String get marketClaimDeal => 'ទទួលប្រូម៉ូសិន';

  @override
  String get marketAddedToCart => 'បានដាក់ក្នុងកន្ត្រក';

  @override
  String get marketDealEnded => 'ប្រូម៉ូសិនបានបញ្ចប់';

  @override
  String marketItemCount(int count) {
    return '$count មុខ';
  }

  @override
  String get marketExplore => 'ស្វែងយល់';

  @override
  String get marketCategories => 'ប្រភេទ';

  @override
  String get marketOrders => 'ការបញ្ជាទិញ';

  @override
  String get marketViewCart => 'មើលកន្ត្រក';

  @override
  String get marketCart => 'កន្ត្រក';

  @override
  String get marketProfile => 'គណនី';

  @override
  String get marketSortBy => 'តម្រៀបតាម';

  @override
  String get marketInStockOnly => 'មានក្នុងស្តុកតែប៉ុណ្ណោះ';

  @override
  String get catalogLoadError => 'មិនអាចផ្ទុកផលិតផលបានទេ';

  @override
  String get catalogLoadErrorBody => 'សូមពិនិត្យការតភ្ជាប់ រួចព្យាយាមម្ដងទៀត។';

  @override
  String get catalogRetry => 'ព្យាយាមម្ដងទៀត';

  @override
  String get catalogLoadMore => 'បង្ហាញបន្ថែម';

  @override
  String get catalogOutOfStock => 'អស់ពីស្តុក';

  @override
  String get catalogAllProducts => 'ផលិតផលទាំងអស់';

  @override
  String get catalogNoProductsInCategory =>
      'មិនទាន់មានផលិតផលក្នុងប្រភេទនេះនៅឡើយទេ។';

  @override
  String get marketSortCurated => 'ជ្រើសរើស';

  @override
  String get marketSortName => 'ឈ្មោះ';

  @override
  String get marketSortCount => 'ចំនួនមុខ';

  @override
  String get marketApplyFilters => 'ប្រើតម្រង';

  @override
  String get marketResetFilters => 'កំណត់តម្រងឡើងវិញ';

  @override
  String get marketClose => 'បិទ';

  @override
  String get marketNoResults => 'រកមិនឃើញកសិផល';

  @override
  String get marketNoResultsDescription =>
      'សូមស្វែងរកម្ដងទៀត ឬជ្រើសរើសប្រភេទផ្សេង។';

  @override
  String get marketNoOrders => 'មិនទាន់មានការបញ្ជាទិញ';

  @override
  String get marketNoOrdersDescription =>
      'ការបញ្ជាទិញរបស់អ្នកនឹងបង្ហាញនៅទីនេះក្រោយពេលទិញ។';

  @override
  String get marketContinueShopping => 'បន្តទិញ';

  @override
  String get marketEmptyCart => 'កន្ត្រករបស់អ្នកទទេ';

  @override
  String get marketEmptyCartDescription =>
      'ស្វែងរកផលិតផលស្រស់ៗ ដើម្បីដាក់ក្នុងកន្ត្រក។';

  @override
  String get marketYourBasket => 'កន្ត្រករបស់អ្នក';

  @override
  String get marketSubtotal => 'សរុបរង';

  @override
  String get marketDecreaseQuantity => 'បន្ថយចំនួន';

  @override
  String get marketIncreaseQuantity => 'បន្ថែមចំនួន';

  @override
  String get marketGuest => 'សូមស្វាគមន៍ ភ្ញៀវ';

  @override
  String get marketGuestDescription =>
      'ទស្សនាជាភ្ញៀវ។ ចូលគណនីដើម្បីបញ្ជាទិញ និងគ្រប់គ្រងគណនី។';

  @override
  String get marketLanguage => 'ភាសា';

  @override
  String get marketDeliveryLocation => 'ទីតាំងដឹកជញ្ជូន';

  @override
  String get marketLocationLabel => 'ក្រុង សង្កាត់ ឬអាសយដ្ឋាន';

  @override
  String get marketSaveLocation => 'រក្សាទុកទីតាំង';

  @override
  String get exploreTodayHarvest => 'ការផ្តល់ជូនពិសេសថ្ងៃនេះ';

  @override
  String get exploreWelcome => 'ផលិតផលស្រស់ និងទំនិញប្រចាំថ្ងៃ ដឹកដល់ផ្ទះអ្នក។';

  @override
  String get exploreShopCategories => 'ទិញតាមប្រភេទ';

  @override
  String get exploreFreshArrivals => 'កសិផលទើបមកដល់';

  @override
  String get exploreFreshSubtitle => 'ទំនិញថ្មី និងទំនិញតាមរដូវនៅក្នុងផ្សារ។';

  @override
  String get explorePopular => 'ពេញនិយមសប្តាហ៍នេះ';

  @override
  String get explorePopularSubtitle =>
      'ផលិតផលក្នុងស្រុកសម្រាប់តម្រូវការប្រចាំថ្ងៃ។';

  @override
  String get exploreMingSrosTitle =>
      'ស្គាល់មីងស្រស់ ជំនួយការ AI សម្រាប់ទិញទំនិញ';

  @override
  String get exploreMingSrosBody =>
      'សួរថាគួរចម្អិនអ្វីយប់នេះ ហើយទទួលបានបញ្ជីទិញឥវ៉ាន់ភ្លាមៗ។';

  @override
  String get exploreMingSrosAction => 'សួរមីងស្រស់';

  @override
  String get exploreSeeAll => 'មើលទាំងអស់';

  @override
  String get exploreProducts => 'ទិញកសិផលស្រស់ៗ';

  @override
  String get exploreDiscover => 'ត្រឡប់ទៅស្វែងរក';

  @override
  String get exploreNoProducts => 'រកមិនឃើញផលិតផល';

  @override
  String get exploreAddToCart => 'ដាក់ក្នុងកន្ត្រក';

  @override
  String get exploreOrganic => 'សរីរាង្គ';

  @override
  String get explorePopularFirst => 'ពេញនិយមមុន';

  @override
  String get marketGreensPromotion => 'បញ្ចុះតម្លៃ 20% លើបន្លែសរីរាង្គ';

  @override
  String get marketFruitsPromotion => 'បញ្ចុះតម្លៃ 20% លើផ្លែឈើត្រូពិច';

  @override
  String marketPromotionPosition(int index, int count) {
    return 'ប្រូម៉ូសិន $index ក្នុងចំណោម $count';
  }

  @override
  String get productOrganicFresh => 'សរីរាង្គ និងស្រស់ពីកសិដ្ឋាន';

  @override
  String get productOrigin => 'ប្រភព';

  @override
  String get productViewFarm => 'មើលកសិដ្ឋាន';

  @override
  String get productPackSize => 'ទំហំកញ្ចប់';

  @override
  String get productPopular => 'ពេញនិយម';

  @override
  String get product250g => 'កញ្ចប់ ២៥០ ក្រាម';

  @override
  String get product500g => 'កញ្ចប់ ៥០០ ក្រាម';

  @override
  String get product1kg => 'កញ្ចប់គ្រួសារ ១ គីឡូ';

  @override
  String get productSinglePack => '១ កញ្ចប់';

  @override
  String get productDoublePack => '២ កញ្ចប់';

  @override
  String get productSixEggs => 'ស៊ុត ៦ គ្រាប់';

  @override
  String get productDozenEggs => 'ស៊ុត ១២ គ្រាប់';

  @override
  String get productMoreLikeThis => 'ផលិតផលស្រដៀងគ្នា';

  @override
  String get productQuantity => 'ចំនួន';

  @override
  String get productAddBasket => 'ដាក់ក្នុងកន្ត្រក';

  @override
  String get productSaved => 'រក្សាទុកក្នុងចំណូលចិត្ត';

  @override
  String get productUnsaved => 'ដកចេញពីចំណូលចិត្ត';

  @override
  String get productCopy => 'ចម្លងព័ត៌មានផលិតផល';

  @override
  String get productCopied => 'បានចម្លងព័ត៌មានផលិតផល';

  @override
  String get productFarmStory => 'ពីកសិដ្ឋានទៅផ្ទះបាយរបស់អ្នក';

  @override
  String get productFarmDescription =>
      'កាតាឡុកក្នុងស្រុករបស់យើងបង្ហាញកសិករ និងសហករណ៍កម្ពុជា ជាមួយកសិផលស្រស់សម្រាប់ចម្អិនអាហារប្រចាំថ្ងៃ។';

  @override
  String get cartEyebrow => 'ផលិតផលស្រស់ៗ រួចរាល់សម្រាប់បញ្ជាទិញ';

  @override
  String get cartSubtitle => 'ពិនិត្យទំនិញរបស់អ្នក ហើយទូទាត់នៅពេលរួចរាល់។';

  @override
  String get cartItemRemoved => 'បានដកចេញពីកន្ត្រក';

  @override
  String get commonRemove => 'ដកចេញ';

  @override
  String get commonUndo => 'ត្រឡប់វិញ';

  @override
  String cartRemoveItem(String name) {
    return 'លុប $name ចេញពីកន្ត្រក';
  }

  @override
  String get cartVoucherCode => 'លេខកូដបញ្ចុះតម្លៃ';

  @override
  String cartVoucherHint(String code, String amount) {
    return 'ប្រើ $code ដើម្បីសន្សំរហូតដល់ $amount លើកន្ត្រករបស់អ្នក។';
  }

  @override
  String get cartApplyVoucher => 'ប្រើលេខកូដ';

  @override
  String get cartInvalidVoucher =>
      'លេខកូដនេះមិនត្រឹមត្រូវទេ។ សូមពិនិត្យ ហើយព្យាយាមម្តងទៀត។';

  @override
  String cartVoucherApplied(String code, String amount) {
    return 'បានប្រើ $code (−$amount)';
  }

  @override
  String get cartRemoveVoucher => 'ដកលេខកូដបញ្ចុះតម្លៃ';

  @override
  String get cartPackagingTitle => 'វេចខ្ចប់យ៉ាងយកចិត្តទុកដាក់ រក្សាភាពស្រស់';

  @override
  String get cartPackagingDescription =>
      'ការបញ្ជាទិញនីមួយៗត្រូវបានវេចខ្ចប់យ៉ាងយកចិត្តទុកដាក់ ដើម្បីរក្សាភាពស្រស់។';

  @override
  String get cartOrderSummary => 'សង្ខេបការបញ្ជាទិញ';

  @override
  String get cartVoucherDiscount => 'ការបញ្ចុះតម្លៃ';

  @override
  String get cartDelivery => 'ដឹកជញ្ជូនដែលគិតគូរដល់បរិស្ថាន';

  @override
  String get cartTotalPayable => 'សរុបត្រូវបង់';

  @override
  String get cartFarmerSupport =>
      'ការបញ្ជាទិញនីមួយៗ ជួយគាំទ្រកសិករ និងអាជីវករក្នុងស្រុក។';

  @override
  String get cartCheckout => 'បន្តទៅការទូទាត់';

  @override
  String get marketCurrency => 'រូបិយប័ណ្ណ';

  @override
  String get currencyUsd => 'ដុល្លារអាមេរិក (\$)';

  @override
  String get currencyKhr => 'ប្រាក់រៀល (៛)';

  @override
  String get currencyExchangeRate =>
      'អត្រាបង្ហាញ៖ \$1 = 4,100៛ (អត្រាថេរសម្រាប់សាកល្បង)។';

  @override
  String get currencyConvertedNote => 'តម្លៃបម្លែងប្រហាក់ប្រហែល';

  @override
  String get checkoutTitle => 'ការទូទាត់';

  @override
  String get checkoutDeliveryAddress => 'អាសយដ្ឋានដឹកជញ្ជូន';

  @override
  String get checkoutChange => 'ផ្លាស់ប្តូរ ›';

  @override
  String get checkoutAddRecipient => 'បន្ថែមឈ្មោះ និងលេខទូរសព្ទអ្នកទទួល';

  @override
  String get checkoutLocalFresh => 'វេចខ្ចប់យ៉ាងយកចិត្តទុកដាក់ ដឹកជញ្ជូនស្រស់ៗ';

  @override
  String get checkoutEditAddress => 'ព័ត៌មានដឹកជញ្ជូន';

  @override
  String get checkoutRecipientName => 'ឈ្មោះអ្នកទទួល';

  @override
  String get checkoutNameRequired => 'សូមបញ្ចូលឈ្មោះអ្នកទទួល។';

  @override
  String get checkoutStreetAddress => 'ផ្លូវ លេខផ្ទះ និងតំបន់ដឹកជញ្ជូន';

  @override
  String get checkoutAddressRequired => 'សូមបញ្ចូលអាសយដ្ឋានដឹកជញ្ជូន។';

  @override
  String get checkoutDeliveryWindow => 'ពេលវេលាដឹកជញ្ជូន';

  @override
  String get checkoutFreshlyPrepared => 'រៀបចំថ្មីៗ';

  @override
  String get checkoutExpress => 'រហ័ស (៣០ នាទី)';

  @override
  String checkoutExpressArrives(String time) {
    return 'មកដល់មុនម៉ោង $time';
  }

  @override
  String get checkoutSchedule => 'កំណត់ពេលដឹកជញ្ជូន';

  @override
  String get checkoutScheduleDescription =>
      'ជ្រើសរើសថ្ងៃ និងម៉ោងដែលសមស្របសម្រាប់អ្នក';

  @override
  String checkoutScheduledSlot(String day, String start, String end) {
    return '$day $start – $end';
  }

  @override
  String get checkoutChooseDay => 'ជ្រើសរើសថ្ងៃ';

  @override
  String get checkoutChooseTime => 'ជ្រើសរើសម៉ោង';

  @override
  String get checkoutFastest => 'លឿនបំផុត';

  @override
  String get checkoutToday => 'ថ្ងៃនេះ';

  @override
  String get checkoutTomorrow => 'ថ្ងៃស្អែក';

  @override
  String get checkoutInstructions => 'ការណែនាំពិសេស';

  @override
  String get checkoutInstructionsHint => 'ឧ. ទុកនៅកន្លែងសន្តិសុខមុខផ្ទះ';

  @override
  String get checkoutInstructionsHelp => 'កំណត់សម្គាល់សម្រាប់អ្នកដឹកជញ្ជូន';

  @override
  String get checkoutPaymentMethod => 'វិធីទូទាត់';

  @override
  String get checkoutAbaPay => 'ABA PAY';

  @override
  String get checkoutAbaPayDescription => 'ទូទាត់តាមកម្មវិធី ABA Mobile';

  @override
  String get checkoutAbaPayHint =>
      'ស្កេនលេខកូដ QR តាមកម្មវិធី ABA Mobile ដើម្បីទូទាត់។';

  @override
  String get checkoutCard => 'កាតធនាគារ';

  @override
  String get checkoutCardDescription => 'ទូទាត់តាមកាតឥណពន្ធ ឬកាតឥណទាន';

  @override
  String get checkoutCash => 'បង់ប្រាក់ពេលទទួលទំនិញ';

  @override
  String get checkoutCashDescription => 'បង់ប្រាក់សុទ្ធពេលទទួលទំនិញ';

  @override
  String checkoutItemQuantity(int count, String pack) {
    return 'ចំនួន៖ $count · $pack';
  }

  @override
  String get checkoutDeliveryFee => 'ថ្លៃដឹកជញ្ជូន';

  @override
  String get checkoutPackaging => 'ការវេចខ្ចប់ និងប្រអប់បរិស្ថាន';

  @override
  String get checkoutIncluded => 'រួមបញ្ចូល';

  @override
  String get checkoutTotalDue => 'សរុបទឹកប្រាក់ត្រូវបង់';

  @override
  String get checkoutPayable => 'ទូទាត់ជាដុល្លារ និងប្រាក់រៀល';

  @override
  String checkoutPayAbaPay(String amount) {
    return 'បញ្ជាទិញ និងបង់តាម ABA PAY · $amount';
  }

  @override
  String checkoutPayCard(String amount) {
    return 'បញ្ជាទិញ និងបង់តាមកាត · $amount';
  }

  @override
  String checkoutPlaceCashOrder(String amount) {
    return 'បញ្ជាទិញ · បង់ពេលទទួល · $amount';
  }

  @override
  String get checkoutComingSoon => 'ការទូទាត់នឹងមកដល់ឆាប់ៗ';

  @override
  String get checkoutUnavailable =>
      'ការបញ្ជាទិញ និងការទូទាត់មិនទាន់អាចប្រើបានទេ។ កន្ត្រក និងជម្រើសទូទាត់របស់អ្នកត្រូវបានរក្សាទុកសម្រាប់ការប្រើប្រាស់លើកនេះ។';

  @override
  String get ordersEyebrow => 'ការដឹកជញ្ជូនស្រស់ៗរបស់អ្នក';

  @override
  String get ordersTitle => 'ការបញ្ជាទិញរបស់ខ្ញុំ';

  @override
  String get ordersSubtitle =>
      'តាមដានការដឹកជញ្ជូន និងទិញទំនិញដែលអ្នកចូលចិត្តម្ដងទៀត។';

  @override
  String ordersActiveCount(int count) {
    return 'កំពុងដំណើរការ $count';
  }

  @override
  String ordersActiveTab(int count) {
    return 'កំពុងដំណើរការ ($count)';
  }

  @override
  String ordersHistoryTab(int count) {
    return 'ប្រវត្តិ ($count)';
  }

  @override
  String get ordersSampleNotice => 'ការបញ្ជាទិញគំរូ · ការតាមដានសាកល្បង';

  @override
  String get ordersTrackingPreview => 'ការតាមដានសាកល្បង';

  @override
  String get ordersDeliveryUpdate => 'ព័ត៌មានដឹកជញ្ជូន';

  @override
  String ordersReference(String id) {
    return 'ការបញ្ជាទិញ #$id';
  }

  @override
  String ordersPlacedAt(String day, String time) {
    return 'បានបញ្ជាទិញ $day, $time';
  }

  @override
  String get ordersYesterday => 'ម្សិលមិញ';

  @override
  String get ordersConfirmed => 'បានបញ្ជាក់';

  @override
  String get ordersPacked => 'បានវេចខ្ចប់';

  @override
  String get ordersOnTheWay => 'កំពុងដឹកជញ្ជូន';

  @override
  String get ordersDelivered => 'បានប្រគល់';

  @override
  String get ordersCancelled => 'បានលុបចោល';

  @override
  String ordersStepComplete(String step) {
    return '$step រួចរាល់';
  }

  @override
  String ordersArrivingIn(int minutes) {
    return 'នឹងមកដល់ប្រហែល $minutes នាទីទៀត';
  }

  @override
  String get ordersDeliveryInProgress => 'ការដឹកជញ្ជូនរបស់អ្នកកំពុងដំណើរការ';

  @override
  String get ordersCourierPending => 'កំពុងស្វែងរកអ្នកដឹកជញ្ជូន';

  @override
  String get ordersDeliveryPartner => 'អ្នកដឹកជញ្ជូនរបស់អ្នក';

  @override
  String get ordersViewDetails => 'មើលព័ត៌មានបញ្ជាទិញ';

  @override
  String get ordersDetailsTitle => 'ព័ត៌មានបញ្ជាទិញ';

  @override
  String get ordersReceipt => 'បង្កាន់ដៃ';

  @override
  String ordersDeliveredOn(String day) {
    return 'បានប្រគល់ · $day';
  }

  @override
  String ordersMoreItems(int count) {
    return '+$count ទៀត';
  }

  @override
  String get ordersLeftAtReception => 'បានប្រគល់ទៅកន្លែងទទួលភ្ញៀវ';

  @override
  String get ordersHandedToCustomer => 'បានប្រគល់ជូនអ្នកទទួលដោយយកចិត្តទុកដាក់';

  @override
  String get ordersReorder => 'បញ្ជាទិញម្ដងទៀត';

  @override
  String get ordersReorderAdded =>
      'បានបន្ថែមទំនិញក្នុងកន្ត្រក។ សូមពិនិត្យមុនពេលទូទាត់។';

  @override
  String get ordersHistoryTitle => 'ប្រវត្តិបញ្ជាទិញ';

  @override
  String get ordersRecentPurchases => 'ការទិញថ្មីៗ';

  @override
  String get ordersSeeAll => 'មើលទាំងអស់';

  @override
  String get ordersNoActive => 'មិនមានការដឹកជញ្ជូនកំពុងដំណើរការ';

  @override
  String get ordersNoActiveDescription =>
      'ការដឹកជញ្ជូនបន្ទាប់របស់អ្នកនឹងបង្ហាញនៅទីនេះ។';

  @override
  String get ordersNoHistory => 'ប្រវត្តិរបស់អ្នកចាប់ផ្ដើមពីកន្ត្រកមួយ';

  @override
  String get ordersNoHistoryDescription =>
      'ការបញ្ជាទិញកន្លងមកនឹងត្រូវរក្សាទុកនៅទីនេះ ដើម្បីងាយស្រួលបញ្ជាទិញម្ដងទៀត។';

  @override
  String get ordersHelpTitle => 'ត្រូវការជំនួយអំពីការបញ្ជាទិញមែនទេ?';

  @override
  String get ordersHelpSubtitle =>
      'ស្វែងរកការណែនាំអំពីការដឹកជញ្ជូន ទំនិញ និងការទូទាត់។';

  @override
  String get ordersGetHelp => 'ទទួលជំនួយ';

  @override
  String get ordersHelpDelivery => 'តើការដឹកជញ្ជូនរបស់ខ្ញុំនៅឯណា?';

  @override
  String get ordersHelpDeliveryAnswer =>
      'បើកព័ត៌មានបញ្ជាទិញ ដើម្បីពិនិត្យអាសយដ្ឋាន និងស្ថានភាពចុងក្រោយ។ ជំហានបង្ហាញថាតើកន្ត្រកត្រូវបានបញ្ជាក់ វេចខ្ចប់ កំពុងដឹកជញ្ជូន ឬបានប្រគល់រួច។';

  @override
  String get ordersHelpItems => 'ទំនិញបាត់ ឬខូច';

  @override
  String get ordersHelpItemsAnswer =>
      'សូមពិនិត្យបញ្ជីទំនិញក្នុងបង្កាន់ដៃជាមុន។ រក្សាលេខបញ្ជាទិញ និងរូបថតទំនិញដែលមានបញ្ហា សម្រាប់ពេលទាក់ទងហាង។';

  @override
  String get ordersHelpPayment => 'ខ្ញុំមានសំណួរអំពីការទូទាត់';

  @override
  String get ordersHelpPaymentAnswer =>
      'បង្កាន់ដៃបង្ហាញវិធីទូទាត់ តម្លៃទំនិញ ថ្លៃដឹកជញ្ជូន និងការបញ្ចុះតម្លៃ។ ការបញ្ជាទិញម្ដងទៀតនឹងបន្ថែមទំនិញក្នុងកន្ត្រក ដើម្បីឱ្យអ្នកពិនិត្យតម្លៃបច្ចុប្បន្នមុនទូទាត់។';

  @override
  String get ordersItemsUnavailable =>
      'ទំនិញទាំងនេះលែងមានក្នុងកាតាឡុកបច្ចុប្បន្នហើយ។';

  @override
  String get profileCustomer => 'អ្នកស្រឡាញ់អាហារស្រស់';

  @override
  String get profileGuestBadge => 'កាន់តែស្រស់ ជារៀងរាល់ថ្ងៃ';

  @override
  String get profileMemberBadge => 'រួមគ្នាគាំទ្រកសិករក្នុងស្រុក';

  @override
  String get profileOrdersMade => 'ការបញ្ជាទិញ';

  @override
  String get profileSavedFavorites => 'ចំណូលចិត្តដែលបានរក្សាទុក';

  @override
  String get profileCommunity => 'ការទិញទំនិញ និងសហគមន៍';

  @override
  String get profileFavorites => 'ផលិតផលដែលខ្ញុំពេញចិត្ត';

  @override
  String get profileFavoritesHint => 'ផលិតផលដែលអ្នកចូលចិត្ត នៅកន្លែងតែមួយ';

  @override
  String get profileFavoritesEmpty => 'ផលិតផលពេញចិត្តបន្ទាប់កំពុងរង់ចាំអ្នក';

  @override
  String get profileFavoritesEmptyHint =>
      'ចុចរូបបេះដូងលើផលិតផល ដើម្បីរក្សាទុកនៅទីនេះសម្រាប់លើកក្រោយ។';

  @override
  String get profileExplore => 'ស្វែងរកផលិតផលស្រស់';

  @override
  String get profileRemoveFavorite => 'ដកចេញពីចំណូលចិត្ត';

  @override
  String get profileDelivery => 'ព័ត៌មានដឹកជញ្ជូន';

  @override
  String get profileDeliveryHint =>
      'កំណត់អាសយដ្ឋាន និងអ្នកទទួលសម្រាប់ការទូទាត់';

  @override
  String get profilePayment => 'វិធីទូទាត់ដែលពេញចិត្ត';

  @override
  String get profilePaymentHint =>
      'ជ្រើសរើសវិធីបង់ប្រាក់ដែលអ្នកប្រើជាប្រចាំ។ អ្នកអាចប្តូរវានៅពេលទូទាត់។';

  @override
  String get profilePreferences => 'ការកំណត់ និងភាសា';

  @override
  String get profileLanguageHint => 'ប្រើភាសាដែលអ្នកពេញចិត្ត';

  @override
  String get profileSupport => 'ជំនួយ និងភាពជឿជាក់';

  @override
  String get profileHelp => 'ជំនួយ និងការគាំទ្រ';

  @override
  String get profileHelpHint => 'ចម្លើយអំពីការដឹកជញ្ជូន ផលិតផល និងការទូទាត់';

  @override
  String get profileSourcing => 'អាហាររបស់អ្នកមកពីណា';

  @override
  String get profileSourcingHint => 'ស្វែងយល់អំពីអាហារស្រស់របស់អ្នក';

  @override
  String get profileSourcingBody =>
      'បើកផលិតផលណាមួយ ដើម្បីមើលប្រភព ទំហំកញ្ចប់ និងព័ត៌មានលម្អិត។';

  @override
  String get profilePrivacy => 'គណនី និងឯកជនភាពរបស់អ្នក';

  @override
  String get profilePrivacyHint => 'របៀបចូលគណនី និងរក្សាទុកកន្ត្រក';

  @override
  String get profilePrivacyBody =>
      'អ្នកអាចមើល និងបន្ថែមទំនិញក្នុងកន្ត្រកមុនចូលគណនី។ កន្ត្រកត្រូវបានរក្សាទុកលើឧបករណ៍នេះ។ អ្នកត្រូវចូលគណនីនៅពេលទូទាត់។ ជម្រើសចងចាំខ្ញុំរក្សាការចូលគណនីពេលបើកកម្មវិធីឡើងវិញ ហើយការចាកចេញបញ្ចប់ការចូលគណនីលើឧបករណ៍នេះ។ ចំណូលចិត្ត និងព័ត៌មានដឹកជញ្ជូនបច្ចុប្បន្នរក្សាទុកតែក្នុងការប្រើកម្មវិធីលើកនេះ។';

  @override
  String get profileEdit => 'កែប្រែប្រវត្តិរូប';

  @override
  String get profileDisplayName => 'ឈ្មោះបង្ហាញ';

  @override
  String get profileEditHint =>
      'គ្រប់គ្រងព័ត៌មានផ្ទាល់ខ្លួន និងគណនីសម្រាប់ចូលប្រើប្រាស់។';

  @override
  String get profileNameRequired => 'សូមបញ្ចូលឈ្មោះរបស់អ្នក។';

  @override
  String get profileSave => 'រក្សាទុកការផ្លាស់ប្តូរ';

  @override
  String get profileSaved => 'ប្រវត្តិរូបរបស់អ្នកត្រូវបានកែប្រែ។';

  @override
  String get profileSaveError =>
      'មិនអាចរក្សាទុកប្រវត្តិរូបបានទេ។ សូមព្យាយាមម្ដងទៀត។';

  @override
  String get profileFooter => 'ស្រស់ពីកសិដ្ឋានខ្មែរ ដល់មាត់ទ្វារផ្ទះអ្នក';

  @override
  String profileVersion(String version) {
    return 'ផ្សារស្រស់ · កំណែ $version';
  }

  @override
  String get profileGuestCta => 'ចូលគណនីដើម្បីប្រើបទពិសោធន៍ផ្ទាល់ខ្លួន';

  @override
  String get profileEmail => 'អាសយដ្ឋានអ៊ីមែល';

  @override
  String get profileNotAdded => 'មិនទាន់បានបន្ថែម';

  @override
  String get profileChangePhone => 'ប្តូរលេខទូរស័ព្ទ';

  @override
  String get profileChangeEmail => 'ប្តូរអាសយដ្ឋានអ៊ីមែល';

  @override
  String get profilePhoneChangeHint =>
      'បញ្ចូលលេខទូរស័ព្ទខ្មែរថ្មីរបស់អ្នក។ យើងនឹងផ្ញើលេខកូដដើម្បីផ្ទៀងផ្ទាត់មុនប្តូរលេខសម្រាប់ចូលគណនី។';

  @override
  String get profileEmailChangeHint =>
      'យើងនឹងផ្ញើតំណផ្ទៀងផ្ទាត់ទៅអ៊ីមែលថ្មីរបស់អ្នក។ ប្រសិនបើគណនីមានអ៊ីមែលរួចហើយ អ្នកអាចត្រូវផ្ទៀងផ្ទាត់តាមអ៊ីមែលទាំងពីរ។';

  @override
  String get profileInvalidEmail => 'សូមបញ្ចូលអាសយដ្ឋានអ៊ីមែលត្រឹមត្រូវ។';

  @override
  String get profileSameContact => 'សូមបញ្ចូលលេខទូរស័ព្ទ ឬអ៊ីមែលផ្សេងទៀត។';

  @override
  String get profileNewPhone => 'លេខទូរស័ព្ទថ្មី';

  @override
  String get profileNewEmail => 'អាសយដ្ឋានអ៊ីមែលថ្មី';

  @override
  String get profileSendConfirmation => 'ផ្ញើការផ្ទៀងផ្ទាត់';

  @override
  String get profileEmailSent =>
      'សូមពិនិត្យអ៊ីមែលសម្រាប់តំណផ្ទៀងផ្ទាត់។ ត្រឡប់មកទីនេះក្រោយផ្ទៀងផ្ទាត់ ដើម្បីពិនិត្យការផ្លាស់ប្តូរ។';

  @override
  String get profilePhoneSent =>
      'បញ្ចូលលេខកូដ SMS ដែលបានផ្ញើទៅលេខថ្មី។ លេខបច្ចុប្បន្ននៅតែអាចប្រើបាន រហូតដល់ការផ្ទៀងផ្ទាត់បញ្ចប់។';

  @override
  String get profileContactUpdated =>
      'ព័ត៌មានទំនាក់ទំនងរបស់អ្នកត្រូវបានកែប្រែ។';

  @override
  String get profileContactError =>
      'មិនអាចកែប្រែព័ត៌មានទំនាក់ទំនងបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get profileCodeError =>
      'មិនអាចផ្ទៀងផ្ទាត់លេខកូដនេះបានទេ។ សូមពិនិត្យលេខកូដ ឬស្នើលេខកូដថ្មី។';

  @override
  String get profileCheckStatus => 'ពិនិត្យស្ថានភាព';

  @override
  String get profileStillPending =>
      'កំពុងរង់ចាំការផ្ទៀងផ្ទាត់។ សូមពិនិត្យសារ ហើយព្យាយាមម្តងទៀត។';

  @override
  String get profilePending => 'កំពុងរង់ចាំការផ្ទៀងផ្ទាត់';

  @override
  String get profileVerifyPhone => 'ផ្ទៀងផ្ទាត់លេខថ្មី';

  @override
  String get profileUseDifferentContact => 'ប្រើលេខទូរស័ព្ទ ឬអ៊ីមែលផ្សេង';

  @override
  String get profileResendConfirmation => 'ផ្ញើការផ្ទៀងផ្ទាត់ម្តងទៀត';

  @override
  String get profileLinkedAccounts => 'គណនីដែលបានភ្ជាប់';

  @override
  String get profileLinkedAccountsHint =>
      'ភ្ជាប់ Google ឬ Facebook ដើម្បីចូលគណនីផ្សារស្រស់ដដែលនេះ។';

  @override
  String get profileLinkAccount => 'ភ្ជាប់គណនី';

  @override
  String get profileConnected => 'បានភ្ជាប់';

  @override
  String get profileNotLinked => 'មិនទាន់បានភ្ជាប់';

  @override
  String get profileFinishLinking =>
      'បញ្ចប់ការភ្ជាប់ក្នុងកម្មវិធីរុករក ហើយត្រឡប់មកទីនេះ។ គណនីនឹងភ្ជាប់បានតែក្រោយការផ្ទៀងផ្ទាត់។';

  @override
  String get profileLinkError => 'មិនអាចភ្ជាប់គណនីនេះបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get profileLinkUnavailable =>
      'ការភ្ជាប់គណនីមិនទាន់អាចប្រើបានទេ។ សូមព្យាយាមនៅពេលក្រោយ។';

  @override
  String get profileIdentityInUse =>
      'គណនី Google ឬ Facebook នេះបានភ្ជាប់ទៅគណនីផ្សេងរួចហើយ។';

  @override
  String get profileLinkNotComplete =>
      'ការភ្ជាប់មិនទាន់បញ្ចប់ទេ។ អ្នកអាចព្យាយាមភ្ជាប់ម្តងទៀត។';

  @override
  String get profileMoreVerification =>
      'លេខកូដនេះត្រូវបានទទួលយក។ ប្រសិនបើមានលេខកូដផ្ទៀងផ្ទាត់ផ្សេងទៀតផ្ញើទៅលេខបច្ចុប្បន្ន សូមបញ្ចូលលេខកូដនោះដើម្បីបញ្ចប់ការផ្លាស់ប្តូរ។';

  @override
  String get authSocialPending =>
      'សូមបញ្ចប់ការចូលគណនីក្នុងកម្មវិធីរុករក ហើយត្រឡប់មកកម្មវិធីវិញ។';

  @override
  String get profilePhoto => 'រូបថតប្រវត្តិរូប';

  @override
  String get profileChangePhoto => 'ប្តូររូបថត';

  @override
  String get profileChoosePhoto => 'ជ្រើសរើសពីរូបថត';

  @override
  String get profileTakePhoto => 'ថតរូប';

  @override
  String get profileRemovePhoto => 'លុបរូបថត';

  @override
  String get profilePhotoHint =>
      'ជ្រើសរើសរូបថតច្បាស់។ ការផ្លាស់ប្តូរនឹងរក្សាទុកពេលចុចរក្សាទុកការផ្លាស់ប្តូរ។';

  @override
  String get profileCropPhoto => 'កែតម្រូវរូបថតរបស់អ្នក';

  @override
  String get profileCropHint =>
      'អូសដើម្បីកំណត់ទីតាំងរូបថត ហើយពង្រីកដោយម្រាមដៃ ឬប្រើរបាររំកិល។ រង្វង់បង្ហាញរូបថតនៅលើប្រវត្តិរូបរបស់អ្នក។';

  @override
  String get profilePhotoZoom => 'ពង្រីករូបថត';

  @override
  String get profileResetCrop => 'កំណត់ការកាត់រូបឡើងវិញ';

  @override
  String get profileUsePhoto => 'ប្រើរូបថតនេះ';

  @override
  String get profilePhotoInvalid =>
      'មិនអាចបើករូបថតនេះបានទេ។ សូមជ្រើសរើសរូបផ្សេងដែលតូចជាង 10 MB។';

  @override
  String get profilePhotoPermission =>
      'មិនអាចចូលប្រើរូបថត ឬកាមេរ៉ាបានទេ។ សូមអនុញ្ញាតក្នុងការកំណត់ឧបករណ៍ ហើយព្យាយាមម្តងទៀត។';

  @override
  String get profilePhotoUnavailable =>
      'មិនអាចជ្រើសរើសរូបថតបានទេ។ សូមបិទ ហើយបើកកម្មវិធីឡើងវិញ រួចព្យាយាមម្តងទៀត។';

  @override
  String get profilePhotoPickerError =>
      'មិនអាចបើកកម្មវិធីជ្រើសរើសរូបថតបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get profileCameraUnavailable =>
      'ឧបករណ៍នេះមិនមានកាមេរ៉ាទេ។ សូមជ្រើសរើសរូបថតពីបណ្ណាល័យរបស់អ្នក។';

  @override
  String get profilePhotoSaveError =>
      'មិនអាចបញ្ចប់ការរក្សាទុករូបថតបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get locationMapHint =>
      'ប៉ះផែនទីដើម្បីដាក់ទីតាំងដឹកជញ្ជូន ឬប្រើទីតាំងបច្ចុប្បន្នរបស់អ្នក។';

  @override
  String get locationUseCurrent => 'ប្រើទីតាំងរបស់ខ្ញុំ';

  @override
  String get locationFinding => 'កំពុងស្វែងរកទីតាំងរបស់អ្នក…';

  @override
  String locationLiveAccuracy(int meters) {
    return 'ទីតាំងបច្ចុប្បន្ន · ភាពត្រឹមត្រូវប្រហែល $meters ម៉ែត្រ';
  }

  @override
  String get locationPermissionDenied =>
      'អ្នកមិនបានអនុញ្ញាតឱ្យប្រើទីតាំងទេ។ សូមព្យាយាមម្តងទៀត ឬជ្រើសរើសទីតាំងលើផែនទី។';

  @override
  String get locationPermissionBlocked =>
      'សូមអនុញ្ញាតឱ្យប្រើទីតាំងក្នុងការកំណត់ឧបករណ៍ ឬជ្រើសរើសទីតាំងលើផែនទី។';

  @override
  String get locationServicesDisabled =>
      'សូមបើកសេវាទីតាំងរបស់ឧបករណ៍ ឬជ្រើសរើសទីតាំងលើផែនទី។';

  @override
  String get locationUnavailable =>
      'យើងមិនអាចរកទីតាំងរបស់អ្នកបានទេ។ សូមព្យាយាមម្តងទៀត ឬជ្រើសរើសទីតាំងលើផែនទី។';

  @override
  String get locationOpenSettings => 'បើកការកំណត់';

  @override
  String get locationSearch => 'ស្វែងរកអាសយដ្ឋានលើផែនទី';

  @override
  String get locationSearchFailed =>
      'យើងមិនអាចរកអាសយដ្ឋាននេះបានទេ។ សូមសាកល្បងទីតាំងជិតខាង ឬដាក់ទីតាំងដោយខ្លួនឯង។';

  @override
  String get locationChooseOnMap => 'ជ្រើសរើសលើផែនទី';

  @override
  String get locationSaveError =>
      'យើងមិនអាចរក្សាទុកទីតាំងរបស់អ្នកបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get locationMapUnavailable =>
      'ផែនទីមិនអាចប្រើបានឥឡូវនេះទេ។ អ្នកនៅតែអាចប្រើទីតាំងរបស់អ្នក ឬបញ្ចូលអាសយដ្ឋានបាន។';

  @override
  String get addressDetailsTitle => 'ព័ត៌មានលម្អិតអាសយដ្ឋាន';

  @override
  String get addressDetailsHint =>
      'ព័ត៌មានបន្ថែមដើម្បីជួយអ្នកដឹកជញ្ជូនរកផ្ទះរបស់អ្នក។';

  @override
  String get addressSaveAs => 'ដាក់ស្លាកអាសយដ្ឋាននេះ';

  @override
  String get addressHome => 'ផ្ទះ';

  @override
  String get addressWork => 'កន្លែងធ្វើការ';

  @override
  String get addressPartner => 'ដៃគូ';

  @override
  String get addressOther => 'ផ្សេងទៀត';

  @override
  String get addressCustomLabel => 'ឈ្មោះស្លាកផ្ទាល់ខ្លួន';

  @override
  String get addressCustomLabelRequired => 'សូមបញ្ចូលឈ្មោះសម្រាប់អាសយដ្ឋាននេះ។';

  @override
  String get addressHouseNumber => 'លេខផ្ទះ / អគារ';

  @override
  String get addressStreet => 'ផ្លូវ';

  @override
  String get addressNote => 'កំណត់សម្គាល់អាសយដ្ឋាន';

  @override
  String get addressNoteHint =>
      'ជាន់ ច្រកចូល ទីតាំងសម្គាល់ជិតខាង ឬការណែនាំផ្លូវ';

  @override
  String get cartVoucherHintRemote =>
      'មានលេខកូដបញ្ចុះតម្លៃទេ? បញ្ចូលវាដើម្បីសន្សំលើកន្ត្រករបស់អ្នក។';

  @override
  String get cartVoucherExpired => 'លេខកូដនេះផុតកំណត់ហើយ។';

  @override
  String get cartVoucherNotStarted => 'លេខកូដនេះមិនទាន់អាចប្រើបានទេ។';

  @override
  String cartVoucherMinOrder(String amount) {
    return 'លេខកូដនេះត្រូវការកន្ត្រកយ៉ាងតិច $amount។';
  }

  @override
  String get cartVoucherCheckFailed =>
      'មិនអាចពិនិត្យលេខកូដបានទេ។ សូមពិនិត្យការតភ្ជាប់ ហើយព្យាយាមម្តងទៀត។';

  @override
  String cartVoucherAddMore(String amount, String code) {
    return 'បន្ថែម $amount ទៀតដើម្បីប្រើ $code។';
  }

  @override
  String get cartVoucherLoginRequired => 'សូមចូលគណនីដើម្បីប្រើលេខកូដនេះ។';

  @override
  String get cartVoucherNotNewCustomer =>
      'លេខកូដនេះសម្រាប់តែការបញ្ជាទិញលើកដំបូងប៉ុណ្ណោះ។';

  @override
  String get cartVoucherAlreadyUsed => 'អ្នកបានប្រើលេខកូដនេះរួចហើយ។';

  @override
  String get checkoutPlacing => 'កំពុងដាក់ការបញ្ជាទិញ…';

  @override
  String get checkoutNeedLocationTitle => 'តើយើងគួរដឹកទៅទីណា?';

  @override
  String get checkoutNeedLocation =>
      'សូមដៅទីតាំងដឹកជញ្ជូនលើផែនទី ដើម្បីឱ្យអ្នកដឹកអាចរកអ្នកឃើញ។';

  @override
  String get orderSuccessTitle => 'បានបញ្ជាទិញរួចរាល់!';

  @override
  String get orderSuccessBody =>
      'សូមអរគុណ! ក្រុមផ្សារកំពុងរៀបចំកន្ត្រកស្រស់របស់អ្នក។';

  @override
  String get orderSuccessCode => 'លេខបញ្ជាទិញ';

  @override
  String get orderSuccessTrack => 'តាមដានការបញ្ជាទិញ';

  @override
  String get checkoutOrderPlacedTitle => 'បានដាក់ការបញ្ជាទិញ';

  @override
  String checkoutOrderPlaced(String code, String total) {
    return 'អរគុណ! ការបញ្ជាទិញ $code តម្លៃ $total បានផ្ញើទៅក្រុមផ្សាររួចហើយ។';
  }

  @override
  String get checkoutOrderFailedTitle => 'មិនអាចដាក់ការបញ្ជាទិញបាន';

  @override
  String get checkoutOrderFailed =>
      'មានបញ្ហាកើតឡើង។ សូមពិនិត្យការតភ្ជាប់ ហើយព្យាយាមម្តងទៀត។';

  @override
  String get checkoutSignInToOrder =>
      'សូមចូលគណនីរបស់អ្នក ដើម្បីដាក់ការបញ្ជាទិញ។';

  @override
  String checkoutVoucherRemoved(String reason) {
    return '$reason យើងបានដកលេខកូដចេញ — សូមពិនិត្យតម្លៃសរុបថ្មី ហើយដាក់ការបញ្ជាទិញម្តងទៀត។';
  }

  @override
  String get khqrTitle => 'បង់ប្រាក់តាម ABA KHQR';

  @override
  String khqrOrder(String code) {
    return 'ការបញ្ជាទិញ $code';
  }

  @override
  String get khqrScanHint =>
      'ស្កេនដោយកម្មវិធី Bakong ឬកម្មវិធីធនាគារចល័តដែលគាំទ្រ KHQR';

  @override
  String get khqrOpenAba => 'បើក ABA Mobile';

  @override
  String get khqrAbaMissing =>
      'ទូរស័ព្ទនេះមិនមាន ABA Mobile ទេ។ សូមស្កេន QR ដោយទូរស័ព្ទ ឬកម្មវិធីធនាគារផ្សេង។';

  @override
  String get khqrWaiting => 'កំពុងរង់ចាំការបង់ប្រាក់';

  @override
  String khqrExpiresIn(String time) {
    return 'ផុតកំណត់ក្នុង $time';
  }

  @override
  String get khqrExpired => 'QR នេះផុតកំណត់ហើយ។';

  @override
  String get khqrFailed => 'ការបង់ប្រាក់មិនបានសម្រេច។';

  @override
  String get khqrNewQr => 'យក QR ថ្មី';

  @override
  String get khqrError => 'មិនអាចបង្កើត ABA KHQR បានទេ។';

  @override
  String get khqrTryAgain => 'ព្យាយាមម្តងទៀត';

  @override
  String get khqrPaidTitle => 'បានទទួលការបង់ប្រាក់';

  @override
  String khqrPaidBody(String code) {
    return 'អរគុណ! ការបញ្ជាទិញ $code បានបង់រួច ហើយក្រុមផ្សារកំពុងរៀបចំ។';
  }

  @override
  String get khqrDone => 'រួចរាល់';

  @override
  String get khqrLeaveTitle => 'ចាកចេញដោយមិនបង់ប្រាក់?';

  @override
  String get khqrLeaveBody =>
      'បើអ្នកចាកចេញឥឡូវ ការបញ្ជាទិញនេះនឹងត្រូវបោះបង់ ហើយទំនិញនឹងត្រឡប់ទៅកន្ត្រកវិញ។';

  @override
  String get khqrStay => 'បន្តបង់ប្រាក់';

  @override
  String get khqrLeave => 'ចាកចេញ';

  @override
  String get khqrTestModeNote =>
      'របៀបសាកល្បង៖ QR នេះមិនមែនពិតទេ ហើយគ្មានការផ្ទេរប្រាក់ពិតប្រាកដទេ។';

  @override
  String get khqrSimulatePay => 'សាកល្បងបង់ប្រាក់ (test)';

  @override
  String get ordersAwaitingPayment => 'កំពុងរង់ចាំការបង់ប្រាក់';

  @override
  String get ordersPaymentNeeded =>
      'បង់ប្រាក់តាម ABA KHQR ហើយយើងនឹងចាប់ផ្តើមរៀបចំ';

  @override
  String get ordersPayNow => 'បង់ប្រាក់ឥឡូវ';

  @override
  String get ordersSignInTitle => 'ចូលគណនីដើម្បីមើលការបញ្ជាទិញរបស់អ្នក';

  @override
  String get ordersSignInBody =>
      'ការបញ្ជាទិញ និងព័ត៌មានដឹកជញ្ជូនរបស់អ្នកនឹងបង្ហាញនៅទីនេះ ពេលអ្នកចូលគណនី។';

  @override
  String get ordersLoadFailed => 'មិនអាចផ្ទុកការបញ្ជាទិញបានទេ';

  @override
  String get ordersLoadFailedBody =>
      'សូមពិនិត្យការតភ្ជាប់ ហើយព្យាយាមម្តងទៀត ឬទាញចុះដើម្បីផ្ទុកឡើងវិញ។';

  @override
  String get ordersRetry => 'ព្យាយាមម្តងទៀត';
}
