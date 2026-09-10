library;

/// Centralized Land Measurement Unit Conversion Engine.
///
/// Official Conversion Standard:
/// - 1 Kattha   = 1,125 sq ft
/// - 1 Dhur     = 56.25 sq ft
/// - 20 Dhur    = 1 Kattha
/// - 1 Decimal  = 450 sq ft
/// - 2.5 Decimal = 1 Kattha
/// - 1 Bigha    = 22,500 sq ft
/// - 20 Kattha  = 1 Bigha
/// - 1 Acre     = 43,560 sq ft
/// - 1 sq meter = 10.7639 sq ft

enum LandInputUnitMode {
  sqFtInches, // Sq. Feet & Sq. Inches
  kattaDhur, // Katta & Dhur
  decimal, // Decimal
  dimensions, // Length (Ft+In) x Breadth (Ft+In)
}

class LandUnitConverter {
  // Configurable conversion factors (1 Kattha = 1,125 Sq Ft | 1 Kattha = 2.5 Decimal)
  static double sqFtPerKatta = 1125.0;
  static double sqFtPerDhur = 56.25; // sqFtPerKatta / 20 = 1125 / 20 = 56.25
  static double sqFtPerDecimal =
      450.0; // 1 Kattha / 2.5 Decimal = 1125 / 2.5 = 450.0
  static double sqFtPerBigha =
      22500.0; // 20 * sqFtPerKatta = 20 * 1125 = 22500.0
  static double sqFtPerAcre = 43560.0;
  static double sqFtPerSqMeter = 10.7639;

  /// Update land unit conversion factors dynamically (e.g. from Admin Settings)
  static void updateConversions({
    double? customSqFtPerKatta,
    double? customSqFtPerDecimal,
    double? customSqFtPerBigha,
  }) {
    if (customSqFtPerKatta != null && customSqFtPerKatta > 0) {
      sqFtPerKatta = customSqFtPerKatta;
      sqFtPerDhur = customSqFtPerKatta / 20.0;
      if (customSqFtPerDecimal == null) {
        sqFtPerDecimal = customSqFtPerKatta / 2.5;
      }
    }
    if (customSqFtPerDecimal != null && customSqFtPerDecimal > 0) {
      sqFtPerDecimal = customSqFtPerDecimal;
    }
    if (customSqFtPerBigha != null && customSqFtPerBigha > 0) {
      sqFtPerBigha = customSqFtPerBigha;
    }
  }

  /// Converts Katta & Dhur to total Square Feet
  static double kattaDhurToSqFt(double katta, double dhur) {
    final k = katta.isNegative ? 0.0 : katta;
    final d = dhur.isNegative ? 0.0 : dhur;
    return (k * sqFtPerKatta) + (d * sqFtPerDhur);
  }

  /// Converts Square Feet to Katta & Dhur breakdown
  static ({int katta, double dhur}) sqFtToKattaDhur(double sqFt) {
    if (sqFt <= 0) return (katta: 0, dhur: 0.0);
    final totalKatta = sqFt / sqFtPerKatta;
    final katta = totalKatta.floor();
    final remainingDhur = (totalKatta - katta) * 20.0;
    return (katta: katta, dhur: double.parse(remainingDhur.toStringAsFixed(2)));
  }

  /// Converts Decimal to Square Feet
  static double decimalToSqFt(double decimal) {
    if (decimal <= 0) return 0.0;
    return decimal * sqFtPerDecimal;
  }

  /// Converts Square Feet to Decimal
  static double sqFtToDecimal(double sqFt) {
    if (sqFt <= 0) return 0.0;
    return double.parse((sqFt / sqFtPerDecimal).toStringAsFixed(3));
  }

  /// Converts Kattha to Decimal (1 Kattha = 2.5 Decimal)
  static double kattaToDecimal(double katta) {
    if (katta <= 0) return 0.0;
    return double.parse((katta * 2.5).toStringAsFixed(3));
  }

  /// Converts Decimal to Kattha (2.5 Decimal = 1 Kattha)
  static double decimalToKatta(double decimal) {
    if (decimal <= 0) return 0.0;
    return double.parse((decimal / 2.5).toStringAsFixed(3));
  }

  /// Converts Kattha & Dhur to Decimal (1 Kattha = 20 Dhur = 2.5 Decimal, 1 Dhur = 0.125 Decimal)
  static double kattaDhurToDecimal(double katta, double dhur) {
    final k = katta.isNegative ? 0.0 : katta;
    final d = dhur.isNegative ? 0.0 : dhur;
    return double.parse(((k + (d / 20.0)) * 2.5).toStringAsFixed(3));
  }

  /// Converts Sq Feet and Sq Inches to total Sq Feet
  static double sqFtInchesToSqFt(double sqFt, double sqInches) {
    final f = sqFt.isNegative ? 0.0 : sqFt;
    final i = sqInches.isNegative ? 0.0 : sqInches;
    return f + (i / 144.0);
  }

  /// Converts decimal feet (e.g. 405.5 ft) to Feet + Inches breakdown (e.g. 405 ft 6 in)
  /// Whole feet = 405 ft, Remaining = 0.5 ft -> 0.5 * 12 = 6 inches
  static ({int feet, double inches}) decimalFeetToFeetInches(
    double decimalFeet,
  ) {
    if (decimalFeet <= 0) return (feet: 0, inches: 0.0);
    final wholeFeet = decimalFeet.floor();
    final remainingFraction = decimalFeet - wholeFeet;
    final inches = double.parse((remainingFraction * 12.0).toStringAsFixed(2));
    if (inches >= 12.0) {
      return (feet: wholeFeet + 1, inches: 0.0);
    }
    return (feet: wholeFeet, inches: inches);
  }

  /// Converts Feet + Inches to normalized decimal Feet (e.g. 405 ft 6 in -> 405.5 ft)
  static double feetInchesToDecimalFeet(double feet, double inches) {
    final f = feet.isNegative ? 0.0 : feet;
    final i = inches.isNegative ? 0.0 : inches;
    return f + (i / 12.0);
  }

  /// Converts Length & Breadth in (Feet, Inches) to total Sq Feet
  static double dimensionsToSqFt({
    required double lengthFt,
    required double lengthIn,
    required double breadthFt,
    required double breadthIn,
  }) {
    final lFt = lengthFt.isNegative ? 0.0 : lengthFt;
    final lIn = lengthIn.isNegative ? 0.0 : lengthIn;
    final bFt = breadthFt.isNegative ? 0.0 : breadthFt;
    final bIn = breadthIn.isNegative ? 0.0 : breadthIn;

    final length = lFt + (lIn / 12.0);
    final breadth = bFt + (bIn / 12.0);
    return length * breadth;
  }

  /// Converts Road Length & Breadth in Feet & Inches to Road Area in Sq Ft
  static double calculateRoadAreaSqFt({
    required double lengthFt,
    required double lengthIn,
    required double breadthFt,
    required double breadthIn,
  }) {
    return dimensionsToSqFt(
      lengthFt: lengthFt,
      lengthIn: lengthIn,
      breadthFt: breadthFt,
      breadthIn: breadthIn,
    );
  }

  /// Converts Sq Feet to Bigha
  static double sqFtToBigha(double sqFt) {
    if (sqFt <= 0) return 0.0;
    return double.parse((sqFt / sqFtPerBigha).toStringAsFixed(3));
  }

  /// Explicit conversion basis string as mandated by Business Rule #8
  static String formatConversionBasisDetail({
    required double originalValue,
    required String originalUnit,
    required double convertedSqFt,
  }) {
    String basis;
    if (originalUnit.toLowerCase().contains('katta')) {
      basis =
          '1 Katta = ${sqFtPerKatta.toStringAsFixed(2)} Sq. Ft. (1 Dhur = ${sqFtPerDhur.toStringAsFixed(2)} Sq. Ft.)';
    } else if (originalUnit.toLowerCase().contains('dec')) {
      basis = '1 Decimal = ${sqFtPerDecimal.toStringAsFixed(2)} Sq. Ft.';
    } else if (originalUnit.toLowerCase().contains('bigha')) {
      basis = '1 Bigha = ${sqFtPerBigha.toStringAsFixed(2)} Sq. Ft.';
    } else {
      basis = '1 Sq. Ft. = 144 Sq. Inches';
    }

    return 'Original: $originalValue $originalUnit | Converted: ${convertedSqFt.toStringAsFixed(1)} Sq. Ft. | Basis: $basis';
  }

  /// Convert any input measurement unit and display values into normalized Sq Ft
  static double unitToSqFt({
    required String unit,
    required double displayArea,
    double? kattaValue,
    double? dhurValue,
  }) {
    switch (unit) {
      case 'Acre':
        return displayArea * sqFtPerAcre;
      case 'Bigha':
        return displayArea * sqFtPerBigha;
      case 'Kattha':
      case 'Katta':
        return displayArea * sqFtPerKatta;
      case 'Dhur':
        return displayArea * sqFtPerDhur;
      case 'Kattha + Dhur':
      case 'Katta + Dhur':
        final k = (kattaValue ?? 0.0).isNegative ? 0.0 : (kattaValue ?? 0.0);
        final d = (dhurValue ?? 0.0).isNegative ? 0.0 : (dhurValue ?? 0.0);
        return (k * sqFtPerKatta) + (d * sqFtPerDhur);
      case 'Decimal':
        return displayArea * sqFtPerDecimal;
      case 'Square Meter':
        return displayArea * sqFtPerSqMeter;
      case 'Square Feet':
      default:
        return displayArea;
    }
  }

  /// Convert Sq Ft to value in specified unit
  static double sqFtToUnitValue(double sqFt, String unit) {
    if (sqFt <= 0) return 0.0;
    switch (unit) {
      case 'Acre':
        return sqFt / sqFtPerAcre;
      case 'Bigha':
        return sqFt / sqFtPerBigha;
      case 'Kattha':
      case 'Katta':
        return sqFt / sqFtPerKatta;
      case 'Dhur':
        return sqFt / sqFtPerDhur;
      case 'Decimal':
        return sqFt / sqFtPerDecimal;
      case 'Square Meter':
        return sqFt / sqFtPerSqMeter;
      case 'Square Feet':
      default:
        return sqFt;
    }
  }

  /// Converts Square Feet to total Kattha (decimal value, e.g. 1125 sq ft -> 1.0 Kattha, 129600 sq ft -> 115.2 Kattha)
  static double sqFtToKatta(double sqFt) {
    if (sqFt <= 0) return 0.0;
    return double.parse((sqFt / sqFtPerKatta).toStringAsFixed(3));
  }

  /// Converts Square Feet to total Dhur (e.g. 56.25 sq ft -> 1.0 Dhur, 1125 sq ft -> 20.0 Dhur)
  static double sqFtToDhur(double sqFt) {
    if (sqFt <= 0) return 0.0;
    return double.parse((sqFt / sqFtPerDhur).toStringAsFixed(3));
  }

  /// Format land measurement as a human readable string preserving original unit
  static String formatLandMeasurement({
    required double areaSqFt,
    required String measurementUnit,
    double? displayArea,
    double? kattaValue,
    double? dhurValue,
  }) {
    final val = displayArea ?? sqFtToUnitValue(areaSqFt, measurementUnit);
    final valStr = val == val.roundToDouble()
        ? val.toInt().toString()
        : double.parse(
            val.toStringAsFixed(2),
          ).toString().replaceAll(RegExp(r'\.0+$'), '');

    switch (measurementUnit) {
      case 'Kattha':
      case 'Katta':
        return '$valStr Kattha';
      case 'Dhur':
        return '$valStr Dhur';
      case 'Decimal':
        return '$valStr Decimal';
      case 'Acre':
        return '$valStr Acre';
      case 'Bigha':
        return '$valStr Bigha';
      case 'Square Meter':
        return '$valStr Sq M';
      case 'Square Feet':
      default:
        return '$valStr Kattha';
    }
  }

  /// Formatted multi-unit summary readout (Square Feet • Kattha • Dhur • Decimal)
  static String formatAllUnits(double sqFt) {
    if (sqFt <= 0) return '0 Sq.Ft  •  0 Kattha  •  0 Dhur  •  0 Dec';

    final totalKatta = sqFtToKatta(sqFt);
    final totalKattaStr = totalKatta == totalKatta.roundToDouble()
        ? totalKatta.toInt().toString()
        : double.parse(totalKatta.toStringAsFixed(3))
              .toString()
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
    final totalDhur = sqFtToDhur(sqFt);
    final totalDhurStr = totalDhur == totalDhur.roundToDouble()
        ? totalDhur.toInt().toString()
        : double.parse(totalDhur.toStringAsFixed(2))
              .toString()
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
    final dec = sqFtToDecimal(sqFt);
    final sqFtFormatted = sqFt
        .toStringAsFixed(1)
        .replaceAll(RegExp(r'\.0$'), '');

    return '$sqFtFormatted Sq.Ft  •  $totalKattaStr Kattha  •  $totalDhurStr Dhur  •  $dec Dec';
  }

  /// Detailed human readable multi-line summary string
  static String formatDetailedSummary(double sqFt) {
    if (sqFt <= 0) return '0 Sq. Ft.';

    final totalKatta = sqFtToKatta(sqFt);
    final totalKattaStr = totalKatta == totalKatta.roundToDouble()
        ? totalKatta.toInt().toString()
        : double.parse(totalKatta.toStringAsFixed(3))
              .toString()
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
    final totalDhur = sqFtToDhur(sqFt);
    final totalDhurStr = totalDhur == totalDhur.roundToDouble()
        ? totalDhur.toInt().toString()
        : double.parse(totalDhur.toStringAsFixed(2))
              .toString()
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
    final dec = sqFtToDecimal(sqFt);

    return '${sqFt.toStringAsFixed(1)} Sq. Ft. ($totalKattaStr Kattha | $totalDhurStr Dhur | $dec Decimal)';
  }
}
