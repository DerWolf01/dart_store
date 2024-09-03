import 'package:dart_store/data_definition/constraint/foreign_key/one_to_one/member.dart';

class OneToOneDescription {
  OneToOneDescription({
    required this.members,
  }) {
    if (members.length != 2) {
      throw Exception(
          "Field members of OneToOneDescription must have exactly 2 entries");
    }
  }

  final List<OneToOneMemberDefinition> members;
  List<OneToOneMemberDefinition> membersOrderedByTableName() => members.toList()
    ..sort((a, b) =>
        a.tableDescription.tableName.compareTo(b.tableDescription.tableName));
}
