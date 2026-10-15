# Plan de pruebas y aceptación

Actualización: 15 de octubre de 2026. Prototipo 0.2.0 verificado. [Informe y evidencias](PROTOTYPE_REPORT.md): 58 comprobaciones de reglas, 31 de recursos, 26 de habitaciones/guardado, 44 de distribución, 65 de integración del dormitorio y 38 de cocina/navegación por orientación/renderizador y sobre paquete, 9 de datos exportados. Hardware móvil pendiente.

## Niveles de verificación

1. Entorno: versiones, repositorio y acceso. Comprobado en esta entrega.
2. Importación/arranque: proyecto, copia limpia y paquete ejecutan sin errores. Comprobado.
3. Reglas automatizadas: ubicación, objetivos, dependencias, riesgos y persistencia. Comprobadas.
4. Integración: ciclo completo con renderizado y eventos mouse/touch simulados comprobado. Usabilidad y escucha humanas pendientes.
5. Móvil real: tacto, ciclo de vida, háptica, rendimiento y estabilidad sostenida. Pendiente; Matías no dispone aún de Android.

La exportación correcta no prueba experiencia ni rendimiento. La ejecución headless no prueba rendering, gestos ni sonido. Una prueba con mouse no acredita una prueba con touch.

## Matriz de los 15 criterios del prompt

| Nº | Criterio | Verificación prevista | Estado |
| --- | --- | --- | --- |
| 1 | Proyecto abre sin errores | Importación limpia y análisis de scripts | Verificado, también en copia sin caché |
| 2 | Escena principal ejecuta | Arranque headless y arranque gráfico | Verificado desde fuente, paquete y ejecutable |
| 3 | Cámara con mouse y touch | Órbita, pinza, límites, transición y retorno | Simulación verificada; touch físico pendiente |
| 4 | Seleccionar y mover | Arrastre, dos toques, cancelación, UI y selección con oclusión | Verificado por entrada y revisión visual en PC |
| 5 | Encaje valida reglas | Categoría, capacidad, orientación, tolerancia y destinos alternativos | Verificado por reglas e integración |
| 6 | Acción inválida comprensible | Motivo correcto y estado sin corrupción | Feedback/estado verificados; comprensión humana pendiente |
| 7 | Limpieza modifica superficie | Trayectoria, cobertura distinta, bordes y visual | Verificado en ambos renderizadores y paquete |
| 8 | Objetivos completables | Dependencias válidas, acciones independientes y final | Verificado |
| 9 | Coleccionable descubrible | Ocultación, hallazgo, duplicados y persistencia | Verificado, incluido repetir nivel |
| 10 | Nivel finaliza | Condiciones obligatorias satisfechas, un solo cierre | Verificado |
| 11 | Resumen visible | Resultados coherentes, repetición y estrellas sin bloqueo | Verificado y capturado |
| 12 | Guardar y recuperar | Reinicio, respaldo, corrupción, IDs y versiones | JSON y recuperación verificados; suspensión física pendiente |
| 13 | Pruebas automatizables pasan | Runner con errores detectables y salida no cero | Verificado con scripts reproducibles |
| 14 | Documentar hardware pendiente | Dispositivo Android ausente registrado; plan de medición definido | Limitación documentada; pruebas físicas pendientes |
| 15 | Sin bloqueos del ciclo | Recorrido completo y seguimiento de defectos | Sin bloqueos en recorridos automatizados de PC; hardware pendiente |

## Casos críticos de reglas

- Dos ubicaciones aceptan el mismo objeto cuando sus categorías/reglas lo permiten.
- Un destino ocupado o contenedor cerrado rechaza sin perder ni duplicar el objeto.
- Cancelar arrastre o perder foco restaura el estado previo.
- Selección con dos toques/clics usa las mismas reglas, conserva selección si se rechaza y la limpia al confirmar/cancelar.
- Un destino con objetos colocados sigue recibiendo el toque; lleno, cerrado o de otra categoría se comunica correctamente.
- Un botón ajeno no termina el gesto activo; el objeto conserva el punto de agarre, incluso si estaba volviendo con animación.
- Las pistas prefieren destinos disponibles y la reducción de animaciones aplica también a puerta/cámara.
- Un objetivo dependiente espera; otro independiente permanece accionable.
- Se detectan IDs duplicados, referencias desconocidas y ciclos de objetivos.
- Resolver un riesgo cambia las condiciones pertinentes; no completa tareas ajenas.
- Cubrir dos veces la misma celda de limpieza no duplica el área limpia.
- No pueden quedar zonas necesarias físicamente inaccesibles a la herramienta.
- Descubrir el coleccionable repetidamente no concede recompensas duplicadas.
- Completar sin logros opcionales permite avanzar en Relax.

## Persistencia

Probar archivo ausente, JSON truncado, tipos inválidos, versión antigua migrable, versión futura no soportada, ID retirado y datos parcialmente recuperables. Probar fallo de escritura y recuperación desde respaldo sin sobrescribir una versión desconocida.

Guardar a mitad de limpieza y a mitad del nivel, cerrar, abrir y comparar los estados lógicos. Al restaurar, validar también presentación, ubicación de objetos, contenedor y hallazgos. Ensayar suspensión móvil en cuanto exista una build y dispositivo.

## Experiencia en Windows

Recorrer inicio, cámara, manipulación, herramienta, objetivos, hallazgo y resumen con mouse. Revisar que HUD consuma su entrada y las transiciones no disparen acciones accidentales. Ensayar relaciones de aspecto horizontal distintas, textos español/inglés, escala, zonas seguras y controles accesibles.

Revisar audio por buses, reducción de efectos y comparación antes/después con encuadre coincidente. Solicitar a jugadores que realicen tareas sin explicarles la solución; registrar confusión, errores de gesto y tiempo para entender la acción siguiente. Son observaciones locales, sin telemetría personal incorporada.

0.1.2 verifica selección del perfil sonoro por objeto y apertura/cierre, roce al moverse, silencio al detener/cancelar, volumen de efectos a cero y limitador único después de repetir. La revisión de capturas comprueba las nuevas siluetas y que decoración/agrupado no oculten objetos jugables. La validación PCM de formato, amplitud, media y uniones no demuestra calidad percibida ni comodidad auditiva.

## Protocolo móvil y rendimiento

Cuando haya hardware: registrar modelo, SoC/GPU, RAM, sistema, versión del juego, renderizador, resolución, escala 3D, modo de energía y condiciones de prueba. Ejecutar el mismo recorrido después de calentamiento y durante una sesión sostenida para observar degradación térmica.

Medir tiempos de frame y percentiles, CPU/GPU cuando las herramientas lo permitan, memoria y cierres inesperados. Separar arranque/importación, interacción, limpieza y pantalla final. Metas del prompt: 60 FPS en gama media y 30 FPS estables en menor capacidad, pendientes de dispositivos y mediciones.

El tamaño aspiracional menor a 90 MB se refiere a descarga; distinguir APK de prueba, AAB, descarga distribuida e instalación. No usar el peso de una carpeta fuente como evidencia.

No hay Android disponible. No se comprobó iOS. El simulador o el escritorio pueden descubrir defectos de flujo, pero no acreditan rendimiento en hardware móvil.

## Automatización y trazabilidad

Runner GDScript implementado: tests/domain_tests.gd y tests/asset_tests.gd para headless, tests/interaction_smoke.gd para ventana real. tests/export_data_tests.gd verifica datos del paquete. tools/verify.ps1 y tools/export-prototype.ps1 comprueban salida y errores de registros. No se usa un framework adicional. GitHub Actions puede importar/analizar y ejecutar esas pruebas con Godot 4.7.2 fijado. No existe aún workflow de CI.

0.1.3: tests/layout_tests.gd verifica límites, superposiciones, tamaños táctiles, encuadre y márgenes simulados en cuatro tamaños y dos idiomas. verify.ps1 -Graphics recorre vertical/horizontal con Mobile y Compatibility. export-prototype.ps1 -Graphics recorre ambas orientaciones del PCK. Los recorridos usan guardados aislados; no reemplazan la partida del jugador. La música se comprueba también después de importar/exportar el WAV.

Registrar cada resultado con commit, prueba, plataforma, resultado, evidencia y defecto asociado. Solo marcar «verificado» lo efectivamente ejecutado. La lista de pendientes no bloquea el avance de tareas independientes, pero debe acompañar la entrega.

## Ampliación doméstica 0.2.0

rooms_tests.gd comprueba la definición completa de cocina, solución con reglas compartidas, guardados independientes, compatibilidad del archivo histórico del dormitorio, respaldo propio, aislamiento de versiones futuras y textos de contenido en ambos idiomas.

interaction_smoke.gd --test-room=kitchen comienza con progreso parcial en dormitorio, abre el selector mediante entrada, visita cocina, coloca ocho objetos mediante toques, limpia la isla, descubre su recuerdo y completa con tres estrellas. Comprueba antes/después, cambio entre ambas sesiones, bytes del guardado anterior, cierre/reapertura con última habitación y repetición exclusiva de cocina. También comprueba continuidad del reproductor de música y limitador único. verify.ps1 -Graphics ejecuta ambos recorridos en Mobile/Compatibility y dos tamaños; export-prototype.ps1 -Graphics los repite sobre PCK con Mobile.

layout_tests.gd incluye el selector, su botón de acceso y opciones táctiles. Una prueba detectó un tamaño mínimo incorrecto del panel oculto debido al texto ajustable; el texto de introducción usa dos líneas definidas y el panel se verifica incluso con márgenes simulados.
