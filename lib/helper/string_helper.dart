extension SplitString on String {
  List<String> splitAt(int index) {
    assert(isNotEmpty);
    assert(length >= index);
    assert(index >= 0);
    return [substring(0, index), substring(index)];
  }
}
