List<String> sortNames(String name1, String name2) => [name1, name2]..sort(
    (a, b) => a.compareTo(b),
  );
