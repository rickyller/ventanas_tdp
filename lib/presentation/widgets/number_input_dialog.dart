import 'package:flutter/material.dart';

/// Clase para representar el resultado de la entrada numérica junto a la categoría.
class NumberInputResult {
  final String number;
  final String category;

  NumberInputResult({required this.number, required this.category});
}

class NumberInputDialog extends StatefulWidget {
  final String buttonText;
  final Color backgroundColor;
  final Color buttonColor;
  final Color titleColor;
  final Color textColor;
  final VoidCallback? onCancel;
  final ValueChanged<NumberInputResult> onAccept;
  // Se añade la propiedad defaultNumber para recibir el número por defecto.
  final String defaultNumber;

  const NumberInputDialog({
    Key? key,
    this.buttonText = 'Aceptar',
    this.backgroundColor = const Color.fromARGB(255, 45, 48, 50),
    this.buttonColor = const Color(0xFF398164),
    this.titleColor = Colors.white,
    this.textColor = Colors.black,
    this.onCancel,
    required this.onAccept,
    this.defaultNumber = '1',
  }) : super(key: key);

  @override
  _NumberInputDialogState createState() => _NumberInputDialogState();
}

class _NumberInputDialogState extends State<NumberInputDialog> {
  final TextEditingController _controller = TextEditingController();
  String? errorText;
  String? selectedCategory; // "May", "Med" o "men"

  Color _mapCategoryToColor(String category) {
    switch (category) {
      case "May":
        return Colors.red;
      case "Med":
        return Colors.blue;
      case "men":
        return const Color.fromARGB(255, 180, 163, 7);
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    // Se asigna el valor por defecto recibido.
    _controller.text = widget.defaultNumber;
  }

@override
Widget build(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  // Usamos casi todo el ancho disponible para el diálogo.
  final double effectiveDialogWidth = screenSize.width * 0.95;
  // Tamaño de los botones, en función del ancho de pantalla.
  final double buttonSize = screenSize.width * 0.18;
  // Tamaño de la fuente para los textos y botones.
  final double textFontSize = screenSize.width * 0.04;
  // Altura del campo de entrada (puedes ajustar según lo necesites).
  final double inputHeight = screenSize.height * 0.15;

  return AlertDialog(
    insetPadding: EdgeInsets.symmetric(
      horizontal: screenSize.width * 0.05,
      vertical: screenSize.height * 0.05,
    ),
    backgroundColor: widget.backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(screenSize.width * 0.1),
    ),
    content: SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveDialogWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fila de botones de categoría
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryButton("May", buttonSize, textFontSize),
                _buildCategoryButton("Med", buttonSize, textFontSize),
                _buildCategoryButton("men", buttonSize, textFontSize),
              ],
            ),
            const SizedBox(height: 10),
            // Campo de entrada numérica
            SizedBox(
              height: inputHeight,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 3,
                style: TextStyle(color: widget.textColor, fontSize: textFontSize),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: widget.defaultNumber,
                  hintStyle: TextStyle(color: Colors.black, fontSize: textFontSize),
                  errorText: errorText,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  if (value.length > 3) {
                    setState(() {
                      errorText = 'Máximo 3 dígitos';
                    });
                  } else {
                    setState(() {
                      errorText = null;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            // Botones de aceptar y cancelar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.onCancel != null)
                  _buildDialogButton(
                    child: Icon(Icons.close, color: Colors.white, size: textFontSize),
                    color: Colors.red,
                    size: buttonSize,
                    onPressed: widget.onCancel!,
                  ),
                if (widget.onCancel != null)
                  SizedBox(width: screenSize.width * 0.05),
                _buildDialogButton(
                  child: Icon(Icons.check, color: Colors.white, size: textFontSize),
                  color: widget.buttonColor,
                  size: buttonSize,
                  onPressed: _handleAccept,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Se agregó el parámetro [textFontSize] para adaptar el tamaño de la fuente.
Widget _buildCategoryButton(String category, double size, double textFontSize) {
  bool isSelected = (selectedCategory == category);
  final Color catColor = _mapCategoryToColor(category);

  return SizedBox(
    width: size,
    height: size,
    child: ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? catColor : catColor.withOpacity(0.1),
        shape: const CircleBorder(),
        padding: EdgeInsets.all(size * 0.25),
      ),
      child: Text(
        category,
        style: TextStyle(fontSize: textFontSize, color: Colors.white),
      ),
    ),
  );
}

/// Botón genérico para el diálogo.
Widget _buildDialogButton({
  required Widget child,
  required Color color,
  required double size,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: size,
    height: size,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        padding: EdgeInsets.all(size * 0.25),
      ),
      child: child,
    ),
  );
}

  void _handleAccept() {
    final input = _controller.text;
    if (selectedCategory == null) {
      setState(() {
        errorText = 'Seleccione categoría';
      });
      return;
    }
    if (input.isNotEmpty && input.length <= 3 && int.tryParse(input) != null) {
      widget.onAccept(
        NumberInputResult(
          number: _controller.text,
          category: selectedCategory!,
        ),
      );
    } else {
      setState(() {
        errorText = 'Ingrese un número de max 3 dígitos';
      });
    }
  }

}
