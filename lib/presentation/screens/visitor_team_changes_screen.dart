import 'package:flutter/material.dart';

class VisitorTeamChangesScreen extends StatefulWidget {
  const VisitorTeamChangesScreen({Key? key}) : super(key: key);

  @override
  _VisitorTeamChangesScreenState createState() =>
      _VisitorTeamChangesScreenState();
}

class _VisitorTeamChangesScreenState extends State<VisitorTeamChangesScreen> {
  late List<String> numbers;
  late List<String?> categories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extraemos de forma segura los argumentos
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    debugPrint("VisitorTeamChangesScreen args: $args");
    if (args != null && args['numbers'] != null && args['categories'] != null) {
      numbers = List<String>.from(args['numbers']);
      categories = List<String?>.from(args['categories']);
    } else {
      numbers = [];
      categories = [];
    }
  }

  // Función para determinar el color del avatar según la categoría.
  Color getCircleColor(String? category) {
    if (category == null) return Colors.grey;
    if (category == "men") return const Color.fromARGB(255, 180, 163, 7);
    if (category == "Med") return Colors.blue;
    if (category == "May") return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Visitante',
          style: TextStyle(
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: numbers.isEmpty
          ? const Center(
              child: Text(
                'No hay datos disponibles',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: numbers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getCircleColor(categories[index]),
                      child: Text(
                        numbers[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      'Jugador ${numbers[index]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      categories[index] ?? 'Sin categoría',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
    );
  }
}