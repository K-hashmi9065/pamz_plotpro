import 'package:flutter/material.dart';
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

/// Enterprise Data Table with header styling, hoverable rows, loading, empty states,
/// and visible responsive horizontal scrollbar support.
class CustomDataTable extends StatefulWidget {
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
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  late final ScrollController _scrollController;
  late final ScrollController _verticalScrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _verticalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Loading data...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.rows.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.inbox_outlined,
                size: 26,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.emptyMessage,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = widget.columns.fold<double>(
            32.0, // 16px left + 16px right row padding
            (sum, col) => sum + (col.width ?? 180.0),
          );

          final minWidth = totalWidth > constraints.maxWidth
              ? totalWidth
              : constraints.maxWidth;

          final hasBoundedHeight = constraints.hasBoundedHeight;

          final rowsWidget = ListView.separated(
            controller: hasBoundedHeight ? _verticalScrollController : null,
            shrinkWrap: !hasBoundedHeight,
            physics: hasBoundedHeight ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
            itemCount: widget.rows.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, rowIndex) {
              final rowCells = widget.rows[rowIndex];
              return _DataTableRow(
                columns: widget.columns,
                rowCells: rowCells,
                rowIndex: rowIndex,
              );
            },
          );

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
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
                      ),
                      child: Row(
                        children: widget.columns.map((col) {
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
                          controller: _verticalScrollController,
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

class _DataTableRow extends StatefulWidget {
  final List<DataTableColumn> columns;
  final List<Widget> rowCells;
  final int rowIndex;

  const _DataTableRow({
    required this.columns,
    required this.rowCells,
    required this.rowIndex,
  });

  @override
  State<_DataTableRow> createState() => _DataTableRowState();
}

class _DataTableRowState extends State<_DataTableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        color: _isHovered ? AppColors.surfaceVariant : AppColors.surface,
        child: Row(
          children: List.generate(widget.columns.length, (colIndex) {
            final col = widget.columns[colIndex];
            final cellWidget = colIndex < widget.rowCells.length
                ? widget.rowCells[colIndex]
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
