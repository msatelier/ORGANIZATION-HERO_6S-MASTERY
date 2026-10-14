# Historial de cambios

## 2026-10-13 — 0.1.1: controles y animaciones

- Colocación con dos toques o clics: seleccionar objeto y después destino.
- Guías de destinos disponibles, cantidad de lugares libres y motivo de rechazo durante el arrastre; un rechazo conserva la selección para reintentar.
- Pistas que consideran apertura/capacidad y seleccionan un objeto accionable.
- Arrastre conserva el punto de agarre. Se pausa una animación al agarrar el objeto y solo el botón que inició el gesto puede terminarlo.
- Cancelar limpia selección, guías y estado del puntero; botón contextual para hacerlo también sin teclado.
- Puerta animada; reducción de animaciones aplicada también a puerta/cámara. Los cambios de estado conservan animaciones en curso cuando el destino no cambió.
- La textura de suciedad se actualiza solo al cambiar cobertura o vista antes/después.
- 55 comprobaciones de dominio, 49 por renderizador/paquete y 5 de datos exportados, sin fallos. Windows y APK debug regenerados; verificación del ciclo del PCK disponible con export-prototype.ps1 -Graphics.
- Se conserva esquema de progreso y versión de contenido 1. Pruebas humanas y móviles físicas pendientes.

## 2026-10-13 — Primer dormitorio jugable

- Base Godot 4.7.2, Resources tipados y escena integrada.
- Cámara, selección, arrastre, encaje, contenedor, cancelación y deshacer.
- Limpieza espacial, seguridad doméstica, coleccionable y objetivos.
- Resultados, comparación, repetición, progreso versionado, ajustes y dos idiomas.
- Audio/arte geométricos de prototipo.
- Importación limpia y arranque verificados; 52 comprobaciones de dominio, 34 por renderizador y paquete, 5 de exportación.
- Ejecutable Windows con PCK separado y APK ARM64 debug firmada.
- Capturas reales en docs/images y procedimientos reproducibles.
- Resueltas pérdida de PackedArrays al convertir Resources, datos inválidos y bloqueo del ejecutable con paquete incrustado.

Pendientes: pruebas de jugadores, arte/audio definitivos, touch físico, rendimiento Android e iOS. No se declara completada la aceptación móvil.


## 2026-10-13 — Descubrimiento y planificación

- Leído el prompt maestro completo y conservado como referencia.
- Inspeccionada la carpeta local vacía y el repositorio remoto con su README inicial.
- Clonado el repositorio en la ubicación de trabajo solicitada.
- Verificados Godot 4.7.2, plantillas coincidentes, VS Code, Godot Tools, Git, Java y Android SDK/ADB.
- Resuelto el acceso del checkout seleccionando la clave SSH existente asociada al perfil de msatelier, sin editar credenciales.
- Redactados análisis, diseño inicial, arquitectura, decisiones, hoja de ruta y plan de pruebas.
- Añadida configuración para excluir cachés, binarios y credenciales y conservar finales de línea coherentes.
- Matías confirmó que todavía no tiene un dispositivo Android; validación física registrada como pendiente.

No hay proyecto Godot ni funciones jugables implementadas. No se ejecutaron pruebas del juego, exportaciones ni benchmarks. La Fase 0 sigue abierta hasta tener una base ejecutable verificada.

El informe de entrega de esta conversación registra el resultado final del commit y de la sincronización con GitHub.
