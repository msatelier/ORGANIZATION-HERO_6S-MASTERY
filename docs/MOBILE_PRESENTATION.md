# Presentación móvil y música — 0.1.3

14 de octubre de 2026. Matías pidió sustituir el ambiente y trabajar con una pantalla de smartphone; eligió vertical como orientación principal. Esta preferencia actualiza la orientación horizontal inicial del prompt maestro, que se conserva intacto como referencia.

## Pantalla

Samsung declara una pantalla de 3200 × 1440 para el [Galaxy S20](https://www.samsung.com/us/business/support/owners/product/galaxy-s20-5g-at-t/). De esas dimensiones se deriva la proporción vertical 9:20. La ventana de desarrollo es 432 × 960, con esa misma relación; no emula el hardware, la densidad física ni el sistema Android de un S20.

Godot usa base lógica cuadrada 480 × 480, canvas_items y aspecto expand. Esto permite ajustar ambas orientaciones conservando proporciones, siguiendo la [guía de resoluciones de Godot](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html). Android queda fijado en portrait. Windows puede redimensionarse y probar la distribución horizontal.

En vertical, objetivos y acciones quedan abajo. En horizontal se agrupan a la derecha con textos compactos. La habitación se encuadra en el espacio restante; el zoom se calcula respecto a ese encuadre y se conserva durante cambios de tamaño. Los controles de acción tienen al menos 56 unidades de altura; encabezado y ajustes, al menos 48. Los ajustes pueden desplazarse en pantallas cortas y mantienen visible el botón Cerrar.

La zona segura incluye los cuatro bordes. En Android se convierten los márgenes físicos a coordenadas lógicas. Cambiar el tamaño cancela gestos pendientes. Los eventos de prueba se convierten a píxeles de ventana antes de entrar al motor, para comprobar el escalado real y la emulación táctil.

## Música

Composición original, 96 BPM, compás 4/4, 16 compases y 40 segundos. Melodía de notas cortas, acordes arpegiados, bajo y percusión suave. Sustituye el acorde sostenido de 0.1.2. Se busca un carácter ligero y de juego; la valoración de diversión/relajación queda a la escucha del jugador.

Fuente editable: scripts/systems/music_composer.gd. Generador: tools/bake-music.gd. Archivo integrado: assets/audio/bedroom_theme.wav, PCM mono 16 bits a 22.05 kHz, sin normalización ni compresión del importador, bucle completo. El clip se prepara previamente; el juego solo lo carga y reproduce por Music. Mantiene control de volumen, desvanecimiento inicial, suspensión y limitador de mezcla.

Para reconstruirlo: ejecutar Godot con --headless --path . --script tools/bake-music.gd y volver a importar. Se versionan el generador, WAV e instrucciones de importación. No se incorporó música de terceros.

## Evidencia

- 36 comprobaciones de distribución: 432 × 960, 450 × 800, 960 × 432 y 800 × 600; español/inglés, encuadre, controles y márgenes seguros simulados.
- Ciclo completo: 65 comprobaciones por tamaño 432 × 960 / 960 × 432 en Mobile y Compatibility; repetido en el PCK exportado con Mobile.
- PCM, duración de la composición y bucle comprobados en la fuente; formato y bucle comprobados también en el paquete.
- Capturas de viewport real del PCK. Prueba física de Android, comodidad táctil, audio en teléfono y FPS móviles pendientes.
