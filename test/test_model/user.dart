import 'package:dart_store/dart_store.dart';

@Entity(name: "user_table")
class User {
  @PrimaryKey(autoIncrement: true)
  @Serial()
  late int id;

  @Varchar()
  late String name;

  @Integer()
  late int age;
  User();

  User.init({required this.id, required this.name, required this.age});
}
