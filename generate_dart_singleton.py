import sys

if len(sys.argv) > 1:
    camelCase = sys.argv[1]
    lowerCase = camelCase.lower()

    snakeCase: str = ""

    for i in range(len(camelCase)):
        if camelCase[i].isupper():
            snakeCase += "_"
        snakeCase += camelCase[i].lower()

    fileContent = (
        f"{camelCase} get {lowerCase} => {camelCase}();\nclass {camelCase} "
        + "{"
        + "\n static {camelCase}? _instance;\n{camelCase}._internal();\nfactory {camelCase}() => (_instance ??= {camelCase}._internal());\n}"
    )
    open
    file = open(f"{snakeCase}.dart", "w").write(fileContent) 
    print(f"Singleton file {snakeCase}.dart created.")

else:
    print("No arguments provided.")
