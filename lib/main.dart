import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'models/tarefa.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de Tarefas',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller = TextEditingController();

  List<Tarefa> tarefas = [];

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  Future<void> carregarTarefas() async {
    tarefas = await DatabaseHelper.instance.getTarefas();
    setState(() {});
  }

  Future<void> adicionarTarefa() async {
    if (controller.text.trim().isEmpty) return;

    final tarefa = Tarefa(
      titulo: controller.text.trim(),
    );

    await DatabaseHelper.instance.insertTarefa(tarefa);

    controller.clear();

    carregarTarefas();
  }

  Future<void> removerTarefa(int id) async {
    await DatabaseHelper.instance.deleteTarefa(id);
    carregarTarefas();
  }

  Future<void> editarTarefa(Tarefa tarefa) async {
    final TextEditingController editController =
        TextEditingController(text: tarefa.titulo);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar tarefa"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Novo nome",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editController.text.trim().isNotEmpty) {
                  final tarefaAtualizada = Tarefa(
                    id: tarefa.id,
                    titulo: editController.text.trim(),
                  );

                  await DatabaseHelper.instance
                      .updateTarefa(tarefaAtualizada);

                  await carregarTarefas();

                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Tarefas"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Digite uma tarefa',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.task),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: adicionarTarefa,
                icon: const Icon(Icons.add),
                label: const Text("Adicionar"),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: tarefas.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhuma tarefa cadastrada",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tarefas.length,
                      itemBuilder: (context, index) {
                        final tarefa = tarefas[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.check_circle_outline),
                            title: Text(tarefa.titulo),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: "Editar",
                                  onPressed: () {
                                    editarTarefa(tarefa);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: "Excluir",
                                  onPressed: () {
                                    removerTarefa(tarefa.id!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}