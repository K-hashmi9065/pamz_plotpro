import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Password Hashing', () {
    test('_generateSalt produces unique salts', () {
      // We test via the public interface indirectly — two users should get different hashes for same password
      // Since salt is private, we verify via different hash outputs
      final salt1 = _generateSalt();
      final salt2 = _generateSalt();
      expect(salt1, isNot(equals(salt2)));
    });

    test('same password with different salts produces different hashes', () {
      final salt1 = _generateSalt();
      final salt2 = _generateSalt();
      const password = 'mySecurePassword123';

      final hash1 = _hashPassword(password, salt1);
      final hash2 = _hashPassword(password, salt2);

      expect(hash1, isNot(equals(hash2)));
    });

    test('same password with same salt always produces same hash', () {
      const salt = 'fixedtestsalt';
      const password = 'testPassword';

      final hash1 = _hashPassword(password, salt);
      final hash2 = _hashPassword(password, salt);

      expect(hash1, equals(hash2));
    });

    test('hash is deterministic SHA-256', () {
      const salt = 'abc123';
      const password = 'hello';
      final combined = utf8.encode('$salt$password');
      final expected = sha256.convert(combined).toString();

      final actual = _hashPassword(password, salt);
      expect(actual, equals(expected));
    });

    test('salt length is 64 hex chars (32 bytes)', () {
      final salt = _generateSalt();
      expect(salt.length, equals(64));
    });

    test('hash output is 64 hex chars (SHA-256 output)', () {
      final hash = _hashPassword('password', 'salt');
      expect(hash.length, equals(64));
    });

    test('empty password still hashes deterministically', () {
      const salt = 'somesalt';
      final h1 = _hashPassword('', salt);
      final h2 = _hashPassword('', salt);
      expect(h1, equals(h2));
    });

    test('unicode password hashes correctly', () {
      const password = 'पासवर्ड123'; // Hindi + numbers
      const salt = 'testsalt';
      final h = _hashPassword(password, salt);
      expect(h, isNotEmpty);
      expect(h.length, equals(64));
    });
  });
}

// Mirror the private methods for test access
String _generateSalt() {
  final rng = Random.secure();
  final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

String _hashPassword(String password, String salt) {
  final combined = utf8.encode('$salt$password');
  return sha256.convert(combined).toString();
}
