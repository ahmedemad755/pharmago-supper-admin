import 'package:flutter/foundation.dart'; // للتحقق من kIsWeb
import 'dart:io'; // اجعله احتياطياً فقط للموبايل
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supper_admin/featchers/banners/manger/cubit/banners_cubit.dart';

class AddBannerForm extends StatefulWidget {
  const AddBannerForm({super.key});

  @override
  State<AddBannerForm> createState() => _AddBannerFormState();
}

class _AddBannerFormState extends State<AddBannerForm> {
  String selectedType = 'none';
  bool isActive = true;
  final TextEditingController targetIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BannersCubit, BannersState>(
      listener: (context, state) {
        if (state is AddBannerSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ تم إضافة العرض بنجاح')),
          );
          targetIdController.clear();
        } else if (state is AddBannerFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<BannersCubit>();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "صورة العرض",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // مساحة اختيار الصورة المعدلة
              GestureDetector(
                onTap: () => cubit.pickImage(),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: cubit.selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: kIsWeb
                              ? Image.network(
                                  cubit.selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(cubit.selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: Colors.blue,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "اضغط لاختيار صورة العرض",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
              
              // ... (باقي الكود الخاص بـ Dropdown والـ TextField يبقى كما هو)
              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                initialValue: selectedType, // تم تغيير initialValue إلى value
                decoration: InputDecoration(
                  labelText: 'ماذا يحدث عند الضغط على العرض؟',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('لا شيء (عرض فقط)')),
                  DropdownMenuItem(value: 'product', child: Text('فتح صفحة منتج')),
                  DropdownMenuItem(value: 'category', child: Text('فتح قسم معين')),
                ],
                onChanged: (val) => setState(() => selectedType = val!),
              ),

              if (selectedType != 'none') ...[
                const SizedBox(height: 20),
                TextField(
                  controller: targetIdController,
                  decoration: InputDecoration(
                    labelText: selectedType == 'product'
                        ? 'ادخل معرف المنتج (ID)'
                        : 'ادخل اسم القسم',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(
                      selectedType == 'product' ? Icons.inventory_2 : Icons.category,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'تفعيل العرض فوراً',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val),
                ),
              ),

              const SizedBox(height: 32),
              state is AddBannerLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        cubit.addBanner(
                          linkType: selectedType,
                          targetId: targetIdController.text,
                          isActive: isActive,
                        );
                      },
                      child: const Text(
                        'نشر العرض الآن',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}