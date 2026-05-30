enum RequestStatus {
  pending,     // الطلب اتبعت ولسه بيتراجع
  underReview, // جاري مراجعة البيانات
  approved,    // تم قبول الصيدلية
  rejected,    // تم رفض الطلب
  suspended    // الحساب متوقف بعد القبول
}