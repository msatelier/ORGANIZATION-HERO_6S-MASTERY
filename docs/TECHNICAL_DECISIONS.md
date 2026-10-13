# Decisiones técnicas y auditoría inicial

Fecha: 13 de octubre de 2026. Los resultados de entorno no acreditan ninguna función del juego.

## Inspección del repositorio

La carpeta local estaba vacía. Se consultó el repositorio remoto y se clonó: `main`, commit inicial `666b2eff5435f5320aaf133d71c96fc2e3801442`, único archivo `README.md` con el nombre del repositorio. No había proyecto Godot, escenas, dependencias ni código para reutilizar. No se encontraron instrucciones AGENTS.md en el checkout ni en los directorios ancestros comprobados.

GitHub devolvió permisos de lectura/escritura/administración y visibilidad pública. No se modificaron permisos, visibilidad ni configuración remota.

## Herramientas comprobadas

| Herramienta | Resultado actual | Método |
| --- | --- | --- |
| Godot | `4.7.2.stable.official.ed1daf0bf` | Ejecutable instalado, `--headless --version` |
| Plantillas | `4.7.2.stable`; Windows, Android e iOS presentes | Archivo version.txt e inventario |
| VS Code | 1.141.0 | Información de versión y package.json de la instalación |
| Godot Tools | 2.7.1 | Carpeta de extensión instalada |
| Git | 2.54.0.windows.1 | `git --version` |
| Java | Temurin OpenJDK 17.0.20.1 | `java -version` |
| ADB | Platform Tools 37.0.1 | `adb version` |
| Android Platforms | API 35 y 36 | Directorios del SDK |
| Android Build Tools | 35.0.1, 36.0.0 y 36.1.0 | Directorios del SDK |

Godot está en `C:\Dev\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe`, con ejecutable de consola equivalente. Java y Android SDK están bajo `C:\Dev\GameDevelopment\Tools`. Las plantillas están en `%APPDATA%\Godot\export_templates\4.7.2.stable`.

La sesión de terminal no heredaba todas las herramientas en PATH; se comprobaron mediante sus rutas existentes. El comando de versión de VS Code mostró la versión, pero también una restricción de cambio de directorio en el entorno aislado. Se confirmó la versión leyendo el metadato instalado. No se comprobó en esta entrega la depuración interactiva ni el autocompletado.

Un informe local de instalación previo se utilizó para localizar herramientas. Sus pruebas sobre otro proyecto no se trasladan a Organization Hero. Esta auditoría volvió a comprobar las versiones y archivos indicados.

## D-001: fijar Godot 4.7.2 estándar

Decisión: usar Godot 4.7.2 estable con GDScript tipado y plantillas exactamente coincidentes. El motor ya está instalado, su versión fue ejecutada y el [archivo oficial de versiones](https://godotengine.org/download/archive/) identifica 4.7.2 como estable.

No se instala .NET ni se adopta una versión de desarrollo. Una actualización futura necesita revisar cambios y repetir importación, arranque, pruebas críticas y exportaciones en una rama. El archivo de versión del proyecto se añadirá al crear la base Godot.

## D-002: Mobile como candidato, decisión final pendiente

Mobile se prueba primero para el diorama 3D. Compatibility se compara sobre la misma escena y queda como alternativa para mayor cobertura de hardware. La [documentación de renderizadores 4.7](https://docs.godotengine.org/en/4.7/tutorials/rendering/renderers.html) distingue sus requisitos y advierte diferencias al cambiar entre ellos.

Evitar inicialmente efectos exclusivos de un renderizador: materiales sencillos, iluminación moderada y ninguna dependencia de compute para la limpieza. Medir arranque, tiempos de frame, memoria y claridad visual con acciones reales. La PC verifica funcionamiento; elegir definitivamente la cobertura móvil requiere teléfono de referencia.

Resultado actual: no existe escena representativa ni benchmark. No hay renderizador configurado todavía en este repositorio.

## D-003: Resources estáticos y sesión mutable separada

Definiciones editables en el inspector mediante Resources; estado de partida separado y serialización explícita por ID. No introducir base de datos durante el MVP. La [guía de objetos y Resources](https://docs.godotengine.org/en/stable/tutorials/best_practices/node_alternatives.html) fundamenta el uso de estructuras ligeras y datos serializables.

Implementar recursos por necesidad y no todos los gestores como autoloads. Los objetivos son la fuente del cumplimiento 6S, con métricas derivadas.

## D-004: comparar limpieza antes de comprometer el sistema

| Técnica | Ventajas esperadas | Costes o riesgos a probar | Decisión |
| --- | --- | --- | --- |
| Regiones/celdas con transición de material | Fácil de guardar, medir y depurar | Bordes visibles, exceso de nodos si se subdivide demasiado | Referencia simple para validar reglas |
| Máscara CPU pequeña + ImageTexture + material | Trazo espacial, cobertura determinista, compatible con diseño sencillo | Actualizaciones de textura, resolución y suavizado | Primera candidata del dormitorio |
| Máscara acumulada con SubViewport | Trazos suaves y producción visual en GPU | Render extra, memoria, precisión y persistencia | Alternativa si mejora el resultado medido |
| Compute o técnicas dependientes de funciones avanzadas | Potencial de efectos complejos | Cobertura de renderizadores, complejidad y mantenimiento | Fuera del primer prototipo |

Comparación pendiente: misma superficie y trayectoria, tiempo de actualización, frame time, memoria, calidad visual y capacidad de recuperar cobertura desde el guardado. La selección inicial es una hipótesis técnica, no un rendimiento demostrado.

Referencias: [ImageTexture 4.7](https://docs.godotengine.org/en/4.7/classes/class_imagetexture.html), [SubViewport como textura](https://docs.godotengine.org/en/stable/tutorials/shaders/using_viewport_as_texture.html).

## D-005: persistencia JSON versionada y recuperable

Usar `user://` para progreso, separar ajustes y conservar respaldo. Validar tipos, IDs y versiones. Ensayar interrupción y reemplazo de archivos; no asumir idénticas garantías de renombrado en Windows y móvil. Definir migración de contenido además del esquema. SQLite solo se evaluará ante un problema concreto que JSON no resuelva.

## D-006: pruebas críticas sin dependencias prematuras

Empezar con pruebas GDScript ejecutables en modo headless para reglas, dependencias e integridad de guardados, con salida no cero ante fallo. Añadir un framework únicamente si mejora de manera concreta las pruebas necesarias. Las pruebas visuales, de audio y de gestos son independientes de ese proceso.

La [referencia de SceneTree](https://docs.godotengine.org/en/4.7/classes/class_scenetree.html) permite un runner sencillo; todavía no se ha creado ni ejecutado.

## D-007: Android temprano, iOS condicionado al entorno

Reutilizar JDK 17 y SDK instalados. La [guía Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) describe configuración, firma y AAB. Crear una APK de depuración tan pronto exista una escena ejecutable y no reservar exportación para el final. Los requisitos vigentes de tiendas y SDK se revisarán de nuevo antes de publicación.

Matías confirmó que todavía no dispone de Android. Exportación, pruebas de escritorio y eventualmente emulación son posibles; tacto, háptica, GPU móvil y rendimiento sostenido quedan pendientes. No se generó APK ni AAB de este juego.

iOS requiere exportar desde macOS con Xcode, según la [guía iOS 4.7](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_ios.html). Tener la plantilla iOS en Windows no elimina ese requisito. El simulador iOS admite Compatibility; la ruta Mobile deberá probarse en hardware Apple compatible.

## D-008: autenticación SSH existente, asociada solo a este checkout

La URL canónica inicialmente rechazó autenticación porque la configuración existente asociaba la clave de msatelier al alias `github-msatelier`. Se verificó acceso con esa misma clave mediante selección explícita; después se clonó la URL solicitada.

Este checkout tiene un core.sshCommand local que selecciona la clave existente y mantiene verificación de host y modo no interactivo. No se editó la clave, no se mostró su contenido y no se cambió la configuración SSH global. La ruta privada no está en archivos versionados. Se conserva el remoto canónico solicitado.

## Límites de esta entrega

Verificados: lectura del prompt completo, contenido inicial del repositorio, herramientas indicadas, lectura SSH y clonación. Documentación y configuración de Git preparadas. No verificados: apertura de un proyecto de este juego, importación, scripts, controles, arte, limpieza, guardado, exportación, FPS, tamaño o iOS. Los resultados de sincronización de la documentación se registran en el historial.
