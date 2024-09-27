import 'package:riverpod/riverpod.dart';

var index = 1;

final indexProvider = Provider((ref) {
  return index;
});