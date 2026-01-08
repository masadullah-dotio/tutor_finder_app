import 'package:dartz/dartz.dart';
import 'package:tutor_finder_app/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
