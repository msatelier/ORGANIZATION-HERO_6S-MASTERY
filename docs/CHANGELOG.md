# Historial de cambios

## 2026-10-14 — 0.1.3: smartphone vertical y música

- Vista principal vertical 9:20, elegida por Matías; ventana de desarrollo 432 × 960 y Android en portrait.
- Interfaz adaptable, objetivos/acciones inferiores en vertical y laterales en horizontal, ajustes desplazables y controles de al menos 48 unidades.
- Cámara ajustada al espacio libre, márgenes seguros en todos los bordes y cancelación al redimensionar.
- Etiquetas del mundo más grandes y textos móviles compactos en ambos idiomas.
- Melodía original de juego de 40 segundos a 96 BPM, preparada previamente, reemplazando el acorde sostenido.
- Corregidos escala de eventos simulados, formato/bucle del WAV importado y lectura eficiente de muestras en pruebas.
- 58 comprobaciones de reglas, 31 de recursos, 36 de distribución, 65 por combinación de tamaño/renderizador y 7 de exportación; sin fallos. Paquete recorrido en ambas orientaciones.
- Progreso conservado. Hardware Android y evaluación sonora/táctil humana siguen pendientes.

## 2026-10-14 — 0.1.2: arte y sonido por material

- Siluetas de prendas y medias mediante polígonos extruidos; peluche redondeado con patas, orejas, hocico y lazo.
- Libros con cubiertas/páginas, botella etiquetada y papel con detalles.
- Cortinas, planta, lámpara, manta y alfombra; iluminación ajustada sin añadir luces ni efectos exclusivos.
- Agrupación de geometría estática por material, conservando colisiones y partes interactivas. Contador puntual en PC: 148/232 draw calls frente a 187/294 de 0.1.1; sin acreditar FPS móviles.
- Cinco perfiles sonoros con tres variantes; apertura/cierre, hallazgo, final y ambiente renovados. Clips sintetizados propios.
- Roce continuo del paño según movimiento, con silencio al detener, salir de la superficie o cancelar. Voz independiente y volumen por bus.
- Contexto de acciones identifica objeto/destino o estado del contenedor; las reglas permanecen independientes del audio.
- Un limitador en Master evita picos de mezcla y no se duplica al repetir.
- 58 comprobaciones de dominio, 30 de recursos, 64 por renderizador/paquete y 6 de exportación, sin fallos. Muestra WAV local y registro de procedencia.
- Esquema, IDs, ubicaciones y objetivos conservados. Escucha humana, touch físico y rendimiento móvil pendientes.

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
