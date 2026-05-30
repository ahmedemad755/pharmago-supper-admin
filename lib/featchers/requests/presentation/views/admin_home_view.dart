import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:supper_admin/featchers/requests/presentation/manger/cubit/request_pharmacy_cubit.dart';
import 'package:supper_admin/featchers/requests/presentation/manger/cubit/request_pharmacy_state.dart';
import 'package:supper_admin/featchers/requests/presentation/views/widgets/admin_home_drawer.dart';
import 'package:supper_admin/featchers/requests/presentation/views/widgets/custom_expansion_card.dart';
import 'package:supper_admin/featchers/requests/presentation/views/widgets/requests_state_widgets.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  static const String _settingsCollection = 'app_settings';
  static const String _supportDocument = 'support';
  static const String _supportPhoneField = 'phoneNumber';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'لوحة التحكم',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal.shade800,
      ),
      drawer: AdminHomeDrawer(
        onSupportPhoneTap: () => _showSupportPhoneDialog(context),
      ),
      body: BlocBuilder<RequestsCubit, RequestsState>(
        builder: (context, state) {
          if (state is RequestsLoading) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            );
          }

          if (state is RequestsSuccess) {
            if (state.requests.isEmpty) {
              return const RequestsEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<RequestsCubit>().fetchAllRequests();
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 100),
                itemCount: state.requests.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) => CustomerExpansionCard(
                  request: state.requests[index],
                ),
              ),
            );
          }

          if (state is RequestsError) {
            return RequestsErrorState(
              message: state.message,
              onRetry: () => context.read<RequestsCubit>().fetchAllRequests(),
            );
          }

          return const RequestsEmptyState();
        },
      ),
    );
  }

  // الحوار الخاص بتعديل رقم الدعم تم الإبقاء عليه هنا لارتباطه المباشر بالـ Firestore context الخاص بهذه الصفحة
  Future<void> _showSupportPhoneDialog(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    final settingsDoc = FirebaseFirestore.instance
        .collection(_settingsCollection)
        .doc(_supportDocument);

    final snapshot = await settingsDoc.get();
    controller.text = snapshot.data()?[_supportPhoneField]?.toString() ?? '';

    if (!context.mounted) {
      controller.dispose();
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            Future<void> savePhone() async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              setState(() => isSaving = true);

              try {
                await settingsDoc.set(
                  {
                    _supportPhoneField: controller.text.trim(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  },
                  SetOptions(merge: true),
                );

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث رقم الدعم بنجاح')),
                );
              } catch (_) {
                if (!dialogContext.mounted) return;

                setState(() => isSaving = false);
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('حدث خطأ أثناء تحديث رقم الدعم'),
                  ),
                );
              }
            }

            return AlertDialog(
              title: const Text('رقم الدعم'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'رقم هاتف الدعم',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اكتب رقم الدعم';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) async {
                    if (!isSaving) await savePhone();
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton.icon(
                  onPressed: isSaving ? null : savePhone,
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('تأكيد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }
}