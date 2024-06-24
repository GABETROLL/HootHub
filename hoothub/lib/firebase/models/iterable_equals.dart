bool iterableEquals<T>(Iterable<T> a, Iterable<T> b, bool Function(T, T) equals) {
  if (a.length != b.length) return false;

  final Iterator<T> aIterator = a.iterator;
  final Iterator<T> bIterator = b.iterator;

  while (aIterator.moveNext() && bIterator.moveNext()) {
    if (!equals(aIterator.current, bIterator.current)) {
      return false;
    }
  }

  return true;
}
