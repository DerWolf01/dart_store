import 'dart:mirrors';

class ConverterService {
  static Map<String, dynamic> objectToMap(Object object) {
    var mirror = reflect(object);
    var classMirror = mirror.type;

    var map = <String, dynamic>{};

    classMirror.declarations.forEach((symbol, declaration) {
      if (declaration is VariableMirror && !declaration.isStatic) {
        var fieldName = MirrorSystem.getName(symbol);
        var fieldValue = mirror.getField(symbol).reflectee;

        map[fieldName] = fieldValue;
      }
    });

    return map;
  }

  static T mapToObject<T>(Map<String, dynamic> map, {Type? type}) {
    var classMirror = reflectClass(type ?? T);
    var instance = classMirror.newInstance(const Symbol(''), []);

    map.forEach((key, value) {
      var fieldName = MirrorSystem.getSymbol(key);
      var fieldValue = value;
      instance.setField(fieldName, fieldValue);
    });

    return instance.reflectee;
  }
}
