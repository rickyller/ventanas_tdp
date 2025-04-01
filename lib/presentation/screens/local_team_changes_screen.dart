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
  late List<Map<String, dynamic>> _originalTitulares;
  late List<Map<String, dynamic>> _originalSuplentes;

  // Se espera que este valor provenga del argumento 'teamName'
  // en tu caso, el valor que se le pasa es leftTeamName.
  late String teamName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        print('Argumentos recibidos: $args');
        // Asegúrate de que en tu TeamSelectorScreen estés pasando
        // 'teamName': widget.leftTeamName como argumento a esta ruta.
        if (args.containsKey('teamName')) {
          teamName = args['teamName'] as String;
        } else {
          // En caso de que no exista el argumento, podemos asignar un valor por defecto.
          teamName = 'Local';
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

  void _showValidationError(String message) {
    final Size screenSize = MediaQuery.of(context).size;
    final double dialogWidth = screenSize.width * 0.8;
    // Calculamos el alto disponible restando los insetPadding (8 superior y 8 inferior)
    final double availableHeight = screenSize.height - 16;
    // Usamos el 50% de la altura de pantalla, o el alto disponible si es menor
    final double dialogHeight = screenSize.height * 0.5 < availableHeight
        ? screenSize.height * 0.5
        : availableHeight;

    showDialog<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: AlertDialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            // Se elimina el padding interno del contenido para aprovechar el espacio
            contentPadding: EdgeInsets.zero,
            backgroundColor: Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenSize.width * 0.08),
            ),
            content: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: dialogWidth,
                  maxHeight: dialogHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Regla incumplida",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenSize.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: screenSize.width * 0.04,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.05),
                    Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: dialogWidth * 0.4,
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blueAccent,
                            textStyle: TextStyle(
                              fontSize: screenSize.width * 0.055,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const Text("Aceptar"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _validarTitulares() {
    // Contamos en forma case-insensitive
    final int countMen = titulares.where((t) {
      final cat = t['category']?.toString().trim().toLowerCase();
      return cat == 'men';
    }).length;

    final int countMed = titulares.where((t) {
      final cat = t['category']?.toString().trim().toLowerCase();
      return cat == 'med';
    }).length;

    debugPrint("Validación titulares => men=$countMen, med=$countMed");

    // Regla 1: al menos 1 men
    if (countMen < 1) {
      _showValidationError(
          "Debe haber al menos un jugador Menor (men) en los titulares.");
      return false;
    }

    // Regla 2: men + med >= 3
    final int totalMenYMed = countMen + countMed;
    if (totalMenYMed < 3) {
      _showValidationError(
          "Actualmente tienes men=$countMen, med=$countMed (suma=$totalMenYMed).");
      return false;
    }

    return true;
  }

  Future<bool?> _showConfirmDialog({
    required BuildContext context,
    required double dialogFontSize,
    required String title,
    required bool showSubstitutions,
  }) {
    final watchSize = MediaQuery.of(context).size;
    final double iconSize = watchSize.width * 0.09;

    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        // Obtenemos el tamaño de la pantalla para hacerlo responsivo.
        final Size watchSize = MediaQuery.of(dialogContext).size;

        // Podemos definir aquí el tamaño base de fuente, íconos, etc.
        final double substitutionFontSize = watchSize.width * 0.055;
        final double noSubstitutionFontSize = watchSize.width * 0.065;
        final double titleFontSize = watchSize.width * 0.06;
        final double iconSize =
            watchSize.width * 0.08; // Ajusta según necesidad

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget titleWidget;
            if (showSubstitutions) {
              if (substitutionChanges.isNotEmpty) {
                // Dividimos la lista de sustituciones en dos columnas.
                int half = (substitutionChanges.length / 2).ceil();
                List<String> leftList = substitutionChanges.sublist(0, half);
                List<String> rightList = substitutionChanges.sublist(half);

                titleWidget = Container(
                  // Ajustamos la altura al 25% de la pantalla del reloj.
                  height: watchSize.height * 0.25,
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Columna izquierda
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: leftList
                                .map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Text(
                                      s,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: substitutionFontSize,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Columna derecha
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: rightList
                                .map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Text(
                                      s,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: substitutionFontSize,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Sin sustituciones
                titleWidget = Text(
                  "No se han realizado sustituciones",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: noSubstitutionFontSize,
                  ),
                  textAlign: TextAlign.center,
                );
              }
            } else {
              // Título normal
              titleWidget = Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              );
            }

            return BasicConfirmationDialog(
              // Usamos el widget titleWidget en la propiedad title.
              title: titleWidget,
              confirmText: "",
              cancelText: "",
              onConfirm: () => Navigator.pop(dialogContext, true),
              onCancel: () => Navigator.pop(dialogContext, false),
              backgroundColor: Colors.grey[850]!,
              confirmButtonColor: const Color.fromARGB(255, 18, 108, 210),
              cancelButtonColor: const Color.fromARGB(255, 242, 20, 20),
              // Ajustamos el tamaño de los íconos con base en watchSize
              confirmIcon:
                  Icon(Icons.check, color: Colors.white, size: iconSize),
              cancelIcon:
                  Icon(Icons.close, color: Colors.white, size: iconSize),
              // Ícono intermedio (siempre presente según tu ejemplo)
              middleIcon: Icon(Icons.undo, color: Colors.white, size: iconSize),
              onMiddlePressed: () {
                _undoLastSubstitution();
                setDialogState(() {}); // Actualiza el diálogo dinámicamente
              },
              content: null,
              // Ajustamos el tamaño de los botones usando MediaQuery
              buttonSize: watchSize.width * 0.17,
              buttonSpacing: watchSize.width * 0.02,
              dialogWidthFactor: 1, // Usa todo el ancho disponible
              // Ajusta el alto mínimo del diálogo para pantallas pequeñas
              dialogMinHeight: watchSize.height * 0.45,
            );
          },
        );
      },
    );
  }

  void _onTitularTap(int titularIndex) {
    if (suplentes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'No hay suplentes',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 80, 80),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
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
                  // Botón de atrás
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () async {
                      if (substitutionChanges.isEmpty) {
                        final updatedNumbers = [
                          for (var t in _originalTitulares)
                            t['number'] as String,
                          for (var s in _originalSuplentes)
                            s['number'] as String,
                        ];
                        final updatedCategories = [
                          for (var t in _originalTitulares)
                            t['category'] as String?,
                          for (var s in _originalSuplentes)
                            s['category'] as String?,
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
                            for (var t in _originalTitulares)
                              t['number'] as String,
                            for (var s in _originalSuplentes)
                              s['number'] as String,
                          ];
                          final updatedCategories = [
                            for (var t in _originalTitulares)
                              t['category'] as String?,
                            for (var s in _originalSuplentes)
                              s['category'] as String?,
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
                  // Aquí mostramos el nombre del equipo (leftTeamName)
                  Text(
                    teamName,
                    style: TextStyle(
                      fontSize: size.shortestSide * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Botón de confirmar
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
                        // Validamos las reglas
                        if (!_validarTitulares()) {
                          return;
                        }
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
              return buildPlayerTile(jugador, esTitular: false, onTap: null);
            }),
          ],
        ],
      ),
    );
  }
}
