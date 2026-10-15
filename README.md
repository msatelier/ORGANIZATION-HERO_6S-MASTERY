# Organization Hero: 6S Mastery

Prototipo jugable **0.2.0** de organización y limpieza con dormitorio y cocina 3D. Godot **4.7.2**, modo Relax, español e inglés. Vista principal vertical para smartphone.

![Cocina al empezar](docs/images/kitchen-before.png)

## Jugar

**Con Godot:** importar `project.godot`, abrir el proyecto y presionar **F5**. La habitación, los objetos y el HUD se generan al ejecutar; la escena de arranque muestra solo el coordinador en el editor.

**Versión Windows local:** ejecutar `build/OrganizationHero.exe`. Mantener `OrganizationHero.pck` en la misma carpeta. Los binarios se generan con el comando de exportación indicado abajo y no se versionan en Git.

- Tocar el nombre de la habitación en el encabezado para abrir «La casa» y elegir dormitorio o cocina. Cada espacio conserva su progreso.
- Arrastrar objetos hacia su destino o tocar primero el objeto y después su lugar: ropa, libros, vajilla, frascos y reciclaje.
- Al seleccionar, los destinos disponibles muestran un borde dorado y sus lugares libres. Un rechazo conserva la selección para volver a intentar. El botón «Cancelar selección» permite salir con mouse o touch.
- Tocar el armario o la alacena para abrirlos. Con un objeto seleccionado, tocar el destino dentro del mueble abierto para guardarlo. La ropa también puede ir al cesto.
- Arrastrar el fondo o usar botón derecho para girar la cámara; rueda para zoom.
- En touch: arrastrar y usar dos contactos para pinza/orbitar.
- Activar el paño y recorrer la mesa del dormitorio o la isla de cocina; el objetivo requiere 85% de cobertura.
- Despejar el paso guardando el peluche o el repasador y tocar el recuerdo dorado de cada habitación.
- Al completar los objetivos obligatorios, revisar la habitación.
- Comparar antes/después o repetir; el coleccionable permanece registrado.

Atajos: **C** paño, **U** deshacer, **Espacio** vista general, **Esc** cancelar/cerrar ajustes o selector. Los ajustes permiten cambiar idioma, volumen, animaciones y vibración opcional.

La ventana Windows abre a **432 × 960**, proporción **9:20**. Se puede redimensionar: cámara, objetivos, controles y ajustes se adaptan. Android se exporta en vertical. La vista horizontal se conserva como alternativa de distribución en Windows y pruebas. [Diseño móvil y música](docs/MOBILE_PRESENTATION.md).

## Qué funciona

Dos habitaciones con ocho objetos cada una: cinco destinos en el dormitorio y seis en la cocina, categorías/capacidad/tolerancia y mueble con puerta animada, dos destinos válidos para ropa, selección/arrastre/colocación con dos toques/cancelación, deshacer organización, limpieza espacial progresiva, riesgo simple de tropiezo, hallazgo oculto, objetivos, pistas que eligen destinos disponibles, resultados con puntuación/estrellas, comparación y repetición. Reducir animaciones afecta objetos, puerta y transición de cámara.

Progreso JSON versionado con temporal y respaldo por habitación bajo `user://`. El dormitorio conserva `progress.json`; la cocina usa `rooms/home_kitchen_01/progress.json`. Ajustes separados y reanudación de la última habitación elegida. Las versiones futuras de progreso se conservan sin sobrescribir. Prendas, medias y peluche con siluetas propias, dormitorio con nuevos detalles y geometría agrupada por material. Sonidos de tela, papel, plástico, objetos blandos y madera; roce del paño según movimiento y silencio al detenerse. Audio sintetizado de desarrollo; sin SDK comerciales.

## Verificación

Desde PowerShell, con Godot 4.7.2 instalado:

```powershell
.\tools\verify.ps1
.\tools\verify.ps1 -Graphics
.\tools\export-prototype.ps1 -Android -Graphics
```

Se puede indicar `-GodotExecutable` si está en otra ruta. Android requiere JDK/SDK, plantillas coincidentes y configuración Android del editor. VS Code incluye configuración para la instalación local; sus rutas se ajustan en otras computadoras. La depuración interactiva de VS Code aún no se verificó.

Resultados de 0.2.0: **58 comprobaciones de reglas**, **31 de recursos/audio**, **26 de habitaciones/guardado**, **44 de distribución**, **65 de interacción del dormitorio** y **38 de cocina/navegación por orientación/renderizador y sobre el paquete**, más **9 de datos exportados**, sin fallos. Se prueba el ciclo completo en 432 × 960 y 960 × 432 con ambos renderizadores. La distribución se revisa también en 450 × 800 y 800 × 600, español/inglés y márgenes seguros simulados. Las pruebas gráficas simulan entrada del motor; no equivalen a touch físico.

El formato de progreso y los IDs del dormitorio siguen en versión 1: las partidas de 0.1.0–0.1.3 continúan siendo compatibles. La cocina tiene un ID y guardado propios; no se migra ni reemplaza el dormitorio.

La música ahora es una composición original de **40 segundos, 96 BPM**, con melodía, bajo, acordes y percusión suave. Está en `assets/audio/bedroom_theme.wav`. Se genera previamente para evitar componer durante el arranque. La verificación genera `build/audio/material-preview.wav` para los efectos. El [registro de recursos](docs/ASSET_REGISTER.md) documenta procedencia y pruebas pendientes.

La conversión de Resources a binario se desactiva porque, en la exportación probada, vaciaba categorías/posiciones. La regresión se comprueba contra el paquete, además de probar desde el editor.

## Entregas y límites

`build/OrganizationHero-debug.apk`: Android ARM64 de depuración, firma v2/v3 verificada, aproximadamente **28.59 MiB**. No se instaló en un teléfono. Ese tamaño no acredita la descarga de una futura AAB comercial.

`build/OrganizationHero.exe` + `.pck`: aproximadamente **100.22 MiB** en conjunto. Ambos archivos deben permanecer juntos. Ciclo completo del paquete comprobado usando el Godot instalado.

Escenario y audio provisionales. Faltan pruebas con jugadores, arte/audio definitivos, mediciones móviles y validación de dispositivos. Matías todavía no dispone de Android. iOS queda pendiente de macOS/Xcode y hardware Apple. No se declaran cumplidos los objetivos móviles de FPS.

## Documentación

- [Informe del primer prototipo](docs/PROTOTYPE_REPORT.md).
- [Arte y sonido](docs/ASSET_REGISTER.md).
- [Diseño](docs/GAME_DESIGN_DOCUMENT.md).
- [Arquitectura](docs/TECHNICAL_ARCHITECTURE.md).
- [Decisiones técnicas](docs/TECHNICAL_DECISIONS.md).
- [Habitaciones y contenido reutilizable](docs/ROOMS_CONTENT.md).
- [Hoja de ruta](docs/DEVELOPMENT_ROADMAP.md).
- [Pruebas y aceptación](docs/TEST_PLAN.md).
- [Análisis inicial](docs/ORCHESTRATION_PLAN.md).
- [Historial](docs/CHANGELOG.md).
- [Prompt original](docs/MASTER_PROMPT.md).

Desarrollo conectado a [GitHub](https://github.com/msatelier/ORGANIZATION-HERO_6S-MASTERY). Primera implementación en `feat/bedroom-vertical-slice`.
