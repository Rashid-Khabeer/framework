library metro;

import 'dart:convert';
import 'package:flutter_launcher_icons/main.dart' as launcherIcons;
import 'package:http/http.dart' as http;
import 'package:args/args.dart';
import 'package:json_to_dart/json_to_dart.dart';

import 'package:nylo_framework/metro/constants/arg_flags.dart';
import 'package:nylo_framework/metro/constants/folders.dart';

import 'package:nylo_framework/metro/models/ny_api_request.dart';
import 'package:nylo_framework/metro/networking/api_request_networking.dart';
import 'package:nylo_framework/metro/stubs/api_request_stub.dart';
import 'package:nylo_framework/metro/stubs/api_service_stub.dart';
import 'package:nylo_framework/metro/stubs/controller_stub.dart';
import 'package:nylo_framework/metro/stubs/model_stub.dart';
import 'package:nylo_framework/metro/stubs/page_stub.dart';
import 'package:nylo_framework/metro/stubs/page_w_controller_stub.dart';
import 'package:nylo_framework/metro/stubs/widget_stub.dart';

import 'helpers/tools.dart';
import 'models/ny_command.dart';
import 'dart:io';

List<NyCommand> _allMakeCommands = [
  NyCommand(name: "controller", options: 1, arguments: ["-h", "-f"], action: _makeController),
  NyCommand(name: "model", options: 1, arguments: ["-h"], action: _makeModel),
  NyCommand(name: "page", options: 1, arguments: ["-h"], action: _makePage),
  NyCommand(name: "widget", options: 1, arguments: ["-h"], action: _makeWidget),
];

List<NyCommand> _allApiSpecCommands = [
  NyCommand(name: "build", options: 1, arguments: ["-h"], action: _apiSpecBuild),
];

List<NyCommand> _allAppIconsCommands = [
  NyCommand(name: "build", options: 1, arguments: ["-h"], action: _makeAppIcons),
];

Future<void> commands(List<String> arguments) async {

  if (arguments.length == 0) {
    _handleMenu();
    return;
  }

  List<String> argumentSplit = arguments[0].split(":");

  if (argumentSplit.length == 0) {
    writeInBlack('Invalid arguments ' + arguments.toString());
    return;
  }

  String type = argumentSplit[0];
  String action = argumentSplit[1];

  NyCommand nyCommand;
  switch (type) {
    case "make": {
      nyCommand = _allMakeCommands.firstWhere((command) => command.name == action, orElse: () => null);
      break;
    }
    case "apispec": {
      nyCommand = _allApiSpecCommands.firstWhere((command) => command.name == action, orElse: () => null);
      break;
    }
    case "appicons": {
      nyCommand = _allAppIconsCommands.firstWhere((command) => command.name == action, orElse: () => null);
      break;
    }
    default: {

    }
  }

  if (nyCommand == null) {
    writeInBlack('Invalid arguments ' + arguments.toString());
    return;
  }

  arguments.removeAt(0);
  nyCommand.action(arguments);
}

_handleMenu() {
  writeInBlack('Metro - Nylo\'s Companion to Build Flutter apps by Anthony Gordon');
  writeInBlack('Version: 1.0.0');

  writeInBlack('');

  writeInBlack('Usage: ');
  writeInBlack('    command [options] [arguments]');

  writeInBlack('');
  writeInBlack('Options');
  writeInBlack('    -h');

  writeInBlack('');

  writeInBlack('All commands:');

  writeInGreen(' make');
  _allMakeCommands.forEach((command) {
    writeInBlack('  make:' + command.name);
  });

  writeInBlack('');

  writeInGreen(' appicons');
  _allApiSpecCommands.forEach((command) {
    writeInBlack('  appicons:' + command.name);
  });

  writeInBlack('');

  writeInGreen(' apispec');
  _allApiSpecCommands.forEach((command) {
    writeInBlack('  apispec:' + command.name);
  });

}

_makeWidget(List<String> arguments) async {
  final ArgParser parser = ArgParser(allowTrailingOptions: true);

  parser.addFlag(helpFlag, abbr: 'h', help: 'e.g. make:controller DashboardController', negatable: false);

  final ArgResults argResults = parser.parse(arguments);

  if (argResults[helpFlag]) {
    writeInBlack('Help - Creates a new controller in Nylo');
    writeInBlack(parser.usage);
    exit(0);
  }

  List<String> split = argResults.arguments.first.split("_");
  List<String> map = split.map((e) => capitalize(e)).toList();
  String newStr = map.join("");

  String path = '$widgetFolder/${argResults.arguments.first}.dart';

  if (await File(path).exists()) {
    writeInRed(argResults.arguments.first + ' already exists');
    return;
  }

  final File file = File(path);

  await file.writeAsString(widgetStub(newStr));

  writeInGreen(argResults.arguments.first + ' created 🎉');

  exit(0);
}

_makeAppIcons(List<String> arguments) async {
  final ArgParser parser = ArgParser(allowTrailingOptions: true);

  parser.addFlag(helpFlag, abbr: 'h', help: 'e.g. make:app_icons', negatable: false);

  final ArgResults argResults = parser.parse(arguments);

  if (argResults[helpFlag]) {
    writeInBlack('Help - Creates App Icons in Nylo');
    writeInBlack(parser.usage);
    exit(0);
  }

  launcherIcons.createIconsFromArguments(arguments);

  writeInGreen('App icons created 🎉');
  exit(0);
}


_makeController(List<String> arguments) async {
  final ArgParser parser = ArgParser(allowTrailingOptions: true);

  parser.addFlag(helpFlag, abbr: 'h', help: 'Used to make new controllers e.g. home_controller', negatable: false);
  parser.addFlag(forceFlag, abbr: 'f', help: 'Creates a new controller even if it already exists.', negatable: false);

  final ArgResults argResults = parser.parse(arguments);

  if (argResults.arguments.length == 0) {
    writeInBlack(parser.usage);
    exit(0);
  }

  bool hasForceFlag = argResults[forceFlag];
  bool hasHelpFlag = argResults[helpFlag];

  if (hasHelpFlag) {
    writeInBlack(parser.usage);
    exit(0);
  }

  String firstArg = argResults.arguments.first;
  String path = '$controllerFolder/$firstArg.dart';

  if (await File(path).exists() && hasForceFlag == false) {
    writeInRed(firstArg + ' already exists');
    exit(0);
  }

  String controllerName = _parseToPascal(firstArg);
  String strController = controllerStub(controllerName: controllerName);

  await _writeToFilePath(path, strController);

  writeInGreen(firstArg + ' created 🎉');

  exit(0);
}

String _parseToPascal(name) {
  List<String> split = name.split("_");
  List<String> map = split.map((e) => capitalize(e)).toList();
  return map.join("");
}

_writeToFilePath(path, strFile) async {
  final File file = File(path);

  await file.writeAsString(strFile);
}

_makeModel(List<String> arguments) async {
  final ArgParser parser = ArgParser(allowTrailingOptions: true);

  parser.addFlag(helpFlag, abbr: 'h', help: 'Used to make new controllers e.g. home_controller', negatable: false);
  parser.addFlag(forceFlag, abbr: 'f', help: 'Creates a new controller even if it already exists.', negatable: false);

  final ArgResults argResults = parser.parse(arguments);

  if (argResults.arguments.length == 0) {
    writeInBlack(parser.usage);
    exit(0);
  }

  bool hasForceFlag = argResults[forceFlag];
  bool hasHelpFlag = argResults[helpFlag];

  if (hasHelpFlag) {
    writeInBlack(parser.usage);
    exit(0);
  }

  String firstArg = argResults.arguments.first;
  String path = '$modelFolder/$firstArg.dart';

  if (await File(path).exists() && hasForceFlag == false) {
    writeInRed(firstArg + ' already exists');
    exit(0);
  }

  final File file = File(path);

  String modelName = _parseToPascal(firstArg);
  String strModel = modelStub(modelName: modelName);

  await file.writeAsString(strModel);

  writeInGreen(modelName + ' created 🎉');

  exit(0);
}

_makePage(List<String> arguments) async {
  final ArgParser parser = ArgParser(allowTrailingOptions: true);

  parser.addFlag(helpFlag, abbr: 'h', help: 'e.g. make:page Menu', negatable: false);

  bool shouldCreateController = false;
  parser.addFlag("controller", abbr: 'c', help: 'Creates a new page with a controller', negatable: false);

  final ArgResults argResults = parser.parse(arguments);

  if (argResults[helpFlag]) {
    writeInBlack('Help - Creates a new page in Nylo');
    writeInBlack(parser.usage);
    exit(0);
  }

  if (argResults["controller"]) {
    shouldCreateController = true;
  }

  if (argResults.arguments.first == " ") {
    exit(0);
  }

  String optionName;

  optionName = capitalize(argResults.arguments.first.replaceAll("_page", ""));

  List<String> split = optionName.split("_");
  List<String> map = split.map((e) => capitalize(e)).toList();
  String className = map.join("");

  String pathPage = '$pageFolder/${optionName.toLowerCase()}_page.dart';
  String pathController = '$controllerFolder/${optionName.toLowerCase()}_controller.dart';
  if (shouldCreateController) {
    if (await File(pathPage).exists()) {
      writeInRed(optionName + 'Page already exists');
      return;
    }

    if (await File(pathController).exists()) {
      writeInRed(optionName + 'Controller already exists');
      return;
    }

    final File filePage = File(pathPage);
    await filePage.writeAsString(pageWithControllerStub(className: className, importName: argResults.arguments.first.replaceAll("_page", "")));

    final File fileInterface = File(pathController);

    String strInterface = controllerStub(controllerName: className);

    await fileInterface.writeAsString(strInterface);

    writeInGreen('${className}Page & ${className}Controller created 🎉');
    exit(0);
  }

  if (await File(pathPage).exists()) {
    writeInRed(argResults.arguments.first + ' already exists');
    return;
  }

  final File file = File(pathPage);

  await file.writeAsString(pageStub(pageName: className));

  writeInGreen('${optionName}Page created 🎉');

  exit(0);
}

_apiSpecBuild(List<String> arguments) async {
  writeInBlack("Building API Spec\n");

  File file;
  Iterable json;

  try {

    file = File("apispec.json");
    json = jsonDecode(await file.readAsString());

  } on Exception catch (e) {
    writeInRed("Error");
    writeInBlack("Please check your apispec.yaml");
    writeInBlack(e.toString());
    return;
  }

  List<NyApiRequest> nyApiRequests = List.of(json).map((e) => NyApiRequest.fromJson(e)).toList();

  String apiRequests = "";
  String importApiRequests = "";

  final ArgParser parser = ArgParser(allowTrailingOptions: true);

  parser.addFlag(helpFlag, abbr: 'h', help: 'Used to auto build models from your apispec.yaml', negatable: false);
  parser.addFlag(forceFlag, abbr: 'f', help: 'Forcefully creates models even if they exist.', negatable: false);

  final ArgResults argResults = parser.parse(arguments);

  bool hasForceFlag = argResults[forceFlag];
  bool hasHelpFlag = argResults[helpFlag];

  if (hasHelpFlag) {
    writeInBlack(parser.usage);
    exit(0);
  }

  for (int i = 0; i < nyApiRequests.length; i++) {

    String modelPath = '$modelFolder/${nyApiRequests[i].modelName.toLowerCase()}.dart';

    if (await File(modelPath).exists() && hasForceFlag == false) {
      writeInBlue(nyApiRequests[i].modelName + ' already exists, skipping...');
      continue;
    }

    http.Response json = await metroApiRequest(nyApiRequests[i]);

    final classGenerator = new ModelGenerator(nyApiRequests[i].modelName);

    DartCode dartCode = classGenerator.generateDartClasses(json.body);

    final File file = File(modelPath);
    await file.writeAsString(dartCode.code);
    writeInBlue(nyApiRequests[i].modelName + " model created");

    apiRequests = apiRequestStub(nyApiRequests[i]) + "\n" + apiRequests;

    importApiRequests = "import \"../models/${nyApiRequests[i].modelName.toLowerCase()}.dart\";\n" + importApiRequests;
  }

  String networkingServicePath = '$networkServicesFolder/base_api_service.dart';
  final File networkingServiceFile = File(networkingServicePath);
  await networkingServiceFile.writeAsString(apiServiceStub(imports: importApiRequests, apiRequests: apiRequests));

  writeInGreen("Api Spec Built 🚨");
  exit(0);
}

writeInGreen(String message) {
  stdout.writeln('\x1B[92m' + message + '\x1B[0m');
}

writeInRed(String message) {
  stdout.writeln('\x1B[91m' + message + '\x1B[0m');
}

writeInBlue(String message) {
  stdout.writeln('\x1B[94m' + message + '\x1B[0m');
}

writeInBlack(String message) {
  stdout.writeln(message);
}