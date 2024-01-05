import '../../push_restapi_dart.dart';

class UserAPI {
  late final String _account;
  UserAPI({
    required String account,
  }) {
    _account = account;
  }

  Future<User?> info({String? overrideAccount}) async {
    return getUser(address: overrideAccount ?? _account);
  }
}
