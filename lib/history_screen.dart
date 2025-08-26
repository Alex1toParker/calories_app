// lib/history_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/food_item.dart';

class HistoryScreen extends StatelessWidget {
  // Added key parameter to constructor as per best practices
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial de Alimentos')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<FoodItem>('foodHistory').listenable(),
        builder: (context, Box<FoodItem> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No hay historial aún'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final item = box.getAt(index);
              return ListTile(
                title: Text(item!.name),
                subtitle: Text(
                  'Cal: ${item.calories.toStringAsFixed(1)} | '
                  'P: ${item.protein.toStringAsFixed(1)}g | '
                  'C: ${item.carbs.toStringAsFixed(1)}g | '
                  'G: ${item.fat.toStringAsFixed(1)}g'
                ),
                trailing: Text(
                  '${item.date.hour}:${item.date.minute.toString().padLeft(2, '0')}'
                ),
              );
            },
          );
        },
      ),
    );
  }
}
