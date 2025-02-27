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
    final bool hasSelection = selected.any((element) => element);
    final Size screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(8),
        height: screenSize.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado
            SizedBox(
              height: screenSize.height * 0.25,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      'Suplentes disponibles',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.055,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: -25,
                    bottom: -60,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: screenSize.width * 0.1,
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
                    // Ajusta aquí el margen para disminuir la separación
                    margin: const EdgeInsets.only(bottom: 0),
                    child: ListTile(
                      // Hace el ListTile más compacto
                      dense: true,
                      // También puedes controlar el padding interno
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      tileColor: selected[index]
                          ? Colors.white12
                          : Colors.transparent,
                      leading: CircleAvatar(
                        radius: screenSize.width * 0.06,
                        backgroundColor:
                            getCircleColor(widget.availableCategories[index]),
                        child: Text(
                          widget.availableNumbers[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenSize.width * 0.065,
                          ),
                        ),
                      ),
                      title: Text(
                        widget.availableCategories[index] ?? 'S/C',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenSize.width * 0.055,
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
              height: screenSize.height * 0.15,
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
                    fontSize: screenSize.width * 0.06,
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
