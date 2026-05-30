import 'package:flutter/material.dart';
import 'package:supper_admin/core/const/app_layout.dart';

class DashboardPageTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget content; // هذا هو الجزء المتغير (محتوى الصفحة)

  const DashboardPageTemplate({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    double hPadding = AppLayout.horizontalPadding(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPadding, 48, hPadding, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            sliver: content, // هنا نضع محتوى الصفحة (Grid أو List)
          ),
        ],
      ),
    );
  }
}
