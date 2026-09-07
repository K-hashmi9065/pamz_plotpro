library;

/// Centralized Land Measurement Unit Conversion Engine.
/// 
/// Supported Land Units & Configurable Kishanganj / Bihar Conversion Conventions:
/// - Square Feet & Inches (1 Sq Ft = 144 Sq Inches, 1 Ft = 12 Inches)
/// - Katta & Dhur (Default: 1 Katta = 20 Dhur = 1,361.25 Sq Ft; 1 Dhur = 68.0625 Sq Ft)
/// - Decimal (Default: 1 Decimal = 435.6 Sq Ft = 1/100 Acre)
/// - Bigha (Default: 1 Bigha = 20 Katta = 27,225 Sq Ft)
/// - Acre (1 Acre = 100 Decimal = 43,560 Sq Ft)

enum LandInputUnitMode {
  sqFtInches, // Sq. Feet & Sq. Inches
  kattaDhur,  // Katta & Dhur
  decimal,    // Decimal
  dimensions, // Length (Ft+In) x Breadth (Ft+In)
}

class LandUnitConverter {
  // Configurable conversion factors (Default: Standard Kishanganj / Bihar legal convention)
  static double sqFtPerKatta = 1361.25;
  static double sqFtPerDhur = 68.0625; // sqFtPerKatta / 20
  static double sqFtPerDecimal = 435.6;
  static double sqFtPerBigha = 27225.0; // 20 * sqFtPerKatta
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
    return (
      katta: katta,
      dhur: double.parse(remainingDhur.toStringAsFixed(2)),
    );
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

  /// Converts Sq Feet and Sq Inches to total Sq Feet
  static double sqFtInchesToSqFt(double sqFt, double sqInches) {
    final f = sqFt.isNegative ? 0.0 : sqFt;
    final i = sqInches.isNegative ? 0.0 : sqInches;
    return f + (i / 144.0);
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
      basis = '1 Katta = ${sqFtPerKatta.toStringAsFixed(2)} Sq. Ft. (1 Dhur = ${sqFtPerDhur.toStringAsFixed(2)} Sq. Ft.)';
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

  /// Format land measurement as a human readable string preserving original unit and structured data
  static String formatLandMeasurement({
    required double areaSqFt,
    required String measurementUnit,
    double? displayArea,
    double? kattaValue,
    double? dhurValue,
  }) {
    if (measurementUnit == 'Kattha + Dhur' || measurementUnit == 'Katta + Dhur') {
      if (kattaValue != null || dhurValue != null) {
        final k = (kattaValue ?? 0.0);
        final d = (dhurValue ?? 0.0);
        final kStr = k == k.roundToDouble() ? k.toInt().toString() : k.toString();
        final dStr = d == d.roundToDouble() ? d.toInt().toString() : d.toString();
        if (k > 0 && d > 0) {
          return '$kStr Kattha + $dStr Dhur';
        } else if (k > 0) {
          return '$kStr Kattha';
        } else if (d > 0) {
          return '$dStr Dhur';
        } else {
          return '0 Kattha + 0 Dhur';
        }
      }
      final kd = sqFtToKattaDhur(areaSqFt);
      final dStr = kd.dhur == kd.dhur.roundToDouble() ? kd.dhur.toInt().toString() : kd.dhur.toString();
      return '${kd.katta} Kattha + $dStr Dhur';
    }

    final val = displayArea ?? sqFtToUnitValue(areaSqFt, measurementUnit);
    final valStr = val == val.roundToDouble()
        ? val.toInt().toString()
        : double.parse(val.toStringAsFixed(2)).toString().replaceAll(RegExp(r'\.0+$'), '');

    switch (measurementUnit) {
      case 'Acre':
        return '$valStr Acre';
      case 'Bigha':
        return '$valStr Bigha';
      case 'Kattha':
      case 'Katta':
        return '$valStr Kattha';
      case 'Dhur':
        return '$valStr Dhur';
      case 'Decimal':
        return '$valStr Decimal';
      case 'Square Meter':
        return '$valStr Sq M';
      case 'Square Feet':
      default:
        return '$valStr Sq Ft';
    }
  }

  /// Formatted multi-unit summary readout (e.g. "1,361.3 Sq.Ft | 1 Kattha 0.0 Dhur | 3.125 Dec")
  static String formatAllUnits(double sqFt) {
    if (sqFt <= 0) return '0 Sq.Ft | 0 Kattha 0 Dhur | 0 Decimal';

    final kd = sqFtToKattaDhur(sqFt);
    final dec = sqFtToDecimal(sqFt);
    final sqFtFormatted = sqFt.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

    return '$sqFtFormatted Sq.Ft  •  ${kd.katta} Kattha ${kd.dhur} Dhur  •  $dec Dec';
  }

  /// Detailed human readable multi-line summary string
  static String formatDetailedSummary(double sqFt) {
    if (sqFt <= 0) return '0 Sq. Ft.';

    final kd = sqFtToKattaDhur(sqFt);
    final dec = sqFtToDecimal(sqFt);
    final bigha = sqFtToBigha(sqFt);
    final sqM = (sqFt / sqFtPerSqMeter).toStringAsFixed(1);

    return '${sqFt.toStringAsFixed(1)} Sq. Ft. '
        '(${kd.katta} Kattha ${kd.dhur} Dhur | $dec Decimal | $bigha Bigha | $sqM Sq. M)';
  }
}

