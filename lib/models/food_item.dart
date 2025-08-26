import 'package:hive/hive.dart';

part 'food_item.g.dart';  // ← Esta línea ES CRÍTICA

@HiveType(typeId: 0)      // ← HiveType con typeId ÚNICO
class FoodItem {
  @HiveField(0)           // ← HiveField con números únicos
  final String name;
  
  @HiveField(1)
  final double calories;
  
  @HiveField(2)
  final double protein;
  
  @HiveField(3)
  final double carbs;
  
  @HiveField(4)
  final double fat;

  @HiveField(5)
  final DateTime date;

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.date,
  });
}