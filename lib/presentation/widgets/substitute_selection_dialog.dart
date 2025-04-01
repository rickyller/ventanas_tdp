import 'package:flutter/material.dart';

class SubstituteSelectionDialog extends StatefulWidget {
  final List<String> availableNumbers;
  final List<String?> availableCategories;
  final Function(List<int>) onConfirm;

  const SubstituteSelectionDialog({
    Key? key,
    required this.availableNumbers,
    required this.availableCategories,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _SubstituteSelectionDialogState createState() =>
      _SubstituteSelectionDialogState();
}

class _SubstituteSelectionDialogState extends State<SubstituteSelectionDialog> {
  late List<bool> selected;

  @override
  void initState() {
    super.initState();
    selected = List.filled(widget.availableNumbers.length, false);
  }

  Color getCircleColor(String? category) {
    if (category == null) return Colors.grey;
    if (category == "men") return const Color.fromARGB(255, 180, 163, 7);
    if (category == "Med") return Colors.blue;
    if (category == "May") return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla para cálculos responsivos
    final Size screenSize = MediaQuery.of(context).size;

    // Definimos variables para tamaños y fuentes
    final double headerFontSize = screenSize.width * 0.055;
    final double backIconSize = screenSize.width * 0.1;
    final double circleAvatarRadius = screenSize.width * 0.06;
    final double circleAvatarFontSize = screenSize.width * 0.065;
    final double categoryFontSize = screenSize.width * 0.055;
    final double confirmButtonHeight = screenSize.height * 0.15;
    final double confirmButtonFontSize = screenSize.width * 0.06;

    // Comprobamos si hay alguna selección
    final bool hasSelection = selected.any((element) => element);

    return SafeArea(
      child: Container(
        // Color de fondo y esquinas redondeadas
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        // Usamos el alto total de la pantalla (puedes reducirlo si quieres)
        height: screenSize.height,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado (título + botón back)
            SizedBox(
              height: screenSize.height * 0.25,
              child: Stack(
                children: [
                  // Título centrado
                  Center(
                    child: Text(
                      'Suplentes disponibles',
                      style: TextStyle(
                        fontSize: headerFontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Botón de volver (arriba, superpuesto)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: -25,
                    bottom: -60,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: backIconSize,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de jugadores
            Expanded(
              child: ListView.builder(
                itemCount: widget.availableNumbers.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      tileColor: selected[index]
                          ? Colors.white12
                          : Colors.transparent,
                      leading: CircleAvatar(
                        radius: circleAvatarRadius,
                        backgroundColor:
                            getCircleColor(widget.availableCategories[index]),
                        child: Text(
                          widget.availableNumbers[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: circleAvatarFontSize,
                          ),
                        ),
                      ),
                      title: Text(
                        widget.availableCategories[index] ?? 'S/C',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: categoryFontSize,
                        ),
                      ),
                      trailing: Icon(
                        selected[index]
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selected[index] ? Colors.green : Colors.grey,
                      ),
                      onTap: () {
                        setState(() {
                          // Solo se permite seleccionar uno, así que deseleccionamos todos
                          for (int i = 0; i < selected.length; i++) {
                            selected[i] = false;
                          }
                          selected[index] = true;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Botón de Confirmar
            SizedBox(
              height: confirmButtonHeight,
              child: ElevatedButton(
                onPressed: hasSelection
                    ? () {
                        final selectedIndices = <int>[];
                        for (int i = 0; i < selected.length; i++) {
                          if (selected[i]) {
                            selectedIndices.add(i);
                          }
                        }
                        widget.onConfirm(selectedIndices);
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasSelection ? Colors.green[600] : Colors.grey[700],
                  elevation: hasSelection ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: TextStyle(
                    fontSize: confirmButtonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
