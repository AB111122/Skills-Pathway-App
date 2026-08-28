import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../models/application_model.dart';
import '../../../../services/firebase_application_repository.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

class StudentApplicationsScreen extends ConsumerWidget {
  const StudentApplicationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentId = ref.watch(authControllerProvider).currentUser?.id ?? 'usr_student_01';
    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: FutureBuilder<List<ApplicationModel>>(
        future: FirebaseApplicationRepository().forStudent(studentId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text('No applications yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.p20),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final application = snapshot.data![index];
              return Card(child: ListTile(title: Text(application.opportunityTitle), subtitle: Text(application.universityName), trailing: Text(application.status.name)));
            },
          );
        },
      ),
    );
  }
}
