import 'package:flutter_test/flutter_test.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

void main() {
  test('default', () async {
    await initPush();
    expect(getCachedENV(), ENV.staging);
  });
  test('.staging', () async {
    await initPush(env: ENV.staging);
    expect(getCachedENV(), ENV.staging);
  });

  test('.dev', () async {
    await initPush(env: ENV.dev);
    expect(getCachedENV(), ENV.dev);
  });

  test('.prod', () async {
    await initPush(env: ENV.prod);
    expect(getCachedENV(), ENV.prod);
  });
}
