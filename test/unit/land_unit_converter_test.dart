import 'package:flutter_test/flutter_test.dart';
import 'package:land_investment_and_sales_management/core/utils/land_unit_converter.dart';

void main() {
  group('LandUnitConverter Tests (Kishanganj / Bihar Land Conventions)', () {
    setUp(() {
      // Reset default conversion ratios
      LandUnitConverter.sqFtPerKatta = 1361.25;
      LandUnitConverter.sqFtPerDhur = 68.0625;
      LandUnitConverter.sqFtPerDecimal = 435.6;
      LandUnitConverter.sqFtPerBigha = 27225.0;
    });

    test('Katta & Dhur to Sq Ft conversion', () {
      expect(LandUnitConverter.kattaDhurToSqFt(1, 0), equals(1361.25));
      expect(LandUnitConverter.kattaDhurToSqFt(0, 20), equals(1361.25));
      expect(LandUnitConverter.kattaDhurToSqFt(2, 10), equals(2 * 1361.25 + 10 * 68.0625));
    });

    test('Sq Ft to Katta & Dhur breakdown', () {
      final res = LandUnitConverter.sqFtToKattaDhur(1361.25);
      expect(res.katta, equals(1));
      expect(res.dhur, equals(0.0));
    });

    test('Decimal to Sq Ft conversion', () {
      expect(LandUnitConverter.decimalToSqFt(1.0), equals(435.6));
      expect(LandUnitConverter.decimalToSqFt(10.0), equals(4356.0));
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

    test('Explicit conversion basis string format', () {
      final detail = LandUnitConverter.formatConversionBasisDetail(
        originalValue: 1.0,
        originalUnit: 'Katta',
        convertedSqFt: 1361.25,
      );

      expect(detail, contains('Original: 1.0 Katta'));
      expect(detail, contains('Converted: 1361.3 Sq. Ft.'));
      expect(detail, contains('Basis: 1 Katta = 1361.25 Sq. Ft.'));
    });
  });
}
