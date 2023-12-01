import 'dart:convert';
import 'dart:typed_data';

import 'package:push_restapi_dart/push_restapi_dart.dart' as push;
import 'package:web3dart/web3dart.dart' as web3;

class Web3Signer extends push.Signer {
  final web3.Credentials credentials;

  Web3Signer(this.credentials);

  @override
  String getAddress() {
    return credentials.address.hex;
  }

  @override
  Future<String> getEip191Signature(String message) async {
    var m = utf8.encode(message);
    final sig = credentials.signToEcSignature(Uint8List.fromList(m));
print('${sig.r} ${sig.v} ${sig.s}');
    return sig.toString();
  }

  @override
  Future<String> getEip712Signature(String message) {
    throw UnimplementedError();
  }

  @override
  Future<String> signMessage(String message) async {
    var m = utf8.encode(message);
    final sig =
        credentials.signPersonalMessageToUint8List(Uint8List.fromList(m));
    return utf8.decode(sig);
  }
}
