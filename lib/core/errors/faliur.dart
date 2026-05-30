abstract class Faliur {
  final String message;

  Faliur(this.message);
}

class ServerFaliur extends Faliur {
  ServerFaliur(super.message);
}

class NetworkFailure extends Faliur {
  NetworkFailure() : super('حدث خطأ في الاتصال بالإنترنت');
}
