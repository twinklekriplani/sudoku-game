class SudokuCell {
  final int row;
  final int col;
  final int correctValue;
  final bool isPrefilled;
  int currentValue;
  bool isError;

  SudokuCell({
    required this.row,
    required this.col,
    required this.correctValue,
    required this.isPrefilled,
    required this.currentValue,
    this.isError = false,
  });
}
