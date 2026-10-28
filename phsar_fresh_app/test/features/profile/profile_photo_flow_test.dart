import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';
import 'package:phsar_fresh_app/features/profile/data/profile_photo_picker.dart';
import 'package:phsar_fresh_app/features/profile/domain/model/avatar_image.dart';
import 'package:phsar_fresh_app/features/profile/presentation/pages/profile_photo_crop_page.dart';

import '../../support/auth_test_repository.dart';
import '../../support/pump_helpers.dart';

class FakePhotoPicker extends ProfilePhotoPicker {
  PreparedAvatar? next;
  PreparedAvatar? recovered;
  Object? failure;
  final sources = <ProfilePhotoSource>[];
  @override
  Future<PreparedAvatar?> recover() async => recovered;
  @override
  Future<PreparedAvatar?> pick(ProfilePhotoSource source) async {
    sources.add(source);
    if (failure != null) throw failure!;
    return next;
  }
}

Future<void> choosePhoto(
  WidgetTester tester, {
  String source = 'gallery',
}) async {
  await revealAndTap(tester, find.byKey(const Key('profile-change-photo')));
  await tester.tap(find.byKey(Key('profile-photo-$source')));
  await tester.pumpAndSettle();
}

Future<void> useCrop(WidgetTester tester) async {
  final button = find.byKey(const Key('profile-use-photo'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  // Image encoding runs in an isolate. Pump frames while waiting for its result.
  for (
    var i = 0;
    i < 100 && find.byType(ProfilePhotoCropPage).evaluate().isNotEmpty;
    i++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 30));
  }
  await tester.pumpAndSettle();
  expect(find.byType(ProfilePhotoCropPage), findsNothing);
}

void main() {
  late TestAuthRepository repository;
  late TestProfilePhotoRepository photos;
  late FakePhotoPicker picker;
  late PreparedAvatar photo;

  setUp(() {
    repository = TestAuthRepository(
      user: const AuthUser(
        id: 'test-account',
        displayName: 'Sophea',
        phone: testPhone,
      ),
    );
    photos = TestProfilePhotoRepository(repository);
    final image = img.Image(width: 80, height: 60);
    img.fill(image, color: img.ColorRgb8(80, 160, 100));
    photo = prepareAvatar(img.encodePng(image));
    picker = FakePhotoPicker();
  });
  tearDown(() => repository.close());

  testWidgets(
    'Photo picker waits for the source sheet to close and ignores repeated taps',
    (tester) async {
      await pumpAccount(
        tester,
        repository,
        photoPicker: picker,
        photoRepository: photos,
      );
      await revealAndTap(tester, find.byKey(const Key('profile-edit')));
      final change = find.byKey(const Key('profile-change-photo'));
      await tester.ensureVisible(change);
      await tester.pumpAndSettle();
      // Two taps before a frame rebuild must still open just one source sheet.
      final onPressed = tester.widget<TextButton>(change).onPressed!;
      onPressed();
      onPressed();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile-photo-gallery')), findsOneWidget);
      await tester.tap(find.byKey(const Key('profile-photo-gallery')));
      await tester.pump();
      expect(picker.sources, isEmpty);
      await tester.pump(const Duration(milliseconds: 50));
      expect(picker.sources, isEmpty);
      await tester.pumpAndSettle();
      expect(picker.sources, [ProfilePhotoSource.gallery]);
      expect(find.byKey(const Key('profile-photo-gallery')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final failure in <Object, String>{
    PlatformException(code: 'channel-error'): 'Close and reopen the app',
    MissingPluginException(): 'Close and reopen the app',
    PlatformException(code: 'invalid_image'): 'Choose a different image',
    PlatformException(code: 'multiple_request'): 'Please try again.',
  }.entries) {
    testWidgets(
      '${failure.key.runtimeType} ${failure.key is PlatformException ? (failure.key as PlatformException).code : "missing plugin"} does not claim access was denied',
      (tester) async {
        picker.failure = failure.key;
        await pumpAccount(
          tester,
          repository,
          photoPicker: picker,
          photoRepository: photos,
        );
        await revealAndTap(tester, find.byKey(const Key('profile-edit')));
        await choosePhoto(tester);
        expect(find.textContaining(failure.value), findsOneWidget);
        expect(
          find.textContaining('Allow access in your device settings'),
          findsNothing,
        );
        expect(photos.saves, 0);
        // The user can select another photo after a picker failure.
        picker.failure = null;
        await choosePhoto(tester);
        expect(picker.sources.length, 2);
        expect(find.byKey(const Key('profile-edit-error')), findsNothing);
      },
    );
  }

  testWidgets(
    'Cancelled photo selection preserves the name draft and never uploads',
    (tester) async {
      await pumpAccount(
        tester,
        repository,
        photoPicker: picker,
        photoRepository: photos,
      );
      await revealAndTap(tester, find.byKey(const Key('profile-edit')));
      await tester.enterText(
        find.byKey(const Key('profile-name-input')),
        'Sophea Pich',
      );
      await choosePhoto(tester);
      expect(picker.sources, [ProfilePhotoSource.gallery]);
      expect(find.byType(ProfilePhotoCropPage), findsNothing);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('profile-name-input')))
            .controller
            ?.text,
        'Sophea Pich',
      );
      expect(photos.saves, 0);
    },
  );

  testWidgets(
    'Gallery photo is cropped and previewed before Save updates the account',
    (tester) async {
      picker.next = photo;
      await pumpAccount(
        tester,
        repository,
        photoPicker: picker,
        photoRepository: photos,
      );
      await revealAndTap(tester, find.byKey(const Key('profile-edit')));
      await choosePhoto(tester);
      expect(find.byType(ProfilePhotoCropPage), findsOneWidget);
      await tester.drag(
        find.byKey(const Key('profile-crop-viewport')),
        const Offset(-20, 10),
      );
      await useCrop(tester);
      expect(find.byKey(const Key('profile-photo-preview')), findsOneWidget);
      expect(photos.saves, 0);
      await revealAndTap(tester, find.byKey(const Key('profile-save')));
      expect(photos.savedPhoto, isNotNull);
      expect(find.byKey(const Key('profile-change-photo')), findsNothing);
      expect(find.byKey(const Key('profile-photo-image')), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Permission denial can be retried with the camera and a failed upload keeps its preview',
    (tester) async {
      picker.failure = PlatformException(code: 'photo_access_denied');
      await pumpAccount(
        tester,
        repository,
        photoPicker: picker,
        photoRepository: photos,
      );
      await revealAndTap(tester, find.byKey(const Key('profile-edit')));
      await choosePhoto(tester);
      expect(
        find.textContaining('Allow access in your device settings'),
        findsOneWidget,
      );
      picker.failure = null;
      picker.next = photo;
      await choosePhoto(tester, source: 'camera');
      expect(picker.sources.last, ProfilePhotoSource.camera);
      await useCrop(tester);
      photos.rejectUpload = true;
      await revealAndTap(tester, find.byKey(const Key('profile-save')));
      expect(find.byKey(const Key('profile-edit-error')), findsOneWidget);
      expect(find.byKey(const Key('profile-photo-preview')), findsOneWidget);
      expect(photos.savedPhoto, isNull);
      photos.rejectUpload = false;
      await revealAndTap(tester, find.byKey(const Key('profile-save')));
      expect(photos.savedPhoto, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Photo removal is a draft until Save and then restores the initial avatar',
    (tester) async {
      repository.updateUser(avatarUrl: 'https://photos.example/old.jpg');
      await pumpAccount(
        tester,
        repository,
        photoPicker: picker,
        photoRepository: photos,
      );
      await revealAndTap(tester, find.byKey(const Key('profile-edit')));
      await choosePhoto(tester, source: 'remove');
      expect(
        repository.currentSession!.user.avatarUrl,
        'https://photos.example/old.jpg',
      );
      await revealAndTap(tester, find.byKey(const Key('profile-save')));
      expect(repository.currentSession!.user.avatarUrl, isNull);
      expect(photos.removals, 1);
      expect(find.byKey(const Key('profile-photo-image')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Recovered Android photo opens crop but cancelling never saves it',
    (tester) async {
      picker.recovered = photo;
      await pumpAccount(
        tester,
        repository,
        photoPicker: picker,
        photoRepository: photos,
      );
      await revealAndTap(tester, find.byKey(const Key('profile-edit')));
      expect(find.byType(ProfilePhotoCropPage), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile-photo-preview')), findsNothing);
      expect(photos.saves, 0);
    },
  );

  testWidgets(
    'A phone-only account can save a photo without inventing a display name',
    (tester) async {
      repository.setUser(testUser);
      picker.next = photo;
      await pumpAccount(
        tester,
        repository,
        photoPicker: picker,
        photoRepository: photos,
      );
      await revealAndTap(tester, find.byKey(const Key('profile-edit')));
      await choosePhoto(tester);
      await useCrop(tester);
      await revealAndTap(tester, find.byKey(const Key('profile-save')));
      expect(photos.savedPhoto, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  for (final language in ['en', 'km']) {
    testWidgets(
      'Photo controls and crop fit $language at 320px with large text',
      (tester) async {
        picker.next = photo;
        await pumpAccount(
          tester,
          repository,
          photoPicker: picker,
          photoRepository: photos,
          width: 320,
          scale: 1.5,
          language: language,
        );
        await revealAndTap(tester, find.byKey(const Key('profile-edit')));
        await choosePhoto(tester);
        await tester.ensureVisible(find.byKey(const Key('profile-use-photo')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await useCrop(tester);
        expect(find.byKey(const Key('profile-photo-preview')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
