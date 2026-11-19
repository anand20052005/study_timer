import 'package:flutter_test/flutter_test.dart';
import 'package:study_timer/store.dart';

void main() {
  test('formats durations', () {
    expect(fmtHms(3661), '01:01:01');
    expect(fmtHm(5400), '1h 30m');
    expect(fmtHm(300), '5m');
  });
}
