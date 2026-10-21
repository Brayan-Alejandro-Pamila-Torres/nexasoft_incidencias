
import 'package:flutter/material.dart';
import '../model/incidencia.dart';
import '../services/gestor_incidencias.dart';
import 'pantalla_detalle.dart';
import 'pantalla_nueva.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final GestorIncidencias g = GestorIncidencias();

  bool cargando = true;
  String? error;
  String busqueda = '';
  String? estadoSeleccionado;
  String? prioridadSeleccionada;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      await g.iniciar();
    } catch (e) {
      error = 'No se pudieron cargar las incidencias: $e';
    }

    if (mounted) {
      setState(() => cargando = false);
    }
  }

  Color colorEstado(String estado) {
    if (estado == 'Resuelta') {
      return const Color(0xFF147D64);
    }
    if (estado == 'En proceso') {
      return const Color(0xFFB56B13);
    }
    return const Color(0xFFAC4052);
  }

  Color colorFondoPrioridad(String prioridad) {
    if (prioridad == 'Alta') {
      return const Color(0xFFFFE0E0);
    }
    if (prioridad == 'Baja') {
      return const Color(0xFFE0F2E8);
    }
    return const Color(0xFFFFF0D6);
  }

  Color colorTextoPrioridad(String prioridad) {
    if (prioridad == 'Alta') {
      return const Color(0xFFAC2435);
    }
    if (prioridad == 'Baja') {
      return const Color(0xFF147D4B);
    }
    return const Color(0xFF925C08);
  }

  Widget etiquetaPrioridad(String prioridad) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: colorFondoPrioridad(prioridad),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Prioridad $prioridad',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorTextoPrioridad(prioridad),
        ),
      ),
    );
  }

  Widget resumen(String etiqueta, String valor, IconData icono) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(
                icono,
                size: 19,
                color: const Color(0xFF174C83),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                etiqueta,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> abrirDetalle(Incidencia item) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaDetalle(
          gestor: g,
          id: item.id,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> abrirFormulario() async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaNueva(gestor: g),
      ),
    );

    if (guardado == true && mounted) {
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incidencia registrada'),
        ),
      );
    }
  }

  Future<void> restablecerDatos() async {
    final aceptar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer demostración'),
        content: const Text(
          'Se descartarán los cambios locales y se cargarán '
          'las incidencias iniciales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );

    if (aceptar != true || !mounted) {
      return;
    }

    try {
      await g.reiniciarDemo();

      if (mounted) {
        setState(() {
          busqueda = '';
          estadoSeleccionado = null;
          prioridadSeleccionada = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reiniciar: $e'),
          ),
        );
      }
    }
  }

  void limpiarFiltros() {
    setState(() {
      busqueda = '';
      estadoSeleccionado = null;
      prioridadSeleccionada = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = g.buscar(
      busqueda,
      estado: estadoSeleccionado,
      prioridad: prioridadSeleccionada,
    );

    final hayFiltros = busqueda.trim().isNotEmpty ||
        estadoSeleccionado != null ||
        prioridadSeleccionada != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NexaSoft | Incidencias'),
        actions: [
          IconButton(
            tooltip: 'Restablecer datos de demostración',
            onPressed: restablecerDatos,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      floatingActionButton: cargando || error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: abrirFormulario,
              label: const Text('Nueva incidencia'),
              icon: const Icon(Icons.add),
            ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: cargar,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 860,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            14,
                            12,
                            8,
                          ),
                          child: Row(
                            children: [
                              resumen(
                                'Pendientes',
                                '${g.contar('Pendiente')}',
                                Icons.pending_actions,
                              ),
                              resumen(
                                'En proceso',
                                '${g.contar('En proceso')}',
                                Icons.build_outlined,
                              ),
                              resumen(
                                'Resueltas',
                                '${g.contar('Resuelta')}',
                                Icons.check_circle_outline,
                              ),
                            ],
                          ),
                        ),

                        // Buscador de texto
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 5,
                          ),
                          child: TextField(
                            controller: TextEditingController
                                .fromValue(
                              TextEditingValue(
                                text: busqueda,
                                selection: TextSelection.collapsed(
                                  offset: busqueda.length,
                                ),
                              ),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Buscar incidencias',
                              hintText:
                                  'Ejemplo: WiFi, correo, pantalla',
                              prefixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(),
                              suffixIcon: busqueda.isNotEmpty
                                  ? IconButton(
                                      tooltip: 'Limpiar búsqueda',
                                      onPressed: () {
                                        setState(() => busqueda = '');
                                      },
                                      icon: const Icon(Icons.clear),
                                    )
                                  : null,
                            ),
                            onChanged: (texto) {
                              setState(() => busqueda = texto);
                            },
                          ),
                        ),

                        // Filtros por estado y prioridad
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 5,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final ancho =
                                  (constraints.maxWidth - 10) / 2;

                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  SizedBox(
                                    width: ancho,
                                    child:
                                        DropdownButtonFormField<String?>(
                                      initialValue: estadoSeleccionado,
                                      isExpanded: true,
                                      decoration:
                                          const InputDecoration(
                                        labelText: 'Estado',
                                        border: OutlineInputBorder(),
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem<String?>(
                                          value: null,
                                          child: Text('Todos'),
                                        ),
                                        DropdownMenuItem<String?>(
                                          value: 'Pendiente',
                                          child: Text('Pendiente'),
                                        ),
                                        DropdownMenuItem<String?>(
                                          value: 'En proceso',
                                          child: Text('En proceso'),
                                        ),
                                        DropdownMenuItem<String?>(
                                          value: 'Resuelta',
                                          child: Text('Resuelta'),
                                        ),
                                      ],
                                      onChanged: (valor) {
                                        setState(() {
                                          estadoSeleccionado = valor;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: ancho,
                                    child:
                                        DropdownButtonFormField<String?>(
                                      initialValue:
                                          prioridadSeleccionada,
                                      isExpanded: true,
                                      decoration:
                                          const InputDecoration(
                                        labelText: 'Prioridad',
                                        border: OutlineInputBorder(),
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem<String?>(
                                          value: null,
                                          child: Text('Todas'),
                                        ),
                                        DropdownMenuItem<String?>(
                                          value: 'Baja',
                                          child: Text('Baja'),
                                        ),
                                        DropdownMenuItem<String?>(
                                          value: 'Media',
                                          child: Text('Media'),
                                        ),
                                        DropdownMenuItem<String?>(
                                          value: 'Alta',
                                          child: Text('Alta'),
                                        ),
                                      ],
                                      onChanged: (valor) {
                                        setState(() {
                                          prioridadSeleccionada =
                                              valor;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  hayFiltros
                                      ? '${items.length} resultados de '
                                          '${g.incidencias.length} incidencias'
                                      : '${items.length} registros',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              if (hayFiltros)
                                TextButton.icon(
                                  onPressed: limpiarFiltros,
                                  icon: const Icon(Icons.filter_alt_off),
                                  label: const Text('Limpiar filtros'),
                                ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: items.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No se encontraron incidencias '
                                    'con esos filtros',
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 12,
                                    bottom: 100,
                                  ),
                                  itemCount: items.length,
                                  itemBuilder: (context, i) {
                                    final item = items[i];

                                    return Card(
                                      margin: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        title: Text(
                                          item.titulo,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${item.id}  ·  '
                                                '${item.cliente}',
                                              ),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  Text(
                                                    item.estado,
                                                    style: TextStyle(
                                                      color: colorEstado(
                                                        item.estado,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  etiquetaPrioridad(
                                                    item.prioridad,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        trailing: const Icon(
                                          Icons.chevron_right,
                                        ),
                                        onTap: () => abrirDetalle(item),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
