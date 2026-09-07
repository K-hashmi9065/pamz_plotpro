import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/investors/domain/investor_model.dart';

/// A searchable dropdown selector for Investors with an auto-focused search bar modal.
class SearchableInvestorDropdown extends StatelessWidget {
  final List<InvestorModel> investors;
  final String? selectedInvestorId;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;
  final String labelText;
  final String hintText;

  const SearchableInvestorDropdown({
    super.key,
    required this.investors,
    required this.selectedInvestorId,
    required this.onChanged,
    this.validator,
    this.labelText = 'Select Investor *',
    this.hintText = 'Select or search investor...',
  });

  @override
  Widget build(BuildContext context) {
    final selectedInvestor = investors.cast<InvestorModel?>().firstWhere(
          (i) => i?.id == selectedInvestorId,
          orElse: () => null,
        );

    return FormField<String>(
      initialValue: selectedInvestorId,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final chosenId = await showDialog<String>(
                  context: context,
                  builder: (context) => _InvestorSearchDialog(
                    investors: investors,
                    selectedInvestorId: selectedInvestorId,
                  ),
                );
                if (chosenId != null) {
                  onChanged(chosenId);
                  state.didChange(chosenId);
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: labelText,
                  errorText: state.errorText,
                  prefixIcon: const Icon(Icons.person_search_outlined, size: 18, color: AppColors.accent),
                  suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                child: Text(
                  selectedInvestor != null
                      ? '${selectedInvestor.name} (${selectedInvestor.phone})'
                      : hintText,
                  style: selectedInvestor != null
                      ? AppTypography.body.copyWith(fontSize: 13, fontWeight: FontWeight.w600)
                      : AppTypography.secondary.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InvestorSearchDialog extends StatefulWidget {
  final List<InvestorModel> investors;
  final String? selectedInvestorId;

  const _InvestorSearchDialog({
    required this.investors,
    required this.selectedInvestorId,
  });

  @override
  State<_InvestorSearchDialog> createState() => _InvestorSearchDialogState();
}

class _InvestorSearchDialogState extends State<_InvestorSearchDialog> {
  final _searchController = TextEditingController();
  late List<InvestorModel> _filteredInvestors;

  @override
  void initState() {
    super.initState();
    _filteredInvestors = widget.investors;
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
        _filteredInvestors = widget.investors;
      } else {
        _filteredInvestors = widget.investors.where((i) {
          return i.name.toLowerCase().contains(query) ||
              i.phone.toLowerCase().contains(query) ||
              (i.email != null && i.email!.toLowerCase().contains(query)) ||
              (i.pan != null && i.pan!.toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 500,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Investor',
                  style: AppTypography.cardTitle.copyWith(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search investor by name, phone, PAN...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              style: AppTypography.input.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _filteredInvestors.isEmpty
                  ? Center(
                      child: Text(
                        'No matching investors found.',
                        style: AppTypography.secondary.copyWith(fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredInvestors.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final i = _filteredInvestors[index];
                        final isSelected = i.id == widget.selectedInvestorId;

                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: AppColors.surfaceSubtle,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: isSelected ? AppColors.accent : AppColors.surfaceVariant,
                            child: Icon(
                              Icons.person_outline,
                              size: 16,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          title: Text(
                            i.name,
                            style: AppTypography.body.copyWith(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? AppColors.accent : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Phone: ${i.phone}${i.pan != null ? ' • PAN: ${i.pan}' : ''}',
                            style: AppTypography.secondary.copyWith(fontSize: 11),
                          ),
                          onTap: () => Navigator.of(context).pop(i.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
