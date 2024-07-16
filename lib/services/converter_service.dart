import 'dart:mirrors';

import 'package:dart_persistence_api/sql_anotations/data_types/data_type.dart';

class ConverterService {
  static Map<String, dynamic> objectToMap(Object object) {
    var mirror = reflect(object);
    var classMirror = mirror.type;

    var map = <String, dynamic>{};

    classMirror.declarations.forEach((symbol, declaration) {
      if (declaration is VariableMirror && !declaration.isStatic) {
        var fieldName = MirrorSystem.getName(symbol);
        var fieldValue = mirror.getField(symbol).reflectee;

        var fieldAnnotation = declaration.metadata.firstWhere(
          (annotation) => annotation.reflectee is SQLDataType,
        );

        var convertToSql = fieldAnnotation.reflectee as SQLDataType;
        fieldValue = convertToSql.convert(fieldValue);

        map[fieldName] = fieldValue;
      }
    });

    return map;
  }

  static T mapToObject<T>(Map<String, dynamic> map) {
    var classMirror = reflectClass(T);
    var instance = classMirror.newInstance(const Symbol(''), []);

    map.forEach((key, value) {
      var fieldName = MirrorSystem.getSymbol(key);
      var fieldValue = value;
      instance.setField(fieldName, fieldValue);
    });

    return instance.reflectee;
  }
}
