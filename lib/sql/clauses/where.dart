class WhereCollection {
  chain() {
    return "WHERE ${wheres.map((where) => "${where.field} ${where.comporator.operator()} ${where.compareTo}").join(" AND ")}";
  }

  List<Where> wheres;
  WhereCollection({required this.wheres});
}

class Where {
  Where(
      {required this.field, required this.comporator, required this.compareTo});
  final String field;
  final WhereOperator comporator;
  final dynamic compareTo;
}

enum WhereOperator {
  equals,
  equalOrBiggerThan,
  equalOrSmallerThan,
  biggerThan,
  smallerThan,
  notEqual,
}

extension WhereCopmarisonExtension on WhereOperator {
  operator() {
    switch (this) {
      case WhereOperator.equals:
        return "=";
      case WhereOperator.equalOrBiggerThan:
        return ">=";
      case WhereOperator.equalOrSmallerThan:
        return "<=";
      case WhereOperator.biggerThan:
        return ">";
      case WhereOperator.smallerThan:
        return "<";
      case WhereOperator.notEqual:
        return "!=";
    }
  }
}
