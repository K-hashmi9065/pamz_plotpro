/// Compliance disclaimers and legal text required by PRD §12.
abstract class LegalDisclaimers {
  static const String complianceDisclaimerShort =
      'Notice: Legal, statutory & tax rules (RERA, TDS u/s 194-IA, Cash limit u/s 269ST, DLC/Circle Rate) require jurisdiction-specific review by a qualified Chartered Accountant / legal counsel before final execution.';

  static const String complianceDisclaimerFull =
      'DISCLAIMER: This system provides financial tracking and calculations based on input records. It does not constitute formal legal or accounting advice. Statutory considerations (including RERA applicability, SEBI CIS guidelines, Benami Transactions Act, Income Tax Act Sections 43CA, 50C, 194-IA, 269SS/269T/269ST, Stamp Duty rates, and GST regulations) vary by jurisdiction. All records, contracts, and tax withholdings must be independently verified by a qualified professional.';

  static const String cashWarning269ST =
      'WARNING (Section 269ST Income Tax Act): Receiving cash of ₹2,00,000 or more in a single day, or in respect of a single transaction/event, is restricted under Section 269ST and may attract equal penalty under Section 271DA unless exempted.';

  static const String circleRateWarning43CA =
      'WARNING (Section 43CA / 50C): The declared sale value is below the notified DLC / Circle Rate. Under Section 43CA / 50C, the circle rate value may be deemed as the full consideration for income tax purposes unless within statutory tolerance limits.';
}
