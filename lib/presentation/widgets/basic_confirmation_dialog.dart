import 'package:flutter/material.dart';

class BasicConfirmationDialog extends StatelessWidget {
  final String title;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Color backgroundColor;
  final Color confirmButtonColor;
  final Color cancelButtonColor;
  final Widget? content;
  final Widget? confirmIcon;
  final Widget? cancelIcon;
  final Widget? middleIcon;
  final VoidCallback? onMiddlePressed;
  final double? buttonSize;
  final double? buttonSpacing;
  final double? titleFontSize;
  final double? dialogMinHeight;
  final double? dialogHeightFactor; // Nueva propiedad
  final double? dialogWidthFactor; // Nueva propiedad

  const BasicConfirmationDialog({
    Key? key,
    required this.title,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
    this.backgroundColor = const Color.fromARGB(5, 45, 48, 50),
    this.confirmButtonColor = const Color.fromARGB(255, 2, 148, 90),
    this.cancelButtonColor = Colors.red,
    this.content,
    this.confirmIcon,
    this.cancelIcon,
    this.middleIcon,
    this.onMiddlePressed,
    this.buttonSize,
    this.dialogWidthFactor,
    this.buttonSpacing,
    this.titleFontSize,
    this.dialogMinHeight,
    this.dialogHeightFactor, // Inicialización de la nueva propiedad
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    // Si no se provee dialogWidthFactor, se usa 1.0 para abarcar casi todo el ancho
    final double effectiveDialogWidth =
        screenSize.width * (dialogWidthFactor ?? 1.0);
    final double effectiveTitleFontSize =
        titleFontSize ?? screenSize.width * 0.07;
    final double effectiveButtonSize = buttonSize ?? screenSize.width * 0.15;
    final double effectiveMinHeight =
        dialogMinHeight ?? screenSize.height * 0.25;
    final double effectiveDialogHeight =
        screenSize.height * (dialogHeightFactor ?? 0.5); // Altura efectiva del diálogo

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenSize.width * 0.1),
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: effectiveDialogWidth,
            minHeight: effectiveMinHeight,
            maxHeight: effectiveDialogHeight, // Altura máxima del diálogo
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Contenido superior: título y contenido opcional
              Column(
                children: [
                  // Envolvemos el título en un contenedor con altura máxima y scroll
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      // Por ejemplo, si hay más de 2 cambios, se limitará a un 15% de la altura de pantalla
                      maxHeight: screenSize.height * 0.22,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: effectiveTitleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.width * 0.05),
                  if (content != null) content!,
                  if (content != null)
                    SizedBox(height: screenSize.width * 0.05),
                ],
              ),
              // Fila de botones en la parte inferior
              Container(
                width: effectiveDialogWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (cancelText.isNotEmpty || cancelIcon != null)
                      _buildDialogButton(
                        child: cancelIcon ?? Text(cancelText),
                        color: cancelButtonColor,
                        size: effectiveButtonSize,
                        onPressed: onCancel,
                      ),
                    if (middleIcon != null)
                      _buildDialogButton(
                        child: middleIcon!,
                        color: Colors.orange,
                        size: effectiveButtonSize,
                        onPressed: onMiddlePressed ?? () {},
                      ),
                    if (confirmText.isNotEmpty || confirmIcon != null)
                      _buildDialogButton(
                        child: confirmIcon ?? Text(confirmText),
                        color: confirmButtonColor,
                        size: effectiveButtonSize,
                        onPressed: onConfirm,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
