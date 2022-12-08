T throwIfNull<T>(T? value, String message) {
  if (value == null) throw ArgumentError(message);
  return value;
}
