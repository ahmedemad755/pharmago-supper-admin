import 'package:flutter/material.dart';
import 'package:supper_admin/core/routs/rout.dart';

class AdminHomeDrawer extends StatelessWidget {
  final VoidCallback onSupportPhoneTap;

  const AdminHomeDrawer({
    super.key,
    required this.onSupportPhoneTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 🎨 الهيدر الجديد المخصص للـ Brand Identity الخاصة بـ PharmaGo
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal.shade50, // خلفية فاتحة ومريحة تبرز تفاصيل اللوجو الكحلي
              border: Border(
                bottom: BorderSide(color: Colors.teal.shade100, width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🖼️ عرض لوجو الأبلكيشن داخل إطار دائري نظيف
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/pharmaGo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                // 📝 اسم التطبيق والوصف البديل للإيميل
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PharmaGo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F4C75), // اللون الكحلي المطابق للوجو الخاص بك
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Smart Pharmacy System',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // شارة توضح رتبة الحساب الحالي (مدير النظام)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'مدير النظام',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 🔘 القائمة والـ ListTiles كما هي
          ListTile(
            leading: const Icon(Icons.local_pharmacy, color: Colors.teal),
            title: const Text('طلبات الصيدليات'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.ad_units, color: Colors.teal),
            title: const Text('إدارة البانرات'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.bannersManagement);
            },
          ),
          ListTile(
            leading: const Icon(Icons.medication_liquid, color: Colors.teal),
            title: const Text('Global Product Library'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.globalProductsUpload);
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent, color: Colors.teal),
            title: const Text('رقم الدعم'),
            trailing: const Icon(Icons.edit, size: 18),
            onTap: () {
              Navigator.pop(context);
              onSupportPhoneTap();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}