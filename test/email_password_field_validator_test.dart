
import 'package:zip/business/validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test('empty email returns error string', () {

    final result = Validator.validateEmail('');
    expect(result, 'Email can\'t be empty');
  });

  test('non-empty email returns null', () {

    final result = Validator.validateEmail('email');
    expect(result, null);
  });

  test('empty password returns error string', () {

    final result = Validator.validatePassword('');
    expect(result, 'Password can\'t be empty');
  });

  test('non-empty password returns null', () {

    final result = Validator.validatePassword('password');
    expect(result, null);
  });
}