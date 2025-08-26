import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/food_item.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_cubit.dart';
import 'blocs/auth/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(FoodItemAdapter());
  await Hive.openBox<FoodItem>('foodHistory');
  await Hive.openBox('userProfile');
  runApp(BetterMeApp());
}

class BetterMeApp extends StatelessWidget {
  const BetterMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit()..checkAuthStatus(),
        ),
      ],
      child: MaterialApp(
        title: 'BetterMe',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return const MainScreen();
            } else if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¡Bienvenido!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AuthCubit>().login('test@example.com', 'password123');
              },
              child: const Text('Login (Simulado)'),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const HomeScreen(),
    HistoryScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BetterMe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _foodController = TextEditingController();
  String _result = '';
  final String _appId = '07b4d260';
  final String _appKey = '7dafd32f8d2904182e04057c0ba29a4b';

  Future<void> _searchFood() async {
    setState(() {
      _result = 'Buscando...';
    });

    final url = Uri.parse('https://trackapi.nutritionix.com/v2/natural/nutrients');

    final headers = {
      'x-app-id': _appId,
      'x-app-key': _appKey,
      'x-remote-user-id': '0', // Puede ser cualquier ID para fines de desarrollo
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'query': _foodController.text,
      'locale': 'es_VE',
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['foods'] != null && data['foods'].isNotEmpty) {
          final food = data['foods'][0];
          final foodName = food['food_name'] ?? 'Desconocido';
          final calories = food['nf_calories'] ?? 0.0;
          final protein = food['nf_protein'] ?? 0.0;
          final carbs = food['nf_carbohydrates'] ?? 0.0;
          final fat = food['nf_total_fat'] ?? 0.0;

          final foodBox = Hive.box<FoodItem>('foodHistory');
          final newFoodItem = FoodItem(
            name: foodName,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            date: DateTime.now(),
          );
          foodBox.add(newFoodItem);

          setState(() {
            _result =
                'Alimento: $foodName\nCalorías: ${calories.toStringAsFixed(1)}\nProteína: ${protein.toStringAsFixed(1)}g\nCarbohidratos: ${carbs.toStringAsFixed(1)}g\nGrasa: ${fat.toStringAsFixed(1)}g';
          });
        } else {
          setState(() {
            _result = 'Alimento no encontrado. Por favor, sé más específico.';
          });
        }
      } else {
        setState(() {
          _result = 'Error en la solicitud: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error de conexión: $e';
      });
    }
  }

  @override
  void dispose() {
    _foodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _foodController,
            decoration: const InputDecoration(
              labelText: 'Ingresa un alimento',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _searchFood,
            child: const Text('Analizar Alimento'),
          ),
          const SizedBox(height: 20),
          Text(_result, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Alimentos')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<FoodItem>('foodHistory').listenable(),
        builder: (context, Box<FoodItem> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No hay historial aún'));
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
                  'G: ${item.fat.toStringAsFixed(1)}g',
                ),
                trailing: Text(
                  '${item.date.hour}:${item.date.minute.toString().padLeft(2, '0')}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}