import 'package:dart_store/data_definition/constraint/foreign_key/one_to_many/member/referenced.dart';
import 'package:dart_store/data_definition/constraint/foreign_key/one_to_many/member/referencing.dart';

class OneToManyDescription {
  OneToManyDescription({
    required this.referencingMember,
    required this.referencedMember,
  });

  final OneToManyReferencingMemberDefinition referencingMember;
  final OneToManyReferencedMemberDefinition referencedMember;
}
