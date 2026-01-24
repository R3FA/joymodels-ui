import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/model/enums/report_reason_api_enum.dart';
import 'package:joymodels_mobile/data/model/enums/reported_entity_type_api_enum.dart';
import 'package:joymodels_mobile/data/model/report/request_types/report_create_request_api_model.dart';
import 'package:joymodels_mobile/data/repositories/report_repository.dart';

class ReportDialog extends StatefulWidget {
  final ReportedEntityTypeApiEnum entityType;
  final String entityUuid;
  final String? entityDescription;

  const ReportDialog({
    super.key,
    required this.entityType,
    required this.entityUuid,
    this.entityDescription,
  });

  static Future<bool?> show({
    required BuildContext context,
    required ReportedEntityTypeApiEnum entityType,
    required String entityUuid,
    String? entityDescription,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ReportDialog(
        entityType: entityType,
        entityUuid: entityUuid,
        entityDescription: entityDescription,
      ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _reportRepository = sl<ReportRepository>();
  final _descriptionController = TextEditingController();

  ReportReasonApiEnum? _selectedReason;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      setState(() {
        _errorMessage = 'Please select a reason';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final request = ReportCreateRequestApiModel(
        reportedEntityType: widget.entityType.toApiString(),
        reportedEntityUuid: widget.entityUuid,
        reason: _selectedReason!.toApiString(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      await _reportRepository.create(request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('already reported')) {
          _errorMessage = 'You have already reported this content';
        } else {
          _errorMessage = 'Failed to submit report. Please try again.';
        }
      });
    }
  }

  String _getTitle() {
    switch (widget.entityType) {
      case ReportedEntityTypeApiEnum.user:
        return 'Report User';
      case ReportedEntityTypeApiEnum.communityPost:
        return 'Report Post';
      case ReportedEntityTypeApiEnum.communityPostComment:
        return 'Report Comment';
      case ReportedEntityTypeApiEnum.modelReview:
        return 'Report Review';
      case ReportedEntityTypeApiEnum.modelFaqQuestion:
        return 'Report Question';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(_getTitle()),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.entityDescription != null) ...[
                Text(
                  'Reporting:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.entityDescription!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Reason for reporting:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              RadioGroup<ReportReasonApiEnum>(
                groupValue: _selectedReason,
                onChanged: (value) {
                  if (_isSubmitting) return;
                  setState(() {
                    _selectedReason = value;
                    _errorMessage = null;
                  });
                },
                child: Column(
                  children: ReportReasonApiEnum.values.map((reason) {
                    return ListTile(
                      title: Text(reason.displayName),
                      leading: Radio<ReportReasonApiEnum>(value: reason),
                      onTap: _isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _selectedReason = reason;
                                _errorMessage = null;
                              });
                            },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Additional details (optional)',
                  border: const OutlineInputBorder(),
                  enabled: !_isSubmitting,
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submitReport,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
