import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/landowners/domain/landowner_model.dart';

/// A searchable dropdown selector for Landowners with an auto-focused search bar modal.
class SearchableLandownerDropdown extends StatelessWidget {
  final List<LandownerModel> landowners;
  final String? selectedLandownerId;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;
  final String labelText;
  final String hintText;

  const SearchableLandownerDropdown({
    super.key,
    required this.landowners,
    required this.selectedLandownerId,
    required this.onChanged,
    this.validator,
    this.labelText = 'Landowner',
    this.hintText = '-- Select Landowner --',
  });

  @override
  Widget build(BuildContext context) {
    final selectedLandowner = landowners.cast<LandownerModel?>().firstWhere(
          (l) => l?.id == selectedLandownerId,
          orElse: () => null,
        );

    return FormField<String>(
      initialValue: selectedLandownerId,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final chosenId = await showDialog<String>(
                  context: context,
                  builder: (context) => _LandownerSearchDialog(
                    landowners: landowners,
                    selectedLandownerId: selectedLandownerId,
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
                  selectedLandowner != null
                      ? '${selectedLandowner.name} (${selectedLandowner.phone})'
                      : hintText,
                  style: selectedLandowner != null
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

class _LandownerSearchDialog extends StatefulWidget {
  final List<LandownerModel> landowners;
  final String? selectedLandownerId;

  const _LandownerSearchDialog({
    required this.landowners,
    required this.selectedLandownerId,
  });

  @override
  State<_LandownerSearchDialog> createState() => _LandownerSearchDialogState();
}

class _LandownerSearchDialogState extends State<_LandownerSearchDialog> {
  final _searchController = TextEditingController();
  late List<LandownerModel> _filteredLandowners;

  @override
  void initState() {
    super.initState();
    _filteredLandowners = widget.landowners;
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
        _filteredLandowners = widget.landowners;
      } else {
        _filteredLandowners = widget.landowners.where((l) {
          return l.name.toLowerCase().contains(query) ||
              l.phone.toLowerCase().contains(query) ||
              (l.email != null && l.email!.toLowerCase().contains(query));
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
                  'Select Landowner',
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
                hintText: 'Search landowner by name, phone...',
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
              child: _filteredLandowners.isEmpty
                  ? Center(
                      child: Text(
                        'No matching landowners found.',
                        style: AppTypography.secondary.copyWith(fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredLandowners.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final l = _filteredLandowners[index];
                        final isSelected = l.id == widget.selectedLandownerId;

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
                            l.name,
                            style: AppTypography.body.copyWith(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? AppColors.accent : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Phone: ${l.phone}${l.address != null ? ' • ${l.address}' : ''}',
                            style: AppTypography.secondary.copyWith(fontSize: 11),
                          ),
                          onTap: () => Navigator.of(context).pop(l.id),
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
