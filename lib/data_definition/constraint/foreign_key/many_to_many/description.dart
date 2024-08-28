import 'package:dart_store/data_definition/constraint/foreign_key/many_to_many/member.dart';

/// A class that describes a many-to-many relationship.
///
/// This class ensures that the relationship is defined between exactly two members.
class ManyToManyDescription {
  /// Creates a new instance of [ManyToManyDescription].
  ///
  /// The [members] parameter is required and must contain exactly two entries.
  /// Throws an [Exception] if the number of members is not equal to two.
  ManyToManyDescription({
    required this.members,
  }) {
    if (members.length != 2) {
      throw Exception(
          "Field members of ManyToManyDescription must have exactly 2 entries");
    }
  }

  /// The list of members involved in the many-to-many relationship.
  final List<ManyToManyMemberDefinition> members;

  /// Returns the members ordered by their table names.
  ///
  /// This method sorts the members by the table names in ascending order.
  ///
  /// Returns a [List] of [ManyToManyMemberDefinition] sorted by table names.
  List<ManyToManyMemberDefinition> membersOrderedByTableName() => members
      .toList()
    ..sort((a, b) =>
        a.tableDescription.tableName.compareTo(b.tableDescription.tableName));
}