import 'package:flutter/material.dart';
import 'package:ventanas_tdp/presentation/widgets/substitute_selection_dialog.dart';
import 'package:ventanas_tdp/presentation/widgets/basic_confirmation_dialog.dart';

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

class VisitorTeamChangesScreen extends StatefulWidget {
  const VisitorTeamChangesScreen({Key? key}) : super(key: key);

  @override
  _VisitorTeamChangesScreenState createState() => _VisitorTeamChangesScreenState();
}

class _VisitorTeamChangesScreenState extends State<VisitorTeamChangesScreen> {
  late List<Map<String, dynamic>> titulares;
  late List<Map<String, dynamic>> suplentes;
  List<String> substitutionChanges = [];

  /// Pila de acciones para poder deshacer la última sustitución.
  final List<SubstitutionAction> _substitutionStack = [];

  bool _isInitialized = false;
  // Para guardar los datos originales y poder descartar cambios.
  late List<Map<String, dynamic>> _originalTitulares;
  late List<Map<String, dynamic>> _originalSuplentes;

  // Se espera que este valor provenga del argumento 'teamName', por defecto "Visita".
  String teamName = 'Visita';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        debugPrint('Argumentos recibidos (Visita): $args');
        if (args.containsKey('teamName')) {
          teamName = args['teamName'] as String;
        }
      }

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
      // Guardamos una copia de los datos originales para poder descartar cambios.
      _originalTitulares = List<Map<String, dynamic>>.from(titulares);
      _originalSuplentes = List<Map<String, dynamic>>.from(suplentes);

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
      final revertIndex = lastAction.titularIndex;
      titulares[revertIndex] = lastAction.oldTitular;
      suplentes.add(lastAction.newTitular);
      if (substitutionChanges.isNotEmpty) {
        substitutionChanges.removeLast();
      }
      setState(() {});
    }
  }

  /// Muestra el diálogo de confirmación usando BasicConfirmationDialog.
  /// Si showSubstitutions es true, se mostrarán los cambios; 
  /// de lo contrario, se usará el mensaje que se pase en title.
  Future<bool?> _showConfirmDialog({
    required BuildContext context,
    required double dialogFontSize,
    required String title,
    required bool showSubstitutions,
  }) {
    final watchSize = MediaQuery.of(context).size;
    final double iconSize = watchSize.width * 0.07;
    final String titleText = showSubstitutions
        ? (substitutionChanges.isNotEmpty ? substitutionChanges.join("\n") : "")
        : title;
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BasicConfirmationDialog(
              title: titleText,
              confirmText: "",
              cancelText: "",
              onConfirm: () => Navigator.pop(context, true),
              onCancel: () => Navigator.pop(context, false),
              backgroundColor: Colors.grey[850]!,
              confirmButtonColor: const Color.fromARGB(255, 18, 108, 210),
              cancelButtonColor: const Color.fromARGB(255, 242, 20, 20),
              confirmIcon:
                  Icon(Icons.check, color: Colors.white, size: iconSize),
              cancelIcon:
                  Icon(Icons.close, color: Colors.white, size: iconSize),
              middleIcon: Icon(Icons.undo, color: Colors.white, size: iconSize),
              onMiddlePressed: () {
                _undoLastSubstitution();
                setDialogState(() {});
              },
              content: const SizedBox.shrink(),
              buttonSize: watchSize.width * 0.12,
              buttonSpacing: watchSize.width * 0.01,
              titleFontSize: watchSize.width * 0.045,
              dialogWidthFactor: 1,
              dialogMinHeight: watchSize.height * 0.45,
            );
          },
        );
      },
    );
  }

  /// Manejo del tap en un jugador titular para hacer el cambio.
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

              _substitutionStack.add(
                SubstitutionAction(
                  titularIndex: titularIndex,
                  oldTitular: leaving,
                  newTitular: substitute,
                ),
              );

              titulares[titularIndex] = substitute;
              suplentes.removeAt(selectedIndex);

              substitutionChanges.add(
                "Entra ${substitute['number']}, Sale ${leaving['number']}",
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
    final size = MediaQuery.of(context).size;
    final double cardHeight = size.height * 0.25;
    final double avatarRadius = cardHeight * 0.3;
    final double titleFontSize = cardHeight * 0.25;
    final double subtitleFontSize = cardHeight * 0.20;
    final double horizontalPadding = cardHeight * 0.2;
    final double topPadding = cardHeight * 0.05;
    final double bottomPadding = cardHeight * 0.1;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: cardHeight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: topPadding,
              bottom: bottomPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: getCircleColor(jugador['category']),
                  child: Text(
                    jugador['number'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: cardHeight * 0.2,
                    ),
                  ),
                ),
                SizedBox(width: horizontalPadding * 0.5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Jugador ${jugador['number']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize,
                        ),
                      ),
                      SizedBox(height: cardHeight * 0.02),
                      Text(
                        jugador['category'] ?? 'S/C',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: subtitleFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: Colors.grey[900],
          child: SafeArea(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón de atrás:
                  // Si no hubo sustituciones se retorna directamente la información original;
                  // si hubo, se muestra el diálogo con el mensaje "Se descartarán los cambios realizados."
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () async {
                      if (substitutionChanges.isEmpty) {
                        final updatedNumbers = [
                          for (var t in _originalTitulares) t['number'] as String,
                          for (var s in _originalSuplentes) s['number'] as String,
                        ];
                        final updatedCategories = [
                          for (var t in _originalTitulares) t['category'] as String?,
                          for (var s in _originalSuplentes) s['category'] as String?,
                        ];
                        final updatedIsTitular = [
                          for (var _ in _originalTitulares) true,
                          for (var _ in _originalSuplentes) false,
                        ];
                        final returnData = {
                          'numbers': updatedNumbers,
                          'categories': updatedCategories,
                          'isTitular': updatedIsTitular,
                          'substitutionChanges': <String>[],
                        };
                        Navigator.pop(context, returnData);
                      } else {
                        final bool? confirm = await _showConfirmDialog(
                          context: context,
                          dialogFontSize: dialogFontSize,
                          title: "Se descartarán los cambios realizados.",
                          showSubstitutions: false,
                        );
                        if (confirm == true) {
                          final updatedNumbers = [
                            for (var t in _originalTitulares) t['number'] as String,
                            for (var s in _originalSuplentes) s['number'] as String,
                          ];
                          final updatedCategories = [
                            for (var t in _originalTitulares) t['category'] as String?,
                            for (var s in _originalSuplentes) s['category'] as String?,
                          ];
                          final updatedIsTitular = [
                            for (var _ in _originalTitulares) true,
                            for (var _ in _originalSuplentes) false,
                          ];
                          final returnData = {
                            'numbers': updatedNumbers,
                            'categories': updatedCategories,
                            'isTitular': updatedIsTitular,
                            'substitutionChanges': <String>[],
                          };
                          Navigator.pop(context, returnData);
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    teamName,
                    style: TextStyle(
                      fontSize: size.shortestSide * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Botón de confirmar: muestra los cambios y guarda las modificaciones.
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      final bool? confirm = await _showConfirmDialog(
                        context: context,
                        dialogFontSize: dialogFontSize,
                        title: "",
                        showSubstitutions: true,
                      );
                      if (confirm == true) {
                        final updatedNumbers = [
                          for (var t in titulares) t['number'] as String,
                          for (var s in suplentes) s['number'] as String,
                        ];
                        final updatedCategories = [
                          for (var t in titulares) t['category'] as String?,
                          for (var s in suplentes) s['category'] as String?,
                        ];
                        final updatedIsTitular = [
                          for (var _ in titulares) true,
                          for (var _ in suplentes) false,
                        ];
                        final returnData = {
                          'numbers': updatedNumbers,
                          'categories': updatedCategories,
                          'isTitular': updatedIsTitular,
                          'substitutionChanges': substitutionChanges,
                        };
                        Navigator.pop(context, returnData);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
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
              return buildPlayerTile(
                jugador,
                esTitular: false,
                onTap: null,
              );
            }),
          ],
        ],
      ),
    );
  }
}
