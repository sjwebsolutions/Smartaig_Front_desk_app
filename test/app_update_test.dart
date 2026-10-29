import 'package:flutter_test/flutter_test.dart';
import 'package:front_desk_app/services/app_update_service.dart';

void main() {
  group('AppUpdateService Version Comparison Tests', () {
    test('Identifies newer patch version', () {
      expect(AppUpdateService.isVersionOlder('2.0.8', '2.0.9'), isTrue);
    });

    test('Identifies newer minor version', () {
      expect(AppUpdateService.isVersionOlder('2.0.8', '2.1.0'), isTrue);
    });

    test('Identifies newer major version', () {
      expect(AppUpdateService.isVersionOlder('2.0.8', '3.0.0'), isTrue);
    });

    test('Returns false when store version is identical', () {
      expect(AppUpdateService.isVersionOlder('2.0.8', '2.0.8'), isFalse);
    });

    test('Returns false when current version is ahead of store version', () {
      expect(AppUpdateService.isVersionOlder('2.0.9', '2.0.8'), isFalse);
    });

    test('Handles build number suffix gracefully', () {
      expect(AppUpdateService.isVersionOlder('2.0.8+10', '2.0.9+12'), isTrue);
      expect(AppUpdateService.isVersionOlder('2.0.8+10', '2.0.8'), isFalse);
    });

    test('Handles two digit minor or patch versions correctly', () {
      expect(AppUpdateService.isVersionOlder('2.0.8', '2.0.10'), isTrue);
      expect(AppUpdateService.isVersionOlder('2.0.12', '2.0.9'), isFalse);
    });
  });
}
