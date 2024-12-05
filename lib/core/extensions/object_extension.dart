extension ObjectExtension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
