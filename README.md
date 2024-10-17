# DartStore

* **Bring your backend development to the next level with DartStore!**  
* Dart-based open source persistence API that dynamically handles "Entity" models and corresponding **CRUD** and even more! 
* It provides a structured way to manage database models, making it easier to develop scalable and maintainable real-time backend applications.
* It works exceptionally good in connection with **Flutter** Apps as it allows you to have the same code base in terms of models.

> :warning: **Still in development**: The library is still under development und not meant to be used in production environments by third parties yet.

## Features

- **Model-Based Architecture**: Organize your code into models for both server & client to handle specific data structures and actions, improving modularity and readability.
- **Serializable Models**: Define models that can be automatically serialized and deserialized from JSON, streamlining client-server data exchange using the `ConversionService`.
- **Reflectable**: Utilizes Dart's reflectable package for runtime reflection, enabling dynamic invocation of methods based on request paths.

## Getting Started

To get started with DartStore, follow these steps:

1. **Add Dependencies**: Ensure you have `dart_store`, added to your `pubspec.yaml` file.
    1. Make sure to define 'analyzer: ^6.4.0' ( bigger version have conflcits with reflectable & build_runner )

           ```yaml
           dependencies:
             portal: ^latest_version
           ```
       2. **Define Models**: Create portals annotated with `@Entity` to handle specific paths and actions. Use `@SQLDataType`'s and `@ForeignKey`'s to define methods for handling requests and responses. See all possible annotations in the [API Reference](https://pub.dev/documentation/portal/latest/portal/portal-library.html).


**Exmaple:**
    This is an example of how to define a simple model with a one-to-many and many-to-one relationship between students and there class room.
    The DartStore will automatically create the necessary tables and relationships in the database.

```dart
@Entity(name: 'ClassRoom')
class ClassRoom {

  @PrimaryKey(autoIncrement: true)
  int? id;

  @Varchar()
  String className;

  @OneToMany()
  List<Student> students;
}

@Entity()
class Student {

  @PrimaryKey(autoIncrement: true)
  int? id;
  
  @Varchar()
  String name;
  
  @ManyToOne()
  ClassRoom classRoom;
}
//... 
   ```

2. **Initiliaze DartStore**: Before running your application, define a **DatabaseConnection** or use an existing implementation like the `PostgresConnection`. See the [API Reference](https://pub.dev/documentation/portal/latest/portal/portal-library.html) for more information about the `DatabaseConenction` implementation.
    **Example:**
    ```dart
    void main() {
        await DartStore.init(
          await PostgresConnection.init(
                    endpoint: Endpoint(
                    host: 'localhost',
                    database: 'ebay_watcher',
                    username: 'ebay_watcher',
                    password: 'ebay_watcher'),
                    settings: ConnectionSettings(
                    onOpen: (connection) async =>
                    print('Connected to the database $connection'),
                    sslMode: SslMode.disable)),
          enableLogging: true
        );
      // Implement and initialize the rest of your application here
    }
    ```


4. **CRUD operations**: **Save**, **update**, **delete**, **query**, check data **existence** or even more using the DartStore singleton.

    Exmaple:

    ```dart
    ...
    // Save a new student
    await dartStore.save(Student(name: 'John Doe', classRoom: ClassRoom(className: 'Math')));
    // Update a student
    await dartStore.update(Student(name: 'John Doe', classRoom: ClassRoom(className: 'Math')));
    // Delete a student
    await dartStore.delete(Student(name: 'John Doe', classRoom: ClassRoom(className: 'Math')));
    // Query all students
    final students = await dartStore.query<Student>();
   ```
