import '../../push_restapi_dart.dart';

class PushApi {
  late final Signer? _signer;
  late final String _account;
  late final String? _decryptedPgpPvtKey;
  final String? pgpPublicKey;
  final bool readMode;

  void Function(ProgressHookType)? progressHook;

  late Chat chat;
  PushApi({
    Signer? signer,
    required String account,
    String? decryptedPgpPvtKey,
    this.pgpPublicKey,
    this.progressHook,
    this.readMode = false,
  }) {
    _signer = signer;
    _account = account;
    _decryptedPgpPvtKey = decryptedPgpPvtKey;

    chat = Chat(
      signer: signer,
      account: account,
      decryptedPgpPvtKey: decryptedPgpPvtKey,
      pgpPublicKey: pgpPublicKey,
      progressHook: progressHook,
    );
  }

  static Future<PushApi> initialize(
      {Signer? signer, PushAPIInitializeProps? options}) async {
    if (signer == null && options?.account == null) {
      throw Exception("Either 'signer' or 'account' must be provided.");
    }

    final readMode = signer != null;

    // Get account
    // Derives account from signer if not provided
    String? derivedAccount;

    if (signer != null) {
      derivedAccount = getAccountAddress(
          getWallet(address: options?.account, signer: signer));
    } else {
      derivedAccount = options?.account;
    }

    if (derivedAccount == null) {
      throw Exception('Account could not be derived.');
    }

    String? decryptedPGPPrivateKey;
    String? pgpPublicKey;

    /**
       * Decrypt PGP private key
       * If user exists, decrypts the PGP private key
       * If user does not exist, creates a new user and returns the decrypted PGP private key
       */
    final user = await getUser(address: derivedAccount);

    if (readMode) {
      if (user != null && user.encryptedPrivateKey != null) {
        decryptedPGPPrivateKey = await decryptPGPKey(
          toUpgrade: options?.autoUpgrade,
          progressHook: options?.progressHook,
          additionalMeta: options?.versionMeta,
          encryptedPGPPrivateKey: user.encryptedPrivateKey!,
          wallet: getWallet(address: options?.account, signer: signer),
        );
        pgpPublicKey = user.publicKey;
      } else {
        final newUser = await createUser(
          signer: signer,
          progressHook: options?.progressHook ?? (_) {},
          version: options?.version ?? ENCRYPTION_TYPE.PGP_V3,
        );
        decryptedPGPPrivateKey = newUser.decryptedPrivateKey;
        pgpPublicKey = newUser.publicKey;
      }
    }

    final api = PushApi(
      account: derivedAccount,
      signer: signer,
      decryptedPgpPvtKey: decryptedPGPPrivateKey,
      pgpPublicKey: pgpPublicKey,
      readMode: readMode,
    );

    return api;
  }

//TODO initStream
  Future initStream() async {}

  Future<User?> info({String? overrideAccount}) async {
    return getUser(address: overrideAccount ?? _account);
  }

  static String ensureSignerMessage() {
    return 'Operation not allowed in read-only mode. Signer is required.';
  }
}
