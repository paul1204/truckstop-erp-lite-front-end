import 'package:flutter_test/flutter_test.dart';
import 'package:self_improvement_app/features/house_accounts/house_accounts_notifier.dart';

void main() {
  group('HouseAccountsNotifier Unit Tests', () {
    test('addHouseAccount inserts a new account and notifies listeners', () async {
      final notifier = HouseAccountsNotifier();

      // Wait for the initial asynchronous fetch to complete
      while (notifier.loading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final initialCount = notifier.accounts.length;

      final payload = {
        'companyName': 'Test Company LLC',
        'phoneNumber': '555-1234',
        'address': '789 Test Road',
        'creditLimit': 15000.0,
      };

      bool listenerNotified = false;
      notifier.addListener(() {
        listenerNotified = true;
      });

      final success = await notifier.addHouseAccount(payload);

      expect(success, isTrue);
      expect(notifier.accounts.length, equals(initialCount + 1));
      expect(notifier.accounts.first.companyName, equals('Test Company LLC'));
      expect(notifier.accounts.first.creditLimit, equals(15000.0));
      expect(listenerNotified, isTrue);
    });
  });
}
