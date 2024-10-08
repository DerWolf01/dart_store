import 'dart:mirrors';

class CollectorService {
  List<ClassMirror> searchClassesWithAnnotation<T>() {
    var classes = <Type>[];

    for (var libraryMirror in currentMirrorSystem().libraries.values) {
      for (var declarationMirror in libraryMirror.declarations.values) {
        if (declarationMirror is ClassMirror) {
          var classMirror = declarationMirror;
          if (classMirror.metadata.any((meta) => meta.reflectee is T)) {
            classes.add(classMirror.reflectedType);
          }
        }
      }
    }
    

    return classes.map((e) => reflectClass(e)).toList();
  }
}
