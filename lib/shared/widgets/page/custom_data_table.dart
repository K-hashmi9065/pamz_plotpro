import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class DataTableColumn {
  final String label;
  final double? width;
  final Alignment alignment;

  const DataTableColumn({
    required this.label,
    this.width,
    this.alignment = Alignment.centerLeft,
  });
}

final tableHoveredRowProvider = StateProvider.autoDispose.family<bool, int>((ref, rowIndex) => false);

/// Enterprise Data Table with header styling, hoverable rows, loading, empty states,
/// and visible responsive horizontal scrollbar support.
class CustomDataTable extends ConsumerWidget {
  final List<DataTableColumn> columns;
  final List<List<Widget>> rows;
  final bool isLoading;
  final String emptyMessage;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.emptyMessage = 'No records found.',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = ScrollController();
    final verticalScrollController = ScrollController();

    if (isLoading) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.accent,
        ),
      );
    }

    if (rows.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 44,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 10),
            Text(
              emptyMessage,
              style: AppTypography.secondary.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = columns.fold<double>(
            32.0, // 16px left + 16px right row padding
            (sum, col) => sum + (col.width ?? 180.0),
          );

          final minWidth = totalWidth > constraints.maxWidth
              ? totalWidth
              : constraints.maxWidth;

          final hasBoundedHeight = constraints.hasBoundedHeight;

          final rowsWidget = ListView.separated(
            controller: hasBoundedHeight ? verticalScrollController : null,
            shrinkWrap: !hasBoundedHeight,
            physics: hasBoundedHeight ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, rowIndex) {
              final rowCells = rows[rowIndex];
              return _DataTableRow(
                columns: columns,
                rowCells: rowCells,
                rowIndex: rowIndex,
              );
            },
          );

          return Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: minWidth,
                height: hasBoundedHeight ? constraints.maxHeight : null,
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        border: Border(
                          bottom: BorderSide(color: AppColors.border),
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                      ),
                      child: Row(
                        children: columns.map((col) {
                          final headerWidget = Container(
                            alignment: col.alignment,
                            child: Text(
                              col.label.toUpperCase(),
                              style: AppTypography.tableHeader,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                          return col.width != null
                              ? SizedBox(width: col.width, child: headerWidget)
                              : Expanded(child: headerWidget);
                        }).toList(),
                      ),
                    ),
                    // Table Rows with Hover Effect
                    if (hasBoundedHeight)
                      Expanded(
                        child: Scrollbar(
                          controller: verticalScrollController,
                          thumbVisibility: true,
                          child: rowsWidget,
                        ),
                      )
                    else
                      rowsWidget,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DataTableRow extends ConsumerWidget {
  final List<DataTableColumn> columns;
  final List<Widget> rowCells;
  final int rowIndex;

  const _DataTableRow({
    required this.columns,
    required this.rowCells,
    required this.rowIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = ref.watch(tableHoveredRowProvider(rowIndex));

    return MouseRegion(
      onEnter: (_) => ref.read(tableHoveredRowProvider(rowIndex).notifier).state = true,
      onExit: (_) => ref.read(tableHoveredRowProvider(rowIndex).notifier).state = false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isHovered ? AppColors.surfaceVariant : AppColors.surface,
        child: Row(
          children: List.generate(columns.length, (colIndex) {
            final col = columns[colIndex];
            final cellWidget = colIndex < rowCells.length
                ? rowCells[colIndex]
                : const SizedBox();

            final containerWidget = Container(
              alignment: col.alignment,
              child: cellWidget,
            );

            return col.width != null
                ? SizedBox(width: col.width, child: containerWidget)
                : Expanded(child: containerWidget);
          }),
        ),
      ),
    );
  }
}
