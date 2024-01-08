import '../push_restapi_dart.dart';

Future initPush({
  ENV env = ENV.staging,
  Wallet? wallet,
  bool showHttpLog = false,
}) async {
  providerContainer.read(envProvider.notifier).setEnv(env);
  providerContainer.read(showHttpLogProvider.notifier).setEnv(showHttpLog);

  if (wallet != null) {
    await providerContainer
        .read(userEthWalletProvider.notifier)
        .setCurrentUserEthWallet(wallet);
  }
}
