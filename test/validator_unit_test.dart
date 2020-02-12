
import 'package:zip/business/validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  // ----------------------- name function test
  test('empty name returns error string', () {

    final result = Validator.validateName('');
    expect(result, false);
  });

  test('non-empty name returns null', () {

    final result = Validator.validateName('name');
    expect(result, true);
  });

  // ------------------------ number function test
  test('empty number returns error string', () {

    final result = Validator.validateNumber('');
    expect(result, false);
  });

  test('non-empty number returns null', () {

    final result = Validator.validateNumber('number');
    expect(result, false);
  });

// -------------------------- email function test
  test('empty email returns error string', () {

    final result = Validator.validateEmail('');
    expect(result, false);
  });

  test('non-empty email returns null', () {

    final result = Validator.validateEmail('email');
    expect(result, false);
  });

// ------------------------- password function test
  test('empty password returns error string', () {

    final result = Validator.validatePassword('');
    expect(result, false);
  });

  test('non-empty password returns null', () {

    final result = Validator.validatePassword('password');
    expect(result, true);
  });

}
