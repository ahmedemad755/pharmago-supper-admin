import 'package:supper_admin/featchers/requests/domain/entities/pharmacy_request_entity.dart';

abstract class RequestsState {}
class RequestsInitial extends RequestsState {}
class RequestsLoading extends RequestsState {}
class RequestsSuccess extends RequestsState {
  final List<PharmacyRequestEntity> requests;
  RequestsSuccess(this.requests);
}
class RequestsError extends RequestsState {
  final String message;
  RequestsError(this.message);
}