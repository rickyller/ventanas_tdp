import 'package:flutter/material.dart';
import 'package:ventanas_tdp/presentation/widgets/substitute_selection_dialog.dart';

/// Clase para almacenar la información de una sustitución,
/// de modo que podamos revertirla.
class SubstitutionAction {
  final int titularIndex;
  final Map<String, dynamic> oldTitular; // el que salió
  final Map<String, dynamic> newTitular; // el que entró

  SubstitutionAction({
    required this.titularIndex,
    required this.oldTitular,
    required this.newTitular,
  });
}

class LocalTeamChangesScreen extends StatefulWidget {
  const LocalTeamChangesScreen({Key? key}) : super(key: key);

  @override
  _LocalTeamChangesScreenState createState() => _LocalTeamChangesScreenState();
}

class _LocalTeamChangesScreenState extends State<LocalTeamChangesScreen> {
  late List<Map<String, dynamic>> titulares;
  late List<Map<String, dynamic>> suplentes;
  List<String> substitutionChanges = [];

  /// Pila de acciones para poder deshacer la última sustitución.
  final List<SubstitutionAction> _substitutionStack = [];

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      final numbers = List<String>.from(args?['numbers'] ?? []);
      final categories = List<String?>.from(args?['categories'] ?? []);

      final isTitularList = (args?['isTitular'] != null &&
              (args?['isTitular'] as List).isNotEmpty)
          ? List<bool>.from(args?['isTitular'])
          : List<bool>.filled(numbers.length, true);

      titulares = [];
      suplentes = [];
      for (int i = 0; i < numbers.length; i++) {
        final jugador = {
          'number': numbers[i],
          'category': categories.length > i ? categories[i] : null,
        };
        if (i < isTitularList.length && isTitularList[i]) {
          titulares.add(jugador);
        } else {
          suplentes.add(jugador);
        }
      }
      _isInitialized = true;
    }
  }

  Color getCircleColor(String? category) {
    if (category == null) return Colors.grey;
    if (category == "men") return const Color.fromARGB(255, 180, 163, 7);
    if (category == "Med") return Colors.blue;
    if (category == "May") return Colors.red;
    return Colors.grey;
  }

  /// Deshace la última sustitución (si existe).
  void _undoLastSubstitution() {
    if (_substitutionStack.isNotEmpty) {
      final lastAction = _substitutionStack.removeLast();

      // Revertir la sustitución en titulares y suplentes
      final revertIndex = lastAction.titularIndex;
      titulares[revertIndex] = lastAction.oldTitular; // vuelve el que salió
      suplentes.add(lastAction.newTitular); // el que entró regresa a suplentes

      // Quitar la última línea del listado de cambios
      if (substitutionChanges.isNotEmpty) {
        substitutionChanges.removeLast();
      }

      // Refrescar la UI
      setState(() {});
    }
  }

  /// Diálogo de confirmación, usando un StatefulBuilder para
  /// poder refrescar el diálogo cuando se deshace la última sustitución.
  Future<bool?> _showConfirmDialog({
  required BuildContext context,
  required double dialogFontSize,
  required String title,
  bool showSubstitutions = false,
}) {
  final watchSize = MediaQuery.of(context).size;
  final double maxDialogWidth = watchSize.width * 0.9;
  final double maxDialogHeight = watchSize.height * 0.9;
  final double contentFontSize = dialogFontSize;
  // Reducimos un poco la escala para evitar overflow en pantallas pequeñas
  final double buttonFontSize = dialogFontSize * 0.8;

  return showDialog<bool>(
    context: context,
    builder: (context) {
      // Usamos StatefulBuilder para refrescar el diálogo al deshacer
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              // Limita el tamaño máximo del diálogo
              constraints: BoxConstraints(
                maxWidth: maxDialogWidth,
                maxHeight: maxDialogHeight,
              ),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: contentFontSize * 1.2,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Título "Sustituciones:" si hay cambios
                  if (showSubstitutions && substitutionChanges.isNotEmpty) ...[
                    Text(
                      "Sustituciones:",
                      style: TextStyle(
                        fontSize: contentFontSize,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Lista de sustituciones (scrollable)
                  Expanded(
                    child: showSubstitutions && substitutionChanges.isNotEmpty
                        ? SingleChildScrollView(
                            child: Column(
                              children: substitutionChanges
                                  .map(
                                    (change) => Text(
                                      change,
                                      style: TextStyle(
                                        fontSize: contentFontSize,
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                  .toList(),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 12),

                  // Fila con "No", icono "Deshacer" y "Sí"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón "No"
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            "No",
                            style: TextStyle(
                              fontSize: buttonFontSize * 1.2,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // IconButton "Deshacer"
                      IconButton(
                        icon: const Icon(Icons.undo, color: Colors.orange),
                        iconSize: buttonFontSize * 1.8,
                        tooltip: "Deshacer",
                        onPressed: () {
                          _undoLastSubstitution();
                          setDialogState(() {});
                        },
                      ),
                      // Botón "Sí"
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            "Sí",
                            style: TextStyle(
                              fontSize: buttonFontSize * 1.2,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  /// Manejo del tap en un jugador titular para hacer el cambio
  void _onTitularTap(int titularIndex) {
    if (suplentes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay suplentes disponibles')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubstituteSelectionDialog(
        availableNumbers:
            suplentes.map((jugador) => jugador['number'] as String).toList(),
        availableCategories:
            suplentes.map((jugador) => jugador['category'] as String?).toList(),
        onConfirm: (selectedIndices) {
          if (selectedIndices.isNotEmpty) {
            final int selectedIndex = selectedIndices.first;
            setState(() {
              final substitute = suplentes[selectedIndex];
              final leaving = titulares[titularIndex];

              // Guardar acción para deshacer
              _substitutionStack.add(
                SubstitutionAction(
                  titularIndex: titularIndex,
                  oldTitular: leaving,
                  newTitular: substitute,
                ),
              );

              // Aplicar el cambio
              titulares[titularIndex] = substitute;
              suplentes.removeAt(selectedIndex);

              // Agregar texto descriptivo al historial
              substitutionChanges.add(
                "Entra ${substitute['number']} sale ${leaving['number']}",
              );
            });
          }
        },
      ),
    );
  }

  Widget buildPlayerTile(
    Map<String, dynamic> jugador, {
    required bool esTitular,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: getCircleColor(jugador['category']),
            child: Text(
              jugador['number'],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            'Jugador ${jugador['number']}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            jugador['category'] ?? 'Sin categoría',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double dialogFontSize = size.shortestSide * 0.040;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            final bool? confirm = await _showConfirmDialog(
              context: context,
              dialogFontSize: dialogFontSize,
              title: "Confirmar abandono",
              showSubstitutions: false,
            );
            if (confirm == true) Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Local',
              style: TextStyle(
                fontSize: size.shortestSide * 0.07,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 9),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () async {
                final bool? confirm = await _showConfirmDialog(
                  context: context,
                  dialogFontSize: dialogFontSize,
                  title: "Confirmar cambios",
                  showSubstitutions: true,
                );
                if (confirm == true) {
                  // Retornar la lista de cambios al cerrar
                  Navigator.pop(context, substitutionChanges);
                }
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            "Titulares",
            style: TextStyle(
              color: Colors.white,
              fontSize: size.shortestSide * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...titulares.asMap().entries.map((entry) {
            int index = entry.key;
            final jugador = entry.value;
            return buildPlayerTile(
              jugador,
              esTitular: true,
              onTap: () => _onTitularTap(index),
            );
          }),
          const SizedBox(height: 16),
          if (suplentes.isNotEmpty) ...[
            Text(
              "Suplentes",
              style: TextStyle(
                color: Colors.white,
                fontSize: size.shortestSide * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...suplentes.map((jugador) {
              return buildPlayerTile(jugador, esTitular: false, onTap: null);
            }),
          ],
        ],
      ),
    );
  }
}
