import 'package:push_restapi_dart/push_restapi_dart.dart';

/// Verifies if the local user's address matches the host's address.
/// If not, throws an exception with a custom error message.
isHost({required String hostAddress, required String errorMessage}) {
  final localAddress = getCachedWallet()!.address!;

  if (localAddress != pCAIP10ToWallet(hostAddress)) {
    throw Exception(errorMessage);
  }
}
