import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class FormulaTermDefinition {
  final String term;
  final String definition;
  final String valueDisplay;

  const FormulaTermDefinition({
    required this.term,
    required this.definition,
    required this.valueDisplay,
  });
}

/// Reusable popup dialog for "How is this calculated?" (Section 12A).
class FormulaExplainabilityDialog extends StatelessWidget {
  final String figureTitle;
  final String plainWordsFormula;
  final List<FormulaTermDefinition> terms;
  final String calculatedResultDisplay;

  const FormulaExplainabilityDialog({
    super.key,
    required this.figureTitle,
    required this.plainWordsFormula,
    required this.terms,
    required this.calculatedResultDisplay,
  });

  /// Helper launcher method
  static Future<void> show(
    BuildContext context, {
    required String figureTitle,
    required String plainWordsFormula,
    required List<FormulaTermDefinition> terms,
    required String calculatedResultDisplay,
  }) {
    return showDialog(
      context: context,
      builder: (context) => FormulaExplainabilityDialog(
        figureTitle: figureTitle,
        plainWordsFormula: plainWordsFormula,
        terms: terms,
        calculatedResultDisplay: calculatedResultDisplay,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.infoText,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How is this calculated?',
                        style: AppTypography.cardTitle,
                      ),
                      Text(
                        figureTitle,
                        style: AppTypography.secondary,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Section 1: Plain Words Formula
            Text(
              '1. FORMULA IN PLAIN WORDS',
              style: AppTypography.tableHeader.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                plainWordsFormula,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: One-line Definitions
            Text(
              '2. TERM DEFINITIONS',
              style: AppTypography.tableHeader.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ...terms.map((term) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_right,
                          size: 18, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.body.copyWith(fontSize: 13),
                            children: [
                              TextSpan(
                                text: '${term.term}: ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: term.definition,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),

            // Section 3: Exact Record Calculation with Real Numbers
            Text(
              '3. REAL NUMBERS FOR THIS EXACT RECORD',
              style: AppTypography.tableHeader.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...terms.map((term) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              term.term,
                              style: AppTypography.secondary.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              term.valueDisplay,
                              style: AppTypography.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const Divider(color: AppColors.border, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Calculated Figure',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        calculatedResultDisplay,
                        style: AppTypography.amountMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small info icon button widget to place next to computed financial figures.
class FormulaInfoButton extends StatelessWidget {
  final String figureTitle;
  final String plainWordsFormula;
  final List<FormulaTermDefinition> terms;
  final String calculatedResultDisplay;

  const FormulaInfoButton({
    super.key,
    required this.figureTitle,
    required this.plainWordsFormula,
    required this.terms,
    required this.calculatedResultDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'How is this calculated?',
      child: InkWell(
        onTap: () => FormulaExplainabilityDialog.show(
          context,
          figureTitle: figureTitle,
          plainWordsFormula: plainWordsFormula,
          terms: terms,
          calculatedResultDisplay: calculatedResultDisplay,
        ),
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
