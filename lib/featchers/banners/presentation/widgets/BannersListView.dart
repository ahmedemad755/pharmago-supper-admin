import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supper_admin/featchers/banners/entity/BannerEntity.dart';

import 'package:supper_admin/featchers/banners/manger/cubit/banners_cubit.dart';

class BannersListView extends StatelessWidget {
  const BannersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannersCubit, BannersState>(
      builder: (context, state) {
        // حالة التحميل
        if (state is GetBannersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // حالة النجاح (عرض القائمة)
        if (state is GetBannersSuccess) {
          final banners = state.banners;

          if (banners.isEmpty) {
            return const Center(child: Text("لا توجد عروض منشورة حالياً"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: banners.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          banner.imageUrl,
                          width: 80,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner.linkType == 'none'
                                  ? "عرض فقط"
                                  : "ربط بـ ${banner.linkType}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              banner.isActive ? "نشط" : "متوقف",
                              style: TextStyle(
                                color: banner.isActive
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _showDeleteDialog(context, banner),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        // حالة الفشل
        if (state is GetBannersFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.errMessage,
                  textAlign: TextAlign.center,
                ), // تم التأكد من المسمى هنا
                TextButton(
                  onPressed: () => context.read<BannersCubit>().getBanners(),
                  child: const Text("إعادة المحاولة"),
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  void _showDeleteDialog(BuildContext context, BannerEntity banner) {
    final bannersCubit = context.read<BannersCubit>();

    showDialog(
      context: context,
      barrierDismissible:
          false, // منع إغلاق النافذة بالضغط خارجها أثناء العملية
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("تأكيد الحذف"),
          ],
        ),
        content: const Text(
          "هل أنت متأكد من حذف هذا العرض؟ سيتم حذفه نهائياً من قاعدة البيانات والصور.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // تنفيذ الحذف باستخدام الكائن كاملاً
              bannersCubit.deleteBanner(banner);

              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("جاري معالجة طلب الحذف..."),
                  backgroundColor: Colors.black87,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              "حذف الآن",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
