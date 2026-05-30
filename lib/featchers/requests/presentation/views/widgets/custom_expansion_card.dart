import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supper_admin/core/enum/request_enum.dart';
import 'package:supper_admin/featchers/requests/domain/entities/pharmacy_request_entity.dart';
import 'package:supper_admin/featchers/requests/presentation/manger/cubit/request_pharmacy_cubit.dart';

class CustomerExpansionCard extends StatelessWidget {
  final PharmacyRequestEntity request;
  const CustomerExpansionCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: _getStatusColor(request.status).withOpacity(0.1),
          child: Icon(Icons.local_pharmacy, color: _getStatusColor(request.status)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                request.pharmacyName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            // 🗑️ زر الحذف البرمجي (يظهر في الحالات المبتوت فيها لتنظيف الواجهة)
            if (request.status == RequestStatus.approved || request.status == RequestStatus.rejected)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                tooltip: 'حذف الطلب نهائياً',
                onPressed: () => _showDeleteConfirmationDialog(context),
              ),
          ],
        ),
        subtitle: _buildStatusBadge(request.status),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('بيانات الصيدلي'),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.person, 'اسم الصيدلي', request.pharmacistName),
                _buildInfoRow(Icons.phone, 'رقم الهاتف', request.phoneNumber),
                _buildInfoRow(Icons.location_on, 'العنوان', request.address),
                _buildInfoRow(Icons.badge, 'رقم الهوية', request.nationalId),
                _buildInfoRow(Icons.description, 'رقم الرخصة', request.licenseNumber),
                
                if (request.status == RequestStatus.rejected && request.rejectionReason != null) ...[
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.report_problem_outlined, size: 18, color: Colors.red.shade800),
                            const SizedBox(width: 8),
                            Text(
                              'سبب الرفض المسجل:',
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          request.rejectionReason!,
                          style: TextStyle(color: Colors.red.shade900, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                _buildSectionTitle('وثيقة الترخيص'),
                const SizedBox(height: 10),
                _buildLicenseImage(context),
                
                const SizedBox(height: 25),
                _buildSectionTitle('تغيير حالة الطلب'),
                const SizedBox(height: 12),
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- واجهة الحذف التأكيدي الحامية للداتا ---
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('تأكيد حذف الطلب'),
          ],
        ),
        content: Text('هل أنت متأكد من مسح طلب صيدلية "${request.pharmacyName}" تماماً؟ لن يظهر هذا الطلب في لوحة التحكم مرة أخرى.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<RequestsCubit>().deleteRequestPermanently(request.uId);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم مسح طلب ${request.pharmacyName} بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد المسح'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w900, fontSize: 14),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.teal.shade700),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(RequestStatus status) {
    Color color = _getStatusColor(status);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLicenseImage(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            request.licenseUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _StatusActionButton(
              label: 'قبول',
              icon: Icons.check_circle,
              color: Colors.green,
              isSelected: request.status == RequestStatus.approved,
              onPressed: () => _confirmAction(context, RequestStatus.approved),
            ),
            const SizedBox(width: 8),
            _StatusActionButton(
              label: 'رفض',
              icon: Icons.cancel,
              color: Colors.red,
              isSelected: request.status == RequestStatus.rejected,
              onPressed: () => _confirmAction(context, RequestStatus.rejected),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _StatusActionButton(
          label: 'إرجاع لقيد الانتظار',
          icon: Icons.hourglass_empty,
          color: Colors.orange,
          isFullWidth: true,
          isSelected: request.status == RequestStatus.pending,
          onPressed: () => _confirmAction(context, RequestStatus.pending),
        ),
      ],
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.approved: return Colors.green;
      case RequestStatus.rejected: return Colors.red;
      case RequestStatus.pending: return Colors.orange;
      default: return Colors.grey;
    }
  }

  void _confirmAction(BuildContext context, RequestStatus newStatus) {
    if (request.status == newStatus) return;

    final TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(newStatus == RequestStatus.rejected ? 'سبب الرفض' : 'تأكيد تغيير الحالة'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(newStatus == RequestStatus.rejected 
                  ? 'يرجى كتابة سبب رفض الطلب لتوضيحه للصيدلي:' 
                  : 'هل أنت متأكد من تحويل حالة الطلب إلى ${newStatus.name}؟'),
              if (newStatus == RequestStatus.rejected) ...[
                const SizedBox(height: 15),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'اكتب السبب هنا...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يجب ذكر سبب الرفض';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (newStatus == RequestStatus.rejected) {
                if (formKey.currentState!.validate()) {
                  context.read<RequestsCubit>().updateStatus(
                    request.uId, 
                    newStatus, 
                    reason: reasonController.text.trim(),
                  );
                  Navigator.pop(dialogContext);
                }
              } else {
                context.read<RequestsCubit>().updateStatus(request.uId, newStatus);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(newStatus),
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(child: Image.network(request.licenseUrl, fit: BoxFit.contain)),
              ),
            ),
            IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

class _StatusActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isFullWidth;
  final VoidCallback onPressed;

  const _StatusActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onPressed,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = isSelected 
      ? ElevatedButton.icon(
          onPressed: null,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: color,
            disabledForegroundColor: Colors.white,
          ),
        )
      : OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
          ),
        );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : Expanded(child: button);
  }
}