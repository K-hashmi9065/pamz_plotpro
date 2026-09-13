import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/buyers_sales/domain/buyer_model.dart';

/// A searchable dropdown selector for Buyers with an auto-focused search bar modal.
class SearchableBuyerDropdown extends StatelessWidget {
  final List<BuyerModel> buyers;
  final String? selectedBuyerId;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;
  final String labelText;
  final String hintText;

  const SearchableBuyerDropdown({
    super.key,
    required this.buyers,
    required this.selectedBuyerId,
    required this.onChanged,
    this.validator,
    this.labelText = 'Customer *',
    this.hintText = 'Select or search customer...',
  });

  @override
  Widget build(BuildContext context) {
    final selectedBuyer = buyers.cast<BuyerModel?>().firstWhere(
          (b) => b?.id == selectedBuyerId,
          orElse: () => null,
        );

    return FormField<String>(
      initialValue: selectedBuyerId,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final chosenId = await showDialog<String>(
                  context: context,
                  builder: (context) => _BuyerSearchDialog(
                    buyers: buyers,
                    selectedBuyerId: selectedBuyerId,
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
                  selectedBuyer != null
                      ? '${selectedBuyer.name} (${selectedBuyer.phone})'
                      : hintText,
                  style: selectedBuyer != null
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

class _BuyerSearchDialog extends StatefulWidget {
  final List<BuyerModel> buyers;
  final String? selectedBuyerId;

  const _BuyerSearchDialog({
    required this.buyers,
    required this.selectedBuyerId,
  });

  @override
  State<_BuyerSearchDialog> createState() => _BuyerSearchDialogState();
}

class _BuyerSearchDialogState extends State<_BuyerSearchDialog> {
  final _searchController = TextEditingController();
  late List<BuyerModel> _filteredBuyers;

  @override
  void initState() {
    super.initState();
    _filteredBuyers = widget.buyers;
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
        _filteredBuyers = widget.buyers;
      } else {
        _filteredBuyers = widget.buyers.where((b) {
          return b.name.toLowerCase().contains(query) ||
              b.phone.toLowerCase().contains(query) ||
              (b.email != null && b.email!.toLowerCase().contains(query)) ||
              (b.pan != null && b.pan!.toLowerCase().contains(query));
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
                  'Select Customer',
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
                hintText: 'Search customer by name, phone, PAN...',
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
              child: _filteredBuyers.isEmpty
                  ? Center(
                      child: Text(
                        'No matching customers found.',
                        style: AppTypography.secondary.copyWith(fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredBuyers.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final b = _filteredBuyers[index];
                        final isSelected = b.id == widget.selectedBuyerId;

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
                            b.name,
                            style: AppTypography.body.copyWith(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? AppColors.accent : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Phone: ${b.phone}${b.pan != null ? ' • PAN: ${b.pan}' : ''}',
                            style: AppTypography.secondary.copyWith(fontSize: 11),
                          ),
                          onTap: () => Navigator.of(context).pop(b.id),
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
