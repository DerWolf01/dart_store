enum ComparisonOperator {
  equals,
  equalOrBiggerThan,
  equalOrSmallerThan,
  biggerThan,
  smallerThan,
  notEqual,
}

extension SQLComparisonOperator on ComparisonOperator {
  operator() {
    switch (this) {
      case ComparisonOperator.equals:
        return "=";
      case ComparisonOperator.equalOrBiggerThan:
        return ">=";
      case ComparisonOperator.equalOrSmallerThan:
        return "<=";
      case ComparisonOperator.biggerThan:
        return ">";
      case ComparisonOperator.smallerThan:
        return "<";
      case ComparisonOperator.notEqual:
        return "!=";
    }
  }
}
