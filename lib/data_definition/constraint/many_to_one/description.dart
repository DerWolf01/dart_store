import 'package:dart_store/data_definition/constraint/many_to_one/member/referencing.dart';
import 'package:dart_store/data_definition/constraint/many_to_one/member/referenced.dart';

class ManyToOneDescription {
  ManyToOneDescription({
    required this.referencingMember,
    required this.referencedMember,
  });

  final ManyToOneReferencingMemberDefinition referencingMember;
  final ManyToOneReferencedMemberDefinition referencedMember;
}
