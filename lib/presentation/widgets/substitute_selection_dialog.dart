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
  _SubstituteSelectionDialogState createState() => _SubstituteSelectionDialogState();
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado con botón de retroceso.
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Suplentes disponibles',
                  style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.availableNumbers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: getCircleColor(widget.availableCategories[index]),
                    child: Text(widget.availableNumbers[index], style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(widget.availableNumbers[index], style: const TextStyle(color: Colors.white)),
                  subtitle: Text(widget.availableCategories[index] ?? 'Sin categoría', style: const TextStyle(color: Colors.white70)),
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
                );
              },
            ),
          ),
          ElevatedButton(
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
              backgroundColor: hasSelection ? Colors.green[600] : Colors.grey[700],
              elevation: hasSelection ? 4 : 0,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
