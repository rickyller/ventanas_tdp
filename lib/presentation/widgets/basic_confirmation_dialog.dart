import 'package:flutter/material.dart';

class BasicConfirmationDialog extends StatelessWidget {
  final Widget? title;          // Widget opcional para el título (puede ser texto, imagen, etc.)
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
  final double? dialogHeightFactor;
  final double? dialogWidthFactor;

  const BasicConfirmationDialog({
    Key? key,
    this.title,
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
    this.buttonSpacing,
    this.titleFontSize,
    this.dialogMinHeight,
    this.dialogHeightFactor,
    this.dialogWidthFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla con MediaQuery
    final Size screenSize = MediaQuery.of(context).size;

    // Si no se provee 'dialogWidthFactor', usamos 1.0 (toda la pantalla)
    // aunque típicamente un valor como 0.7 o 0.8 puede ser adecuado en relojes.
    final double effectiveDialogWidth =
        screenSize.width * (dialogWidthFactor ?? 1.0);

    // Si no se provee 'buttonSize', usamos 15% del ancho de pantalla
    final double effectiveButtonSize = buttonSize ?? screenSize.width * 0.15;

    // Si no se provee 'dialogMinHeight', usamos 25% de la altura de pantalla
    final double effectiveMinHeight =
        dialogMinHeight ?? screenSize.height * 0.25;

    // Si no se provee 'dialogHeightFactor', usamos 0.5 (mitad de la pantalla)
    final double effectiveDialogHeight =
        screenSize.height * (dialogHeightFactor ?? 0.5);

    // Espaciado entre los botones (si alguno lo provee, si no, se usa 0.02 * ancho)
    final double effectiveButtonSpacing =
        buttonSpacing ?? (screenSize.width * 0.02);

    return AlertDialog(
      // insetPadding define margen alrededor del diálogo
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.02,
        vertical: screenSize.height * 0.02,
      ),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenSize.width * 0.1),
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: effectiveDialogWidth,
            minHeight: effectiveMinHeight,
            maxHeight: effectiveDialogHeight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Área superior: título
              if (title != null) title!,

              // Contenido adicional (si existe)
              if (content != null) ...[
                SizedBox(height: screenSize.height * 0.02),
                content!,
              ],

              // Separador
              SizedBox(height: screenSize.height * 0.015),

              // Contenedor para los botones
              SizedBox(
                height: effectiveButtonSize,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón de cancelar (si cancelText o cancelIcon existe)
                    if (cancelText.isNotEmpty || cancelIcon != null)
                      _buildDialogButton(
                        child: cancelIcon ?? Text(cancelText),
                        color: cancelButtonColor,
                        size: effectiveButtonSize,
                        onPressed: onCancel,
                      ),

                    // Botón intermedio (si middleIcon existe)
                    if (middleIcon != null)
                      SizedBox(width: effectiveButtonSpacing),
                    if (middleIcon != null)
                      _buildDialogButton(
                        child: middleIcon!,
                        color: Colors.orange,
                        size: effectiveButtonSize,
                        onPressed: onMiddlePressed ?? () {},
                      ),

                    // Espaciado entre botones
                    if ((cancelText.isNotEmpty || cancelIcon != null) ||
                        middleIcon != null)
                      SizedBox(width: effectiveButtonSpacing),

                    // Botón de confirmar (si confirmText o confirmIcon existe)
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

  /// Widget helper para crear un botón circular del diálogo
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
