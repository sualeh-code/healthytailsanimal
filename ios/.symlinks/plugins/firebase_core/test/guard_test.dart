import 'package:firebase_core/src/internals.dart';
import 'package:firebase_core/src/interop_shimmer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('guardWebException', () {
    test('preserves stacktrace on futures that fail with FirebaseError',
        () async {
      final current = StackTrace.current;
      try {
        await guardWebExceptions(
          () => Future.error(_FirebaseError(), current),
          plugin: 'test',
          codeParser: (c) => c,
        );
        fail('dead code');
      } catch (err, stack) {
        expect(stack, current);
      }
    });

    test('preserves stacktrace on streams that fail with FirebaseError',
        () async {
      final current = StackTrace.current;
      try {
        await guardWebExceptions(
          () => Stream.error(_FirebaseError(), current),
          plugin: 'test',
          codeParser: (c) => c,
        ).first;
        fail('dead code');
      } catch (err, stack) {
        expect(stack, current);
      }
    });

    test('preserves stacktrace on functions that throw a FirebaseError',
        () async {
      final current = StackTrace.current;
      try {
        guardWebExceptions<void>(
          () => Error.throwWithStackTrace(_FirebaseError(), current),
          plugin: 'test',
          codeParser: (c) => c,
        );
        fail('dead code');
      } catch (err, stack) {
        expect(stack, current);
      }
    });
  });
}

class _FirebaseError implements FirebaseError {
  @override
  String get code => '';

  @override
  String get message => '';

  @override
  String get name => '';

  @override
  Object get serverResponse => '';

  @override
  String get stack => '';
}
