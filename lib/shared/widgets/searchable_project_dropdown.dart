import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/projects/domain/project_model.dart';

/// A sleek, searchable dropdown selector widget for selecting a Project with an inline search bar.
class SearchableProjectDropdown extends StatelessWidget {
  final List<ProjectModel> projects;
  final String? selectedProjectId;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;
  final String labelText;
  final String hintText;

  const SearchableProjectDropdown({
    super.key,
    required this.projects,
    required this.selectedProjectId,
    required this.onChanged,
    this.validator,
    this.labelText = 'Target Project *',
    this.hintText = 'Select or search project...',
  });

  @override
  Widget build(BuildContext context) {
    final selectedProject = projects.cast<ProjectModel?>().firstWhere(
          (p) => p?.id == selectedProjectId,
          orElse: () => null,
        );

    return FormField<String>(
      initialValue: selectedProjectId,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final chosenId = await showDialog<String>(
                  context: context,
                  builder: (context) => _ProjectSearchDialog(
                    projects: projects,
                    selectedProjectId: selectedProjectId,
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
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.accent),
                  suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                child: Text(
                  selectedProject != null
                      ? '${selectedProject.name} (${selectedProject.code}) - ${selectedProject.landAreaSqFt.round()} sq.ft'
                      : hintText,
                  style: selectedProject != null
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

class _ProjectSearchDialog extends StatefulWidget {
  final List<ProjectModel> projects;
  final String? selectedProjectId;

  const _ProjectSearchDialog({
    required this.projects,
    required this.selectedProjectId,
  });

  @override
  State<_ProjectSearchDialog> createState() => _ProjectSearchDialogState();
}

class _ProjectSearchDialogState extends State<_ProjectSearchDialog> {
  final _searchController = TextEditingController();
  late List<ProjectModel> _filteredProjects;

  @override
  void initState() {
    super.initState();
    _filteredProjects = widget.projects;
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
        _filteredProjects = widget.projects;
      } else {
        _filteredProjects = widget.projects.where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.code.toLowerCase().contains(query) ||
              p.location.toLowerCase().contains(query);
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
        width: 520,
        height: 520,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Target Project',
                  style: AppTypography.cardTitle.copyWith(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Search Input Field
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search project by name, code, or location...',
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
            // Projects List
            Expanded(
              child: _filteredProjects.isEmpty
                  ? Center(
                      child: Text(
                        'No matching projects found.',
                        style: AppTypography.secondary.copyWith(fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredProjects.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final project = _filteredProjects[index];
                        final isSelected = project.id == widget.selectedProjectId;

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
                              Icons.folder_outlined,
                              size: 16,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          title: Text(
                            '${project.name} (${project.code})',
                            style: AppTypography.body.copyWith(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? AppColors.accent : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Location: ${project.location} • Total Land: ${project.landAreaSqFt.round()} sq.ft',
                            style: AppTypography.secondary.copyWith(fontSize: 11),
                          ),
                          onTap: () => Navigator.of(context).pop(project.id),
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
