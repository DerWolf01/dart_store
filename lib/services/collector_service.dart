import 'dart:mirrors';

class CollectorService {
  List<ClassMirror> searchClassesWithAnnotation<T>() {
    var classes = <Type>[];

    currentMirrorSystem().libraries.values.forEach((libraryMirror) {
      libraryMirror.declarations.values.forEach((declarationMirror) {
        if (declarationMirror is ClassMirror) {
          var classMirror = declarationMirror as ClassMirror;
          if (classMirror.metadata.any((meta) => meta.reflectee is T)) {
            classes.add(classMirror.reflectedType);
          }
        }
      });
    });

    return classes.map((e) => reflectClass(e)).toList();
  }
}
