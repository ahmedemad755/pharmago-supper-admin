import 'package:flutter/material.dart';

class OrderItemWidget extends StatelessWidget {
  const OrderItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // أيقونة الحالة أو رقم الطلب
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.teal.shade100),
            ),
            child: const Icon(Icons.shopping_bag_outlined, size: 20, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          
          // تفاصيل الطلب
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'طلب رقم #98234',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '20 مارس 2024 - 10:30 ص',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          
          // الحالة والسعر
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '150.00 ج.م',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 6),
              _buildStatusBadge('قيد التنفيذ'),
            ],
          ),
        ],
      ),
    );
  }

  // ودجت صغير لحالة الطلب (Badge)
  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        status,
        style: TextStyle(color: Colors.orange.shade800, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}