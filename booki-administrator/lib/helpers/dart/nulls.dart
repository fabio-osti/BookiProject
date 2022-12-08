T throwIfNull<T>(T? value, String message) {
  if (value == null) throw ArgumentError(message);
  return value;
}

T? tryCast<T>(dynamic object) => object is T ? object : null;