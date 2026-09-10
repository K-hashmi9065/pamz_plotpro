import 'package:flutter_test/flutter_test.dart';
import 'package:land_investment_and_sales_management/core/utils/land_unit_converter.dart';

void main() {
  group('LandUnitConverter Tests', () {
    setUp(() {
      // Reset default conversion ratios (1 Kattha = 1125 Sq.Ft, 1 Kattha = 2.5 Decimal => 1 Dec = 450 Sq.Ft)
      LandUnitConverter.sqFtPerKatta = 1125.0;
      LandUnitConverter.sqFtPerDhur = 56.25;
      LandUnitConverter.sqFtPerDecimal = 450.0;
      LandUnitConverter.sqFtPerBigha = 22500.0;
    });

    test('Katta & Dhur to Sq Ft conversion', () {
      expect(LandUnitConverter.kattaDhurToSqFt(1, 0), equals(1125.0));
      expect(LandUnitConverter.kattaDhurToSqFt(0, 20), equals(1125.0));
      expect(LandUnitConverter.kattaDhurToSqFt(2, 10), equals(2 * 1125.0 + 10 * 56.25));
    });

    test('Sq Ft to Katta & Dhur breakdown', () {
      final res = LandUnitConverter.sqFtToKattaDhur(1125.0);
      expect(res.katta, equals(1));
      expect(res.dhur, equals(0.0));
    });

    test('Decimal to Sq Ft and Kattha conversions (1 Kattha = 2.5 Decimal = 1125 Sq.Ft)', () {
      expect(LandUnitConverter.decimalToSqFt(1.0), equals(450.0));
      expect(LandUnitConverter.decimalToSqFt(2.5), equals(1125.0));
      expect(LandUnitConverter.kattaToDecimal(1.0), equals(2.5));
      expect(LandUnitConverter.decimalToKatta(2.5), equals(1.0));
      expect(LandUnitConverter.kattaDhurToDecimal(1.0, 0.0), equals(2.5));
      expect(LandUnitConverter.kattaDhurToDecimal(0.0, 20.0), equals(2.5));
    });

    test('Length x Breadth dimensions conversion', () {
      final sqFt = LandUnitConverter.dimensionsToSqFt(
        lengthFt: 50,
        lengthIn: 0,
        breadthFt: 20,
        breadthIn: 0,
      );
      expect(sqFt, equals(1000.0));
    });

    test('Configurable land unit conversion ratios', () {
      LandUnitConverter.updateConversions(
        customSqFtPerKatta: 1400.0,
        customSqFtPerDecimal: 440.0,
      );

      expect(LandUnitConverter.sqFtPerKatta, equals(1400.0));
      expect(LandUnitConverter.kattaDhurToSqFt(1, 0), equals(1400.0));
      expect(LandUnitConverter.decimalToSqFt(1), equals(440.0));
    });

    test('Decimal feet to feet and inches conversion (e.g. 405.5 ft = 405 ft 6 in)', () {
      final res1 = LandUnitConverter.decimalFeetToFeetInches(405.5);
      expect(res1.feet, equals(405));
      expect(res1.inches, equals(6.0));

      final res2 = LandUnitConverter.decimalFeetToFeetInches(30.25);
      expect(res2.feet, equals(30));
      expect(res2.inches, equals(3.0));

      final decimalBack = LandUnitConverter.feetInchesToDecimalFeet(405, 6);
      expect(decimalBack, equals(405.5));
    });

    test('Auto-calculation of land value from Kattha and Rate per Kattha (e.g. 115.2 Kattha * 500,000)', () {
      // 600 ft x 216 ft = 129600 Sq Ft = 115.2 Kattha
      final sqFt = LandUnitConverter.dimensionsToSqFt(
        lengthFt: 600,
        lengthIn: 0,
        breadthFt: 216,
        breadthIn: 0,
      );
      expect(sqFt, equals(129600.0));

      final totalKattha = LandUnitConverter.sqFtToKatta(sqFt);
      expect(totalKattha, equals(115.2));

      const ratePerKattha = 500000.0;
      final totalPrice = totalKattha * ratePerKattha;
      expect(totalPrice, equals(57600000.0));
    });
  });
}
