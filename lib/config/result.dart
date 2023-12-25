abstract class Result<T> {
  final bool isSuccess;
  Result(this.isSuccess);
}

class Success<T> extends Result<T> {
  final T data;
  Success({required this.data}) : super(true);
}

class Failure<T> extends Result<T> {
  final int status;
  final String message;
  Failure({this.status = 500, this.message = 'Something went wrong, please try again!'}) : super(false);
}