/// Annotation to define a table entity
/// The name of the entity is the name of the table if not specified in the constructor.
class Entity {
  /// The name of the table
  /// If not specified, the name of the table is the name of the class in snake_case format in order to be sql conform.
  final String? name;
  const Entity({this.name});

  @override
  String toString() => "Entity(name: $name)";
}
