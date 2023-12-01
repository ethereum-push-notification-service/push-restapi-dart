import 'package:flutter_test/flutter_test.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

void main() async {
  setUp(() {
    initPush();
  });

  group('Api', () {
    test('getAPIBaseUrls', () {
      expect(Api.getAPIBaseUrls(), 'https://backend-staging.epns.io/apis');
      expect(Api.getAPIBaseUrls(ENV.staging),
          'https://backend-staging.epns.io/apis');
      expect(Api.getAPIBaseUrls(ENV.dev), 'https://backend-dev.epns.io/apis');
      expect(Api.getAPIBaseUrls(ENV.prod), 'https://backend.epns.io/apis');
      expect(Api.getAPIBaseUrls(ENV.local), 'http://localhost:4000/apis');
    });

    test('getSocketAPIBaseUrls', () {
      expect(Api.getSocketAPIBaseUrls(), 'https://backend-staging.epns.io');
      expect(Api.getSocketAPIBaseUrls(ENV.staging),
          'https://backend-staging.epns.io');
      expect(Api.getSocketAPIBaseUrls(ENV.dev), 'https://backend-dev.epns.io');
      expect(Api.getSocketAPIBaseUrls(ENV.prod), 'https://backend.epns.io');
      expect(Api.getSocketAPIBaseUrls(ENV.local), 'http://localhost:4000');
    });
  });

  test('.getQueryParams', () {
    expect(getQueryParams({'date': 'today'}), 'date=today');
    expect(
        getQueryParams({
          'page': 10,
          'limit': 1,
          'spam': 2,
        }),
        'page=10&limit=1&spam=2');
  });
}
