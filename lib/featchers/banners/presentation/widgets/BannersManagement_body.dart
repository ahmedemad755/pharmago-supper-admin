import 'package:flutter/material.dart';
import 'package:supper_admin/featchers/banners/presentation/widgets/AddBannerForm.dart';
import 'package:supper_admin/featchers/banners/presentation/widgets/BannersListView.dart';

class BannersManagement_body extends StatelessWidget {
  const BannersManagement_body({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة العروض البصرية'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'العروض الحالية', icon: Icon(Icons.view_carousel)),
              Tab(
                text: 'إضافة عرض جديد',
                icon: Icon(Icons.add_photo_alternate),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BannersListView(), // ويدجت عرض القائمة والحذف
            AddBannerForm(), // ويدجت النموذج (Form)
          ],
        ),
      ),
    );
  }
}
