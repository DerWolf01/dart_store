class WhereCollection {
  chain() {
    return "WHERE ${wheres.map((where) => where.lowerCase ? "${where.field} ILIKE ${where.getCompareTo}" : "${where.field} ${where.comporator.operator()} ${where.getCompareTo}").join(" AND ")}";
  }

  List<Where> wheres;

  WhereCollection({required this.wheres});
}

class Where {
  Where(
      {required this.field,
      required this.comporator,
      required this.compareTo,
      this.lowerCase = false});

  final String field;
  final WhereOperator comporator;
  final dynamic compareTo;
  final bool lowerCase;

  String get getCompareTo =>
      compareTo is String ? "'$compareTo'" : compareTo.toString();
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
