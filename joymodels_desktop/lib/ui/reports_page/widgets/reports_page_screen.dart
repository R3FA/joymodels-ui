import 'package:flutter/material.dart';
import 'package:joymodels_desktop/data/model/enums/report_reason_api_enum.dart';
import 'package:joymodels_desktop/data/model/enums/report_status_api_enum.dart';
import 'package:joymodels_desktop/data/model/enums/reported_entity_type_api_enum.dart';
import 'package:joymodels_desktop/data/model/report/response_types/report_response_api_model.dart';
import 'package:joymodels_desktop/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_desktop/ui/reports_page/view_model/reports_page_view_model.dart';
import 'package:provider/provider.dart';

class ReportsPageScreen extends StatefulWidget {
  final VoidCallback? onSessionExpired;
  final VoidCallback? onForbidden;
  final VoidCallback? onNetworkError;

  const ReportsPageScreen({
    super.key,
    this.onSessionExpired,
    this.onForbidden,
    this.onNetworkError,
  });

  @override
  State<ReportsPageScreen> createState() => _ReportsPageScreenState();
}

class _ReportsPageScreenState extends State<ReportsPageScreen> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ReportsPageViewModel>();
    viewModel.onSessionExpired = widget.onSessionExpired;
    viewModel.onForbidden = widget.onForbidden;
    viewModel.onNetworkError = widget.onNetworkError;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.init();
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReportsPageViewModel>();
    final theme = Theme.of(context);
    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        viewModel.clearErrorMessage();
      });
    }

    return Column(
      children: [
        _buildFilterBar(viewModel, theme),
        Expanded(
          child: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.items.isEmpty
              ? Center(
                  child: Text(
                    'No reports found.',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : _buildDataTable(viewModel.items, viewModel, theme),
        ),
        if (viewModel.paginationData != null)
          PaginationControls(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            totalRecords: viewModel.totalRecords,
            hasPreviousPage: viewModel.hasPreviousPage,
            hasNextPage: viewModel.hasNextPage,
            isLoading: viewModel.isLoadingPage,
            onPreviousPage: () => viewModel.onPreviousPage(),
            onNextPage: () => viewModel.onNextPage(),
          ),
      ],
    );
  }

  Widget _buildFilterBar(ReportsPageViewModel viewModel, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: viewModel.filterStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...ReportStatusApiEnum.values.map(
                  (s) => DropdownMenuItem(value: s.name, child: Text(s.name)),
                ),
              ],
              onChanged: (value) {
                viewModel.setFilterStatus(value);
                viewModel.searchReports();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: viewModel.filterEntityType,
              decoration: InputDecoration(
                labelText: 'Entity Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...ReportedEntityTypeApiEnum.values.map(
                  (t) => DropdownMenuItem(value: t.name, child: Text(t.name)),
                ),
              ],
              onChanged: (value) {
                viewModel.setFilterEntityType(value);
                viewModel.searchReports();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: viewModel.filterReason,
              decoration: InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...ReportReasonApiEnum.values.map(
                  (r) => DropdownMenuItem(value: r.name, child: Text(r.name)),
                ),
              ],
              onChanged: (value) {
                viewModel.setFilterReason(value);
                viewModel.searchReports();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
    List<ReportResponseApiModel> reports,
    ReportsPageViewModel viewModel,
    ThemeData theme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Reporter')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Reason')),
                    DataColumn(label: Text('Preview')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Created')),
                  ],
                  rows: reports
                      .map((r) => _buildReportRow(r, viewModel, theme))
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildReportRow(
    ReportResponseApiModel report,
    ReportsPageViewModel viewModel,
    ThemeData theme,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(report.reporter.nickName),
          onTap: () => _showReportDetailDialog(context, viewModel, report),
        ),
        DataCell(
          Text(report.reportedEntityType),
          onTap: () => _showReportDetailDialog(context, viewModel, report),
        ),
        DataCell(
          Text(report.reason),
          onTap: () => _showReportDetailDialog(context, viewModel, report),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              report.getPreviewText() ?? '-',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          onTap: () => _showReportDetailDialog(context, viewModel, report),
        ),
        DataCell(
          _buildStatusChip(report.status, theme),
          onTap: () => _showReportDetailDialog(context, viewModel, report),
        ),
        DataCell(
          Text(_formatDate(report.createdAt)),
          onTap: () => _showReportDetailDialog(context, viewModel, report),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    final Color chipColor;
    switch (status) {
      case 'Pending':
        chipColor = Colors.orange;
      case 'Reviewed':
        chipColor = Colors.blue;
      case 'Resolved':
        chipColor = Colors.green;
      case 'Dismissed':
        chipColor = Colors.grey;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  void _showReportDetailDialog(
    BuildContext ctx,
    ReportsPageViewModel viewModel,
    ReportResponseApiModel report,
  ) {
    final isReadOnly =
        report.status == ReportStatusApiEnum.Resolved.name ||
        report.status == ReportStatusApiEnum.Dismissed.name;
    bool isSaving = false;
    bool isDeletingContent = false;

    showDialog(
      context: ctx,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Expanded(child: Text('Report Details')),
                  _buildStatusChip(report.status, theme),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDetailRow(
                        'Reporter',
                        report.reporter.nickName,
                        theme,
                      ),
                      _buildDetailRow(
                        'Entity Type',
                        report.reportedEntityType,
                        theme,
                      ),
                      _buildDetailRow('Reason', report.reason, theme),
                      if (report.description != null &&
                          report.description!.isNotEmpty)
                        _buildDetailRow(
                          'Description',
                          report.description!,
                          theme,
                        ),
                      _buildDetailRow(
                        'Created',
                        _formatDate(report.createdAt),
                        theme,
                      ),
                      if (report.reviewedBy != null)
                        _buildDetailRow(
                          'Reviewed By',
                          report.reviewedBy!.nickName,
                          theme,
                        ),
                      if (report.reviewedAt != null)
                        _buildDetailRow(
                          'Reviewed At',
                          _formatDate(report.reviewedAt!),
                          theme,
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Reported Content',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (!isReadOnly && report.getPreviewText() != null)
                            TextButton.icon(
                              onPressed: isDeletingContent
                                  ? null
                                  : () => _showDeleteContentConfirmation(
                                      context,
                                      viewModel,
                                      report,
                                      onStartDeleting: () {
                                        setState(
                                          () => isDeletingContent = true,
                                        );
                                      },
                                      onDeleteComplete: () async {
                                        await viewModel.updateReportStatus(
                                          report.uuid,
                                          ReportStatusApiEnum.Resolved.name,
                                        );
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    ),
                              icon: isDeletingContent
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: theme.colorScheme.error,
                                    ),
                              label: Text(
                                'Delete Content',
                                style: TextStyle(
                                  color: isDeletingContent
                                      ? null
                                      : theme.colorScheme.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          report.getPreviewText() ?? 'No content available',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                if (!isReadOnly)
                  FilledButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            setState(() => isSaving = true);
                            await viewModel.updateReportStatus(
                              report.uuid,
                              ReportStatusApiEnum.Dismissed.name,
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Dismiss'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  void _showDeleteContentConfirmation(
    BuildContext ctx,
    ReportsPageViewModel viewModel,
    ReportResponseApiModel report, {
    required VoidCallback onStartDeleting,
    required VoidCallback onDeleteComplete,
  }) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reported Content'),
        content: Text(
          'Are you sure you want to permanently delete this '
          '${report.reportedEntityType}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              onStartDeleting();
              await viewModel.deleteReportedContent(
                report.reportedEntityType,
                report.reportedEntityUuid,
              );
              onDeleteComplete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
