sealed class AppFailure {
  const AppFailure();
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure();
}

final class LocalDataFailure extends AppFailure {
  const LocalDataFailure();
}
