import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/account_contact.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/profile/data/profile_photo_picker.dart';
import 'package:phsar_fresh_app/features/profile/domain/model/avatar_image.dart';
import 'package:phsar_fresh_app/features/profile/presentation/pages/profile_photo_crop_page.dart';
import 'package:phsar_fresh_app/features/profile/presentation/providers/profile_photo_provider.dart';
import 'package:phsar_fresh_app/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:phsar_fresh_app/features/profile/presentation/widgets/profile_components.dart';
import 'package:phsar_fresh_app/features/profile/presentation/widgets/profile_contact_sheet.dart';
import 'package:phsar_fresh_app/features/profile/presentation/widgets/profile_linked_accounts.dart';

class ProfileEditSheet extends ConsumerStatefulWidget {
  const ProfileEditSheet({super.key, required this.name});
  final String name;

  static Future<bool?> show(BuildContext context, String name) =>
      showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: Colors.white,
        builder: (_) => ProfileEditSheet(name: name),
      );

  @override
  ConsumerState<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<ProfileEditSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.name,
  );
  bool _saving = false;
  bool _workingWithPhoto = false;
  String? _ownerId;
  bool _removePhoto = false;
  Uint8List? _photo;
  String? _error;

  bool get _busy => _saving || _workingWithPhoto;

  @override
  void initState() {
    super.initState();
    _ownerId = ref.read(authSessionProvider).value?.user.id;
    WidgetsBinding.instance.addPostFrameCallback((_) => _recoverPhoto());
  }

  Future<void> _recoverPhoto() async {
    if (!mounted) return;
    final owner = ref.read(authSessionProvider).value?.user.id;
    var openingCrop = false;
    try {
      final recovered = await ref.read(profilePhotoPickerProvider).recover();
      if (recovered != null &&
          mounted &&
          !_busy &&
          ref.read(authSessionProvider).value?.user.id == owner) {
        openingCrop = true;
        setState(() => _workingWithPhoto = true);
        await _crop(recovered, owner);
      }
    } on MissingPluginException {
      // No pending native picker can be recovered on an unsupported host.
    } catch (error) {
      if (kDebugMode) debugPrint('Photo recovery failed: ${error.runtimeType}');
    } finally {
      if (openingCrop && mounted) setState(() => _workingWithPhoto = false);
    }
  }

  Future<void> _crop(PreparedAvatar image, String? owner) async {
    final jpeg = await ProfilePhotoCropPage.open(context, image);
    if (!mounted ||
        jpeg == null ||
        ref.read(authSessionProvider).value?.user.id != owner) {
      return;
    }
    setState(() {
      _photo = jpeg;
      _removePhoto = false;
      _error = null;
    });
  }

  Future<_PhotoAction?> _choosePhotoAction(bool hasPhoto) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final material = MaterialLocalizations.of(context);
    final route = ModalBottomSheetRoute<_PhotoAction>(
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      isScrollControlled: false,
      barrierLabel: material.scrimLabel,
      barrierOnTapHint: material.scrimOnTapHint(material.bottomSheetLabel),
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('profile-photo-gallery'),
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profileChoosePhoto),
              onTap: () => Navigator.pop(sheetContext, _PhotoAction.gallery),
            ),
            if (!kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.iOS ||
                    defaultTargetPlatform == TargetPlatform.android))
              ListTile(
                key: const Key('profile-photo-camera'),
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.profileTakePhoto),
                onTap: () => Navigator.pop(sheetContext, _PhotoAction.camera),
              ),
            if (hasPhoto)
              ListTile(
                key: const Key('profile-photo-remove'),
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(l10n.profileRemovePhoto),
                onTap: () => Navigator.pop(sheetContext, _PhotoAction.remove),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    final action = await navigator.push(route);
    // The pop result arrives before the sheet's reverse animation finishes.
    // Remove its overlay before presenting a native camera or photo controller.
    await route.completed;
    return action;
  }

  Future<void> _changePhoto(bool hasPhoto) async {
    if (_busy) return;
    final owner = ref.read(authSessionProvider).value?.user.id;
    setState(() {
      _workingWithPhoto = true;
      _error = null;
    });
    try {
      final action = await _choosePhotoAction(hasPhoto);
      if (!mounted ||
          action == null ||
          ref.read(authSessionProvider).value?.user.id != owner) {
        return;
      }
      if (action == _PhotoAction.remove) {
        setState(() {
          _photo = null;
          _removePhoto = true;
        });
        return;
      }
      final image = await ref
          .read(profilePhotoPickerProvider)
          .pick(
            action == _PhotoAction.camera
                ? ProfilePhotoSource.camera
                : ProfilePhotoSource.gallery,
          );
      if (image != null &&
          mounted &&
          ref.read(authSessionProvider).value?.user.id == owner) {
        await _crop(image, owner);
      }
    } on MissingPluginException {
      if (kDebugMode) {
        debugPrint('Profile photo picker is not registered. Rebuild the app.');
      }
      if (mounted) {
        setState(() => _error = context.l10n.profilePhotoUnavailable);
      }
    } on PlatformException catch (error) {
      if (kDebugMode) debugPrint('Profile photo picker failed: ${error.code}');
      if (mounted) {
        final l10n = context.l10n;
        setState(() {
          _error = switch (error.code) {
            'camera_access_denied' ||
            'camera_access_restricted' ||
            'photo_access_denied' ||
            'photo_access_restricted' ||
            'storage_access_denied' => l10n.profilePhotoPermission,
            'channel-error' => l10n.profilePhotoUnavailable,
            'invalid_image' => l10n.profilePhotoInvalid,
            'no_available_camera' => l10n.profileCameraUnavailable,
            _ => l10n.profilePhotoPickerError,
          };
        });
      }
    } on FormatException {
      if (mounted) setState(() => _error = context.l10n.profilePhotoInvalid);
    } catch (error) {
      if (kDebugMode) debugPrint('Profile photo failed: ${error.runtimeType}');
      if (mounted) {
        setState(() => _error = context.l10n.profilePhotoPickerError);
      }
    } finally {
      if (mounted) setState(() => _workingWithPhoto = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    if (_ownerId == null ||
        ref.read(authSessionProvider).value?.user.id != _ownerId) {
      setState(() => _error = context.l10n.authNoSession);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (_photo != null) {
        await ref
            .read(profilePhotoRepositoryProvider)
            .save(_photo!, displayName: _name.text);
      } else if (_removePhoto) {
        await ref
            .read(profilePhotoRepositoryProvider)
            .remove(displayName: _name.text);
      } else {
        await ref.read(authRepositoryProvider).updateDisplayName(_name.text);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = _photo != null || _removePhoto
              ? context.l10n.profilePhotoSaveError
              : context.l10n.profileSaveError,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(authSessionProvider).value?.user;
    final phone = user?.phone;
    final email = user?.email;
    final hasPhoto =
        _photo != null ||
        (!_removePhoto && (user?.avatarUrl?.isNotEmpty ?? false));
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.profileEdit,
                style: const TextStyle(
                  fontSize: AppFontSize.display,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.profileEditHint,
                style: const TextStyle(
                  fontSize: AppFontSize.footnote,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ProfileAvatar(
                  size: 100,
                  initial: widget.name.trim().isEmpty
                      ? null
                      : widget.name.trim().characters.first.toUpperCase(),
                  preview: _photo,
                  showDefault: _removePhoto,
                ),
              ),
              TextButton.icon(
                key: const Key('profile-change-photo'),
                onPressed: _busy ? null : () => _changePhoto(hasPhoto),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: Text(l10n.profileChangePhoto),
              ),
              Text(
                l10n.profilePhotoHint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppFontSize.caption,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const Key('profile-name-input'),
                controller: _name,
                enabled: !_busy,
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.nickname],
                decoration: InputDecoration(
                  labelText: l10n.profileDisplayName,
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  final empty = value == null || value.trim().isEmpty;
                  final photoOnly =
                      widget.name.trim().isEmpty &&
                      (_photo != null || _removePhoto);
                  return empty && !photoOnly ? l10n.profileNameRequired : null;
                },
                onFieldSubmitted: (_) => _save(),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    key: const Key('profile-edit-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      height: 1.5,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              FilledButton.icon(
                key: const Key('profile-save'),
                onPressed: _busy ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
                label: Text(l10n.profileSave),
              ),
              const SizedBox(height: 28),
              ProfileSurface(
                child: Column(
                  children: [
                    ProfileMenuTile(
                      key: const Key('profile-change-phone'),
                      icon: Icons.phone_iphone_rounded,
                      title: l10n.authPhoneNumber,
                      subtitle: phone == null || phone.isEmpty
                          ? l10n.profileNotAdded
                          : '+${phone.replaceFirst(RegExp(r'^\+'), '')}',
                      onTap: () {
                        if (_busy) return;
                        ProfileContactSheet.show(
                          context,
                          AccountContact.phone,
                          phone ?? '',
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.inputBackground),
                    ProfileMenuTile(
                      key: const Key('profile-change-email'),
                      icon: Icons.mail_outline_rounded,
                      title: l10n.profileEmail,
                      subtitle: email == null || email.isEmpty
                          ? l10n.profileNotAdded
                          : email,
                      onTap: () {
                        if (_busy) return;
                        ProfileContactSheet.show(
                          context,
                          AccountContact.email,
                          email ?? '',
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              IgnorePointer(
                ignoring: _busy,
                child: const ProfileLinkedAccounts(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PhotoAction { gallery, camera, remove }
