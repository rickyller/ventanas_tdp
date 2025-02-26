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
    this.backgroundColor = const Color(0xFF123C52),
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
    final double dialogWidth = screenSize.width * 0.8;
    final double buttonSize = screenSize.width * 0.131;

    return AlertDialog(
      backgroundColor: widget.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenSize.width * 0.1),
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCategoryButton("May", buttonSize),
                  _buildCategoryButton("Med", buttonSize),
                  _buildCategoryButton("men", buttonSize),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 30,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  style: TextStyle(color: widget.textColor, fontSize: 14),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: widget.defaultNumber,
                    hintStyle: TextStyle(color: Colors.black, fontSize: 14),
                    errorText: errorText,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 4.0),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.onCancel != null)
                    _buildDialogButton(
                      child: const Icon(Icons.close, color: Colors.white),
                      color: Colors.red,
                      size: buttonSize,
                      onPressed: widget.onCancel!,
                    ),
                  if (widget.onCancel != null)
                    SizedBox(width: screenSize.width * 0.05),
                  _buildDialogButton(
                    child: const Icon(Icons.check, color: Colors.white),
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

  Widget _buildCategoryButton(String category, double size) {
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
          style: const TextStyle(fontSize: 7.9, color: Colors.white),
        ),
      ),
    );
  }

  void _handleAccept() {
    final input = _controller.text;
    if (selectedCategory == null) {
      setState(() {
        errorText = 'Seleccione una categoría';
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
}
