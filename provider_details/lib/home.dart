import 'package:flutter/material.dart';

import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

@immutable
class BaseObject {
  final String id;
  final String lastUpdated;

  BaseObject()
      : id = const Uuid().v4(),
        lastUpdated = DateTime.now().toIso8601String();

  @override
  bool operator ==(covariant BaseObject other) => id == other.id;

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}

@immutable
class ExpensiveObject extends BaseObject {}

@immutable
class CheapObject extends BaseObject {}

class ObjectProvider extends ChangeNotifier {
  late String id;
  late CheapObject _cheapObject;
  late StreamSubscription _cheapObjectStreamSubs;
  late ExpensiveObject _expensiveObject;
  late StreamSubscription _expensiveObjectStreamSubs;

  CheapObject get cheapObject => _cheapObject;
  ExpensiveObject get expensiveObject => _expensiveObject;
  ObjectProvider()
      : id = const Uuid().v4(),
        _cheapObject = CheapObject(),
        _expensiveObject = ExpensiveObject() {
    start();
  }

  @override
  void notifyListeners() {
    id = const Uuid().v4();
    super.notifyListeners();
  }

  void start() {
    _cheapObjectStreamSubs = Stream.periodic(
      const Duration(seconds: 1),
    ).listen((_) {
      _cheapObject = CheapObject();
      notifyListeners();
    });

    _expensiveObjectStreamSubs = Stream.periodic(
      const Duration(seconds: 10),
    ).listen((_) {
      _expensiveObject = ExpensiveObject();
      notifyListeners();
    });
  }

  void stop() {
    _cheapObjectStreamSubs.cancel();
    _expensiveObjectStreamSubs.cancel();
  }
}

class home extends StatelessWidget {
  const home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home'),
      ),
      body: Column(
        children: [
          Row(
            children: const [
              Expanded(child: CheapWidget()),
              Expanded(child: ExpensiveWidget()),
            ],
          ),
          Row(
            children: const [Expanded(child: ObjectProviderWidget())],
          ),
          Row(
            children: [
              TextButton(onPressed: (){
                context.read<ObjectProvider>().stop();
              }, child: const Text('stop'),),
              TextButton(onPressed: (){
                context.read<ObjectProvider>().start();
              }, child: const Text('start'),),
            ],
          ),
        ],
      ),
    );
  }
}

class CheapWidget extends StatelessWidget {
  const CheapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cheapObject = context.select<ObjectProvider, CheapObject>(
      (provider) => provider.cheapObject,
    );
    return Container(
      height: 100,
      color: Colors.deepOrange,
      child: Column(
        children: [
          const Text('cheap widget'),
          const Text('last updated'),
          Text(cheapObject.lastUpdated),
        ],
      ),
    );
  }
}

class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final expensiveObject = context.select<ObjectProvider, ExpensiveObject>(
      (provider) => provider.expensiveObject,
    );
    return Container(
      height: 100,
      color: Colors.amber,
      child: Column(
        children: [
          const Text('expensive widget'),
          const Text('last updated'),
          Text(expensiveObject.lastUpdated),
        ],
      ),
    );
  }
}

class ObjectProviderWidget extends StatelessWidget {
  const ObjectProviderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObjectProvider>();
    return Container(
      height: 100,
      color: Colors.blueAccent,
      child: Column(
        children: [
          const Text('object provider widget'),
          const Text('id'),
          Text(provider.id),
        ],
      ),
    );
  }
}
