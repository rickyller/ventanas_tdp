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
            // Encabezado: en un SizedBox con altura fija
            SizedBox(
              height: screenSize.height * 0.18,
              child: Stack(
                children: [
                  // Título centrado
                  Center(
                    child: Text(
                      'Suplentes disponibles',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.045,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Botón de back, posicionado a la izquierda
                  Positioned(
                    left: 0,
                    right: 0,
                    top: -25,
                    bottom: -50,
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
            // Quitamos el SizedBox que había aquí para que la lista inicie de inmediato
            // Lista que ocupa aproximadamente 45% de la pantalla
            Expanded(
              child: ListView.builder(
                itemCount: widget.availableNumbers.length,
                itemBuilder: (context, index) {
                  return Container(
                    // Se mantiene la altura para ver 2 tarjetas
                    height: (screenSize.height * 0.45) / 2,
                    // Se elimina la margin vertical
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: screenSize.width * 0.06, // Se reduce el radio
                        backgroundColor:
                            getCircleColor(widget.availableCategories[index]),
                        child: Text(
                          widget.availableNumbers[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenSize.width * 0.045,
                          ),
                        ),
                      ),
                      title: Text(
                        widget.availableNumbers[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.055,
                        ),
                      ),
                      subtitle: Text(
                        widget.availableCategories[index] ?? 'S/C',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenSize.width * 0.055,
                        ),
                      ),
                      trailing: Checkbox(
                        value: selected[index],
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              for (int i = 0; i < selected.length; i++) {
                                selected[i] = false;
                              }
                              selected[index] = true;
                            } else {
                              selected[index] = false;
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            // Botón de confirmar con altura fija ~10% de la pantalla
            SizedBox(
              height: screenSize.height * 0.1,
              child: ElevatedButton(
                onPressed: hasSelection
                    ? () {
                        final selectedIndices = <int>[];
                        for (int i = 0; i < selected.length; i++) {
                          if (selected[i]) selectedIndices.add(i);
                        }
                        widget.onConfirm(selectedIndices);
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasSelection ? Colors.green[600] : Colors.grey[700],
                  elevation: hasSelection ? 4 : 0,
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.width * 0.02,
                    horizontal: screenSize.width * 0.04,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: TextStyle(
                    fontSize: screenSize.width * 0.03,
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
