import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../profit_loss_settlement/domain/profit_loss_models.dart';
import '../../../profit_loss_settlement/presentation/widgets/payout_disbursement_dialog.dart';

class InvestorWithdrawalOption {
  final String investorName;
  final String projectName;
  final String? projectLocation;
  final String? phone;
  final double capitalInvested;
  final double remainingPayoutBalance;
  final InvestorPayoutModel payout;

  const InvestorWithdrawalOption({
    required this.investorName,
    required this.projectName,
    this.projectLocation,
    this.phone,
    required this.capitalInvested,
    required this.remainingPayoutBalance,
    required this.payout,
  });
}

/// A modal dialog allowing users to search and select an investor & project agreement for withdrawal.
class InvestorWithdrawalSelectionDialog extends StatefulWidget {
  final List<InvestorWithdrawalOption> options;
  final String? preselectedInvestorName;

  const InvestorWithdrawalSelectionDialog({
    super.key,
    required this.options,
    this.preselectedInvestorName,
  });

  static Future<void> show({
    required BuildContext context,
    required List<InvestorWithdrawalOption> options,
    String? preselectedInvestorName,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => InvestorWithdrawalSelectionDialog(
        options: options,
        preselectedInvestorName: preselectedInvestorName,
      ),
    );
  }

  @override
  State<InvestorWithdrawalSelectionDialog> createState() => _InvestorWithdrawalSelectionDialogState();
}

class _InvestorWithdrawalSelectionDialogState extends State<InvestorWithdrawalSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  late List<InvestorWithdrawalOption> _filteredOptions;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = widget.options;
      } else {
        _filteredOptions = widget.options.where((opt) {
          final matchInvestor = opt.investorName.toLowerCase().contains(query);
          final matchProject = opt.projectName.toLowerCase().contains(query);
          final matchLocation = opt.projectLocation?.toLowerCase().contains(query) ?? false;
          final matchPhone = opt.phone?.toLowerCase().contains(query) ?? false;
          return matchInvestor || matchProject || matchLocation || matchPhone;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.preselectedInvestorName != null
        ? 'Select Project for Withdrawal (${widget.preselectedInvestorName})'
        : 'Select Investor & Project for Withdrawal';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 560),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titleText,
                    style: AppTypography.cardTitle.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar at Top
            TextField(
              controller: _searchController,
              autofocus: true,
              style: AppTypography.input.copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by investor, project name, location...',
                hintStyle: AppTypography.secondary.copyWith(fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.accent),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Search stats / count label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredOptions.length} ${_filteredOptions.length == 1 ? "agreement" : "agreements"} found',
                  style: AppTypography.secondary.copyWith(fontSize: 12),
                ),
                if (_searchController.text.isNotEmpty)
                  InkWell(
                    onTap: () => _searchController.clear(),
                    child: Text(
                      'Reset filter',
                      style: AppTypography.secondary.copyWith(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),

            // Scrollable List of Options
            Flexible(
              child: _filteredOptions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'No matching investor agreements found.',
                              style: AppTypography.secondary.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredOptions.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final opt = _filteredOptions[idx];

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                            child: const Icon(Icons.person, color: AppColors.accent, size: 20),
                          ),
                          title: Text(
                            '${opt.investorName} • ${opt.projectName}',
                            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Capital: ${CalculationEngine.formatCurrency(opt.capitalInvested)}  |  Available: ${CalculationEngine.formatCurrency(opt.remainingPayoutBalance)}',
                              style: AppTypography.secondary.copyWith(fontSize: 12),
                            ),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              PayoutDisbursementDialog.show(context, payout: opt.payout);
                            },
                            child: const Text('Withdraw', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Bottom Actions
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.dangerText,
                ),
                child: const Text('Cancel', style: TextStyle(color: AppColors.dangerText, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
