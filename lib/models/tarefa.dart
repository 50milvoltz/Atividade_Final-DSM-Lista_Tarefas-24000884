class Tarefa {
  int? id;
  String titulo;

  Tarefa({
    this.id,
    required this.titulo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
    };
  }

  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'],
      titulo: map['titulo'],
    );
  }
}