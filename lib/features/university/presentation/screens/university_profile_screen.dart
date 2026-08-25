import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

class UniversityProfileScreen extends ConsumerWidget {
  const UniversityProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authControllerProvider).organizationProfile;
    final name = profile?.orgName ?? 'University';
    return Scaffold(
      appBar: AppBar(title: const Text('University Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.p20),
        children: [
          CircleAvatar(radius: 42, child: Text(name.substring(0, 1))),
          const SizedBox(height: 16),
          Text(name, style: Theme.of(context).textTheme.headlineSmall),
          if (profile?.isVerified == true)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: VerifiedBadge(isVerified: true),
            ),
          const SizedBox(height: 20),
          Text(profile?.orgType ?? 'University / Higher Education'),
          Text(profile?.city ?? 'Location not provided'),
          const SizedBox(height: 12),
          Text(profile?.website ?? 'Website not provided'),
          Text(profile?.officialEmail ?? 'Contact email not provided'),
        ],
      ),
    );
  }
}
