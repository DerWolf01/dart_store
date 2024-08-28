import 'package:dart_store/data_definition/constraint/many_to_many/member.dart';

class ManyToManyDescription {
  ManyToManyDescription({
    required this.members,
  }) {
    if (members.length != 2) {
      throw Exception(
          "Field members of ManyToManyDescription must have exactly 2 entries");
    }
  }

  final List<ManyToManyMemberDefinition> members;
  List<ManyToManyMemberDefinition> membersOrderedByTableName() => members
      .toList()
    ..sort((a, b) =>
        a.tableDescription.tableName.compareTo(b.tableDescription.tableName));
}
