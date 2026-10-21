
class Incidencia {
  String id;
  String titulo;
  String descripcion;
  String cliente;
  String categoria;
  String estado;
  String fecha;
  String prioridad;

  static const prioridadesValidas = ['Baja', 'Media', 'Alta'];

  Incidencia({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.cliente,
    required this.categoria,
    required this.estado,
    required this.fecha,
    this.prioridad = 'Media',
  });

  factory Incidencia.desdeJson(Map<String, dynamic> m) {
    final prioridadLeida = m['prioridad']?.toString();

    return Incidencia(
      id: m['id']?.toString() ?? '',
      titulo: m['titulo']?.toString() ?? '',
      descripcion: m['descripcion']?.toString() ?? '',
      cliente: m['cliente']?.toString() ?? '',
      categoria: m['categoria']?.toString() ?? 'Software',
      estado: m['estado']?.toString() ?? 'Pendiente',
      fecha: m['fecha']?.toString() ?? '',
      prioridad: prioridadesValidas.contains(prioridadLeida)
          ? prioridadLeida!
          : 'Media',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'cliente': cliente,
      'categoria': categoria,
      'estado': estado,
      'fecha': fecha,
      'prioridad': prioridad,
    };
  }
}
