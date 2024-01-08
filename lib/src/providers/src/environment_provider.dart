import 'package:riverpod/riverpod.dart';

import '../../../push_restapi_dart.dart';

enum ENV {
  prod,
  staging,
  dev,
  local,
}

final envProvider =
    StateNotifierProvider<EnvProvider, ENV>((ref) => EnvProvider(ENV.staging));

class EnvProvider extends StateNotifier<ENV> {
  EnvProvider(super.state);

  setEnv(ENV newValue) {
    state = newValue;
  }
}

ENV getCachedENV() {
  return providerContainer.read(envProvider);
}

final showHttpLogProvider = StateNotifierProvider<ShowHttpLogProvider, bool>(
    (ref) => ShowHttpLogProvider(false));

class ShowHttpLogProvider extends StateNotifier<bool> {
  ShowHttpLogProvider(super.state);

  setEnv(bool showHttpLog) {
    state = showHttpLog;
  }
}
