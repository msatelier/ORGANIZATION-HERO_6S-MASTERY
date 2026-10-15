# Informe del prototipo jugable

15 de octubre de 2026. Versión 0.2.0 de desarrollo. Godot 4.7.2.stable.official.ed1daf0bf.

## Entrega

Casa con dormitorio y cocina jugables. El selector se abre tocando el nombre de la habitación o «La casa» en los resultados. Muestra estado y estrellas; permite alternar sin requisitos de desbloqueo. Se recupera la última elección al abrir el juego. [Contenido y ampliación](ROOMS_CONTENT.md).

Cocina: dos tazas, dos platos, frasco, repasador, botella y recetario; seis destinos. Alacena que se abre, isla con limpieza espacial al 85%, paso que despejar y recuerdo propio. Mismo ciclo de objetivos, deshacer, comparación, repetición y estrellas. Baldosas, heladera, fregadero, ventana, plantas y muebles construidos para el nuevo diorama.


Vista principal vertical para smartphone, elegida por Matías: proporción 9:20 y ventana Windows 432 × 960. La interfaz redistribuye objetivos y acciones, la cámara se ajusta al espacio restante y los cuatro bordes respetan zonas seguras. La distribución horizontal se prueba también. [Detalle móvil y música](MOBILE_PRESENTATION.md).

Dormitorio 3D con ocho objetos. Clasificación por categoría, dos destinos válidos para prendas, armario con puerta animada, encaje animado, rechazo, cancelación y deshacer. Cámara orbital limitada, zoom, foco sobre mesa y equivalentes mouse/touch.

Primera mejora artística: prendas/medias con silueta, peluche redondeado, libros con cubiertas, botella etiquetada y hojas con detalles. Cortinas, planta, lámpara, manta y alfombra enriquecen el diorama. Geometría agrupada por material sin fusionar las partes que deben moverse o interactuar por separado.

Se puede arrastrar o seleccionar con un toque/clic y tocar/clicar después el destino. Los lugares disponibles muestran borde y capacidad restante. Preview y colocación usan la misma validación de categoría, apertura, capacidad y orientación. Un rechazo conserva selección para reintentar; cancelar la limpia con botón contextual o Esc. Las pistas eligen un destino disponible antes de sugerir abrir el armario.

El punto de agarre se conserva durante el arrastre; un botón ajeno no termina el gesto. Agarrar un objeto en animación lo detiene hasta soltarlo o cancelar. Reducir animaciones afecta objetos, puerta y transición de cámara.

Limpieza real mediante máscara CPU de 64 × 40, textura RGBA y shader sencillo. El trazo interpola zonas recorridas y cuenta celdas distintas; repetir un punto no aumenta cobertura. Umbral en datos: 85%.

Guardar el peluche despeja el paso y revela el coleccionable. Objetivos y estado 6S derivados, pistas, inspección final, puntuación, dos estrellas por completar y tercera por el hallazgo opcional. Las estrellas no bloquean progreso.

Guardado y repetición con hallazgo conservado. Antes/después reconstruye representación inicial/final sin mutar progreso. Localización nativa español/inglés y ajustes de audio, animaciones y háptica opcional.

Cinco perfiles sonoros (tela, papel, plástico, blando y madera), tres variantes por perfil, armario con apertura/cierre diferentes y hallazgo/final. La música sustituye el acorde sostenido: melodía original de 40 segundos a 96 BPM, con bajo, arpegios y percusión suave, preparada previamente. Roce continuo del paño por velocidad, desvanecimiento al detenerse y salida al cancelar. El limitador del mix permanece único al repetir. Valoración de la nueva música y ASMR definitivo pendientes de escucha humana. [Registro de recursos](ASSET_REGISTER.md).

![Cocina inicial](images/kitchen-before.png)

![Cocina terminada](images/kitchen-after.png)

![Dormitorio inicial](images/bedroom-before.png)

![Estado final](images/bedroom-after.png)

![Selección y destino disponible](images/bedroom-selection.png)

## Integración

Entrada en scenes/app/main.tscn. GameRoot conserva las sesiones, cámara, HUD y audio; reemplaza vista/controlador al cambiar de habitación. RoomCatalog registra bedroom.tres y kitchen.tres, sus vistas y rutas. Nueve tipos de Resource. GameSession mantiene estado/objetivos; PlacementRules valida encaje; SaveStore persiste por IDs.

No hay autoloads. Los servicios viven en la escena. Mobiliario/HUD se generan por código al ejecutar; RoomView comparte presentación de tareas/objetos, BedroomView/KitchenView aportan decoración, ItemVisuals construye modelos y MeshBatcher agrupa geometría. Edición visual y refinamiento artístico siguen por mejorar.

La máscara se actualiza cuando cambia cobertura o vista antes/después, una vez por frame de presentación. Otros cambios de estado no repintan suciedad ni reinician una animación cuyo destino sigue siendo el mismo. Guardado al terminar el trazo, en acciones discretas y al suspender/cerrar. Deshacer afecta organización en la sesión y conserva hallazgos; su historial no se persiste.

Esquema de progreso y versiones de contenido siguen en 1. El dormitorio conserva IDs, posiciones y user://progress.json, sin migración desde 0.1.x. Cocina usa user://rooms/home_kitchen_01/progress.json con respaldo independiente; settings.cfg recuerda la elección. El ciclo de cocina comprueba que los bytes del dormitorio no cambian. ItemData declara sound_profile; el contexto de acciones llega a GameRoot y FeedbackManager sin introducir reglas de audio en la sesión.

## Evidencia ejecutada

| Comprobación | Resultado |
| --- | --- |
| Importación/análisis y arranque | Sin errores |
| Copia sin caché ni traducciones binarias | Importa y arranca en 0.2.0 |
| Reglas, estado y persistencia | 58 comprobaciones, 0 fallos |
| Geometría y PCM | 31 comprobaciones, 0 fallos |
| Habitaciones / aislamiento / compatibilidad | 26 comprobaciones, 0 fallos |
| Distribución / idiomas / márgenes / selector | 44 comprobaciones, 0 fallos |
| Entrada/UI con Mobile | 65 comprobaciones por orientación, 0 fallos |
| Mismo ciclo con Compatibility | 65 comprobaciones por orientación, 0 fallos |
| Cocina / navegación con ambos renderizadores | 38 comprobaciones por orientación/renderizador, 0 fallos |
| Ciclos con recursos del PCK exportado | 65 dormitorio + 38 cocina por orientación, 0 fallos |
| Datos/localización/música del paquete | 9 comprobaciones, 0 fallos |
| Ejecutable Windows independiente | Arranque headless sin errores |
| APK Android ARM64 debug | Exportación y firma v2/v3 verificadas |
| Android físico | Pendiente: no hay dispositivo |
| iOS | Pendiente |
| Usabilidad y escucha con jugadores | Pendientes |

La entrada usa Input.parse_input_event: arrastre inválido/válido, colocación con dos toques, rechazo de destino lleno, pistas disponibles, deshacer, touch cancelado, agarre y botón de finalización, ajustes táctiles, animación/reducción, contenedor, pinza, clasificación, hallazgo, barrido de limpieza, persistencia, resultados, comparación y repetición. Las imágenes vienen del viewport real.

PC: NVIDIA GeForce RTX 4050 Laptop GPU. Mobile: Vulkan 1.4.325; Compatibility: OpenGL 3.3, controlador NVIDIA 592.82. Ciclos en 432 × 960 y 960 × 432. Distribución comprobada además en 450 × 800 y 800 × 600, dos idiomas y márgenes seguros simulados. No son un emulador de S20 ni demuestran FPS móviles. Los contadores de dibujo de versiones anteriores pertenecen a otro encuadre y resolución.

## Exportaciones

Windows: OrganizationHero.exe + OrganizationHero.pck separados, alrededor de 100.22 MiB en conjunto. Ambos deben permanecer juntos.

Android: OrganizationHero-debug.apk, alrededor de 28.59 MiB. Identificador com.msatelier.organizationhero.prototype, versión 0.2.0 (código 5), orientación portrait, mínimo declarado API 24 y objetivo API 36. El mínimo declarado no certifica soporte gráfico en todos esos dispositivos. Permiso normal de vibración; sin Internet solicitado por el preset.

APK sin prueba física, firma comercial ni AAB para tienda. El peso del archivo no equivale a descarga comercial distribuida. Los binarios y registros quedan en build, excluido de Git.

## Problemas detectados y resueltos

- Objeto oculto detrás del escritorio: reubicado y comprobado.
- Tipos inválidos en progreso: validación previa y recuperación probadas.
- Traducciones de texto cargadas antes de los loaders: registro nativo después de inicialización, desde Resources versionados.
- Conversión binaria vaciaba categorías y slots en esta exportación: desactivada y cubierta por prueba del paquete; causa interna del motor no determinada.
- PCK incrustado provocaba bloqueo de Application Control: exportación estándar con binario del motor sin modificar y datos separados; arrancó con la política existente.
- Referencia de audio retenida en salida automática headless: audio desactivado en esa prueba y parada explícita al cerrar.
- Selección cancelada retenía guías; se limpia junto con el estado del gesto.
- Cualquier botón de mouse podía terminar un arrastre; ahora solo el que lo inició.
- Pequeño desplazamiento al agarrar durante un retorno animado; animación pausada desde el contacto inicial y agarre comprobado.
- Colisión amplia del mueble abierto interceptaba toques sobre sus destinos: ahora la colocación seleccionada tiene prioridad.
- Selector oculto adquiría una altura mínima excesiva: texto de dos líneas y límites comprobados en cuatro tamaños.
- El resultado horizontal cubría parte del acceso superior: «La casa» está también disponible en los resultados.

## Pendientes y próximo hito

Ajustar selección, tolerancias y ayudas con uso humano; evaluar la nueva música, reconocimiento de formas y comodidad; revisar interfaces en tamaños físicos. Gestos y zonas seguras implementados y simulados, todavía sin validación en teléfono.

Solo existe esquema 1: versiones desconocidas protegidas, sin migraciones históricas todavía. Hay un catálogo doméstico de dos habitaciones, sin mapa de campaña ni desbloqueos. No hay galería independiente, modo Desafío completo, anuncios, compras, nube ni SQLite.

Dos habitaciones completas en vista vertical, con distribución adaptable, navegación y progreso independiente. Aceptación móvil y refinamiento comercial abiertos. Próximo trabajo: devolución de Matías sobre destinos/selector, luego baño, sala y garaje conforme a M5; mediciones Android cuando haya dispositivo.
