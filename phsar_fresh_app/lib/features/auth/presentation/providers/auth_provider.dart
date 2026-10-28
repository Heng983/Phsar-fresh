import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/features/auth/data/auth_repository.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => const UnavailableAuthRepository(),
);

final authSessionProvider = StreamProvider<AuthSession?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return Stream<AuthSession?>.multi((controller) {
    final subscription = repository.sessionChanges.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );
    controller.add(repository.currentSession);
    controller.onCancel = subscription.cancel;
  });
});
