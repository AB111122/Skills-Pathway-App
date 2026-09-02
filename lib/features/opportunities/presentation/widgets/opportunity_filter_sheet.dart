import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../models/opportunity_filter_model.dart';
import '../../../../models/opportunity_model.dart';

/// Modal bottom sheet for multi-criteria filtering of Scholarships and Internships.
class OpportunityFilterSheet extends StatefulWidget {
  final OpportunityFilterModel initialFilter;
  final ValueChanged<OpportunityFilterModel> onApply;

  const OpportunityFilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<OpportunityFilterSheet> createState() => _OpportunityFilterSheetState();
}

class _OpportunityFilterSheetState extends State<OpportunityFilterSheet> {
  late OpportunityType? _type;
  late String _location;
  late String _field;
  late String _degreeLevel;
  late bool _isPaidOnly;
  late bool _isFullyFundedOnly;
  late bool _isVerifiedOnly;

  final List<String> _locations = [
    'All',
    'Islamabad',
    'Lahore',
    'Karachi',
    'Remote',
    'United Kingdom',
    'United States',
  ];

  final List<String> _fields = [
    'All',
    'Computer Science & AI',
    'Software Engineering',
    'Business & Finance',
    'Electrical / Mechanical Engineering',
    'Biotechnology',
  ];

  final List<String> _degreeLevels = [
    'All',
    'High School',
    'Undergraduate',
    'Master\'s',
    'Fresh Grad',
    'PhD',
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.initialFilter.opportunityType;
    _location = widget.initialFilter.location ?? 'All';
    _field = widget.initialFilter.field ?? 'All';
    _degreeLevel = widget.initialFilter.degreeLevel ?? 'All';
    _isPaidOnly = widget.initialFilter.isPaidOnly;
    _isFullyFundedOnly = widget.initialFilter.isFullyFundedOnly;
    _isVerifiedOnly = widget.initialFilter.isVerifiedOnly;
  }

  void _reset() {
    setState(() {
      _type = null;
      _location = 'All';
      _field = 'All';
      _degreeLevel = 'All';
      _isPaidOnly = false;
      _isFullyFundedOnly = false;
      _isVerifiedOnly = false;
    });
  }

  void _apply() {
    final updated = OpportunityFilterModel(
      searchQuery: widget.initialFilter.searchQuery,
      opportunityType: _type,
      location: _location == 'All' ? null : _location,
      field: _field == 'All' ? null : _field,
      degreeLevel: _degreeLevel == 'All' ? null : _degreeLevel,
      isPaidOnly: _isPaidOnly,
      isFullyFundedOnly: _isFullyFundedOnly,
      isVerifiedOnly: _isVerifiedOnly,
    );
    widget.onApply(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardBorderDark
                  : AppColors.cardBorderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filter Opportunities',
                      style: AppTextStyles.titleMedium(context),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _reset,
                  child: Text(
                    'Reset All',
                    style: AppTextStyles.labelMedium(
                      context,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Filter Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Opportunity Type
                  Text(
                    'Opportunity Type',
                    style: AppTextStyles.labelMedium(context),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'All Types',
                          isSelected: _type == null,
                          onSelected: () => setState(() => _type = null),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Scholarships',
                          isSelected: _type == OpportunityType.scholarship,
                          onSelected: () => setState(
                            () => _type = OpportunityType.scholarship,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Internships',
                          isSelected: _type == OpportunityType.internship,
                          onSelected: () => setState(
                            () => _type = OpportunityType.internship,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Verified Only Toggle (Strict Requirement)
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.p12),
                    decoration: BoxDecoration(
                      color: AppColors.verifiedBadge.withValues(alpha: 0.08),
                      borderRadius: AppDimensions.roundedMedium,
                      border: Border.all(
                        color: AppColors.verifiedBadge.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              color: AppColors.verifiedBadge,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verified Listings Only',
                                  style: AppTextStyles.labelMedium(context),
                                ),
                                Text(
                                  'Only show verified universities & firms',
                                  style: AppTextStyles.labelSmall(
                                    context,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _isVerifiedOnly,
                          activeThumbColor: AppColors.verifiedBadge,
                          onChanged: (val) {
                            setState(() => _isVerifiedOnly = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Location / Country
                  Text(
                    'Location / Region',
                    style: AppTextStyles.labelMedium(context),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _locations.map((loc) {
                      final isSelected = _location == loc;
                      return ChoiceChip(
                        label: Text(loc),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(
                          alpha: 0.15,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : null,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        onSelected: (_) => setState(() => _location = loc),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 4. Field of Study
                  Text(
                    'Field of Study',
                    style: AppTextStyles.labelMedium(context),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _fields.map((f) {
                      final isSelected = _field == f;
                      return ChoiceChip(
                        label: Text(f),
                        selected: isSelected,
                        selectedColor: AppColors.secondary.withValues(
                          alpha: 0.15,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.secondary : null,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        onSelected: (_) => setState(() => _field = f),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 5. Degree Level
                  Text(
                    'Degree Level',
                    style: AppTextStyles.labelMedium(context),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _degreeLevels.map((deg) {
                      final isSelected = _degreeLevel == deg;
                      return ChoiceChip(
                        label: Text(deg),
                        selected: isSelected,
                        selectedColor: AppColors.accentGold.withValues(
                          alpha: 0.2,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.accentGold : null,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        onSelected: (_) => setState(() => _degreeLevel = deg),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 6. Additional Filters (Paid & Fully Funded)
                  Text(
                    'Funding & Compensation',
                    style: AppTextStyles.labelMedium(context),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Paid Internships Only',
                      style: AppTextStyles.bodyMedium(context),
                    ),
                    subtitle: Text(
                      'Includes monthly stipend in PKR',
                      style: AppTextStyles.bodySmall(context),
                    ),
                    value: _isPaidOnly,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _isPaidOnly = val ?? false);
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Fully Funded Scholarships Only',
                      style: AppTextStyles.bodyMedium(context),
                    ),
                    subtitle: Text(
                      'Covers 100% tuition + living costs',
                      style: AppTextStyles.bodySmall(context),
                    ),
                    value: _isFullyFundedOnly,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _isFullyFundedOnly = val ?? false);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Bottom Action
          Padding(
            padding: const EdgeInsets.all(AppDimensions.p20),
            child: CustomButton(
              text: 'Apply Filters',
              variant: ButtonVariant.gradient,
              icon: Icons.check_rounded,
              onPressed: _apply,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: AppDimensions.roundedMedium,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: AppDimensions.roundedMedium,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}
