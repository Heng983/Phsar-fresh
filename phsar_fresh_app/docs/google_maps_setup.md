# Google Maps setup

The delivery picker embeds the official Google Maps SDK on Android and iOS. It retains foreground GPS, address lookup, draggable delivery pins, and device-saved delivery locations. A Google Maps API key is required for each platform. The app keeps GPS and address entry available if a key has not been configured.

## Create the keys

1. Open [Google Cloud Console](https://console.cloud.google.com/), select or create your project, and attach a billing account.
2. Under **APIs & Services → Library**, enable **Maps SDK for Android** and **Maps SDK for iOS**. These are the SDKs needed by the embedded mobile map; a Maps JavaScript API key does not replace them.
3. Open **APIs & Services → Credentials → Create credentials → API key**. Create an Android key and an iOS key separately.
4. Edit the Android key: choose **Android apps** under application restrictions, add the package name and certificate fingerprint below, and restrict API access to **Maps SDK for Android**.
5. Edit the iOS key: choose **iOS apps**, add the bundle identifier below, and restrict API access to **Maps SDK for iOS**.

These are your project's current identifiers:

| Setting | Value |
| --- | --- |
| Android package | `com.example.phsar_fresh_app` |
| Android debug SHA-1 on this Mac | `07:6D:36:08:30:6E:8E:78:E0:6F:E8:16:99:63:B0:56:83:C1:53:82` |
| iOS bundle identifier | `com.example.phsarFreshApp` |

The debug fingerprint is for local debug builds on this Mac. For a release, add the certificate fingerprint used to sign that release; Google Play builds use the app signing certificate shown in Play Console. Update the key restrictions if you change an app identifier.

Official instructions: [Google Maps Flutter setup](https://developers.google.com/maps/flutter-package/config), [API key restrictions](https://developers.google.com/maps/api-security-best-practices).

## Add the keys locally

Your git-ignored `config.json` uses these fields. Fill them with the corresponding keys:

```json
{
  "GOOGLE_MAPS_ANDROID_API_KEY": "YOUR_ANDROID_KEY",
  "GOOGLE_MAPS_IOS_API_KEY": "YOUR_IOS_KEY"
}
```

An Android-only test needs only the Android key; an iPhone test needs the iOS key. Keep `config.json` out of source control. Mobile Maps keys are packaged into the app, so the application and API restrictions above are essential.

Fully stop the app and rebuild:

```sh
flutter run --dart-define-from-file=config.json
```

Tap the header location, choose **Use my location**, allow foreground location access, and confirm with **Save location**. Tap anywhere on the map or drag the green marker to choose a different delivery pin. Location updates stop when the picker closes or the app is backgrounded.

The Android manifest key and iOS `GoogleMapsConfig.plist` are generated from the same Dart defines. Do not manually paste keys into native source files. The iOS build bundles only the iOS Maps key; it does not copy the rest of your configuration into that plist. Rebuilding without an iOS key clears any previously generated key.

The official iOS Flutter map plugin currently uses CocoaPods alongside the project's Swift Package Manager plugins. The generated Podfile and lock file are included in the project; normal `flutter run` performs required dependency setup. If running Xcode builds directly after changing dependencies, run `cd ios && pod install` first.

For foreground-only iOS distribution builds, use `BYPASS_PERMISSION_LOCATION_ALWAYS=1 flutter build ios --dart-define-from-file=config.json` to omit the unused always-location authorization code from the GPS plugin.

## If the map is blank

- Check that billing is active and the correct platform's Maps SDK is enabled in the same Google Cloud project as the key.
- Check the Android package and debug/release SHA-1, or the iOS bundle identifier, against the key's application restrictions.
- Make sure the API key field for the platform being run is filled, then perform a full rebuild.
- Check the device's internet connection. Google Maps authorization failures can be inspected in native logs; avoid sharing API keys from those logs.

Address search and reverse geocoding currently use Android/iOS location services. This integration does not enable Places autocomplete, turn-by-turn navigation, or courier tracking.

## Delivery address details

Both the map picker and checkout address editor support an optional house/building number, street, delivery notes, and a Home, Work, Partner, or custom address label. Map changes retain the entered details. Confirm the map, then save the checkout address to apply checkout edits; dismissing either editor discards its unsaved changes. The selected address and its details are saved on this device and shown at checkout. This stores one selected delivery address, not an account-synced address book.
