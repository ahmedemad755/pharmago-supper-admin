// lib/featchers/requests/presentation/manger/requests_cubit/requests_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:supper_admin/core/enum/request_enum.dart';
import 'package:supper_admin/featchers/requests/domain/repos/requests_repo.dart';
import 'package:supper_admin/featchers/requests/presentation/manger/cubit/request_pharmacy_state.dart';


class RequestsCubit extends Cubit<RequestsState> {
  final PharmaciesRepo _repo;
  RequestsCubit(this._repo) : super(RequestsInitial());

  void fetchAllRequests() {
    emit(RequestsLoading());
    _repo.fetchRequests().listen((result) {
      result.fold(
        (failure) => emit(RequestsError(failure.message)),
        (requests) => emit(RequestsSuccess(requests)),
      );
    });
  }

  Future<void> updateStatus(String uId, RequestStatus status, {String? reason}) async {
    final result = await _repo.changeRequestStatus(status: status, uId: uId, rejectionReason: reason);
    result.leftMap((failure) => emit(RequestsError(failure.message)));
  }
}