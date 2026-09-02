import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../models/opportunity_model.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../university_provider.dart';

class CreateOpportunityScreen extends ConsumerStatefulWidget {
  final OpportunityModel? opportunity;
  const CreateOpportunityScreen({super.key, this.opportunity});
  @override
  ConsumerState<CreateOpportunityScreen> createState() =>
      _CreateOpportunityScreenState();
}

class _CreateOpportunityScreenState
    extends ConsumerState<CreateOpportunityScreen> {
  late final TextEditingController _title,
      _description,
      _location,
      _url,
      _deadline;
  OpportunityType? _type;
  bool _isSaving = false;
  @override
  void initState() {
    super.initState();
    final item = widget.opportunity;
    _title = TextEditingController(text: item?.title);
    _description = TextEditingController(text: item?.fullDescription);
    _location = TextEditingController(text: item?.location);
    _url = TextEditingController(text: item?.officialUrl);
    _deadline = TextEditingController(
      text: item?.deadline.toIso8601String().split('T').first,
    );
    _type = item?.type;
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _description,
      _location,
      _url,
      _deadline,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final deadline = DateTime.tryParse(_deadline.text.trim());
    if (_title.text.trim().isEmpty ||
        _description.text.trim().isEmpty ||
        _type == null ||
        deadline == null ||
        _url.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete title, description, type, deadline, and application URL.',
          ),
        ),
      );
      return;
    }
    final auth = ref.read(authControllerProvider);
    final organizationId = auth.currentUser?.id;
    final organizationName =
        auth.organizationProfile?.orgName ?? auth.currentUser?.name ?? '';
    if (organizationId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final repository = ref.read(universityRepositoryProvider);
      if (widget.opportunity == null) {
        await repository.createOpportunity(
          organizationId: organizationId,
          organizationName: organizationName,
          title: _title.text.trim(),
          description: _description.text.trim(),
          type: _type!,
          deadline: deadline,
          location: _location.text.trim().isEmpty
              ? 'Not specified'
              : _location.text.trim(),
          applicationUrl: _url.text.trim(),
        );
      } else {
        await repository.updateOpportunity(
          organizationId,
          widget.opportunity!.copyWith(
            title: _title.text.trim(),
            fullDescription: _description.text.trim(),
            shortDescription: _description.text.trim(),
            type: _type!,
            deadline: deadline,
            location: _location.text.trim(),
            officialUrl: _url.text.trim(),
          ),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.opportunity == null
                ? 'Opportunity published'
                : 'Changes saved',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_friendlyError(error))));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('permission-denied')) {
      return "You don't have permission to perform this action.";
    }
    if (message.contains('unauthenticated') || message.contains('sign in')) {
      return 'Your session has expired. Please log in again.';
    }
    if (message.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.opportunity == null ? 'Create Opportunity' : 'Edit Opportunity',
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(AppDimensions.p20),
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<OpportunityType>(
          initialValue: _type,
          decoration: const InputDecoration(labelText: 'Opportunity Type'),
          items: OpportunityType.values
              .map(
                (type) =>
                    DropdownMenuItem(value: type, child: Text(type.label)),
              )
              .toList(),
          onChanged: (value) => setState(() => _type = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _location,
          decoration: const InputDecoration(labelText: 'Location'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _deadline,
          decoration: const InputDecoration(labelText: 'Deadline (YYYY-MM-DD)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _url,
          decoration: const InputDecoration(labelText: 'Application URL'),
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: widget.opportunity == null
              ? 'Publish Opportunity'
              : 'Save Changes',
          icon: Icons.publish,
          isLoading: _isSaving,
          onPressed: _isSaving ? null : _save,
        ),
      ],
    ),
  );
}
