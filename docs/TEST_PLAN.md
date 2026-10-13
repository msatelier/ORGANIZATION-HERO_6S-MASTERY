# Plan de pruebas y aceptación

Fecha: 13 de octubre de 2026. Estado actual: planificación; no existe código del juego ni pruebas ejecutadas sobre él.

## Niveles de verificación

1. Entorno: versiones, repositorio y acceso. Comprobado en esta entrega.
2. Importación/arranque: proyecto abre, scripts analizan, escena ejecuta. Pendiente.
3. Reglas automatizadas: ubicación, objetivos, dependencias, riesgos y persistencia. Pendiente.
4. Integración y experiencia: controles, cámara, visuales, audio y ciclo completo. Pendiente.
5. Móvil real: tacto, ciclo de vida, háptica, rendimiento y estabilidad sostenida. Pendiente; Matías no dispone aún de Android.

La exportación correcta no prueba experiencia ni rendimiento. La ejecución headless no prueba rendering, gestos ni sonido. Una prueba con mouse no acredita una prueba con touch.

## Matriz de los 15 criterios del prompt

| Nº | Criterio | Verificación prevista | Estado |
| --- | --- | --- | --- |
| 1 | Proyecto abre sin errores | Importación limpia y análisis de scripts | Pendiente |
| 2 | Escena principal ejecuta | Arranque headless y arranque gráfico | Pendiente |
| 3 | Cámara con mouse y touch | Órbita, pinza, límites, transición y retorno | Pendiente; touch físico sin hardware |
| 4 | Seleccionar y mover | Arrastre, cancelación, UI y selección con oclusión | Pendiente |
| 5 | Encaje valida reglas | Categoría, capacidad, orientación, tolerancia y destinos alternativos | Pendiente |
| 6 | Acción inválida comprensible | Motivo correcto y estado sin corrupción | Pendiente |
| 7 | Limpieza modifica superficie | Trayectoria, cobertura distinta, bordes y visual | Pendiente |
| 8 | Objetivos completables | Dependencias válidas, acciones independientes y final | Pendiente |
| 9 | Coleccionable descubrible | Ocultación, hallazgo, duplicados y persistencia | Pendiente |
| 10 | Nivel finaliza | Condiciones obligatorias satisfechas, un solo cierre | Pendiente |
| 11 | Resumen visible | Resultados coherentes, repetición y estrellas sin bloqueo | Pendiente |
| 12 | Guardar y recuperar | Reinicio, respaldo, corrupción, IDs y versiones | Pendiente |
| 13 | Pruebas automatizables pasan | Runner con errores detectables y salida no cero | Pendiente |
| 14 | Documentar hardware pendiente | Dispositivo Android ausente registrado; plan de medición definido | Limitación documentada; pruebas físicas pendientes |
| 15 | Sin bloqueos del ciclo | Recorrido completo y seguimiento de defectos | Pendiente |

## Casos críticos de reglas

- Dos ubicaciones aceptan el mismo objeto cuando sus categorías/reglas lo permiten.
- Un destino ocupado o contenedor cerrado rechaza sin perder ni duplicar el objeto.
- Cancelar arrastre o perder foco restaura el estado previo.
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

## Protocolo móvil y rendimiento

Cuando haya hardware: registrar modelo, SoC/GPU, RAM, sistema, versión del juego, renderizador, resolución, escala 3D, modo de energía y condiciones de prueba. Ejecutar el mismo recorrido después de calentamiento y durante una sesión sostenida para observar degradación térmica.

Medir tiempos de frame y percentiles, CPU/GPU cuando las herramientas lo permitan, memoria y cierres inesperados. Separar arranque/importación, interacción, limpieza y pantalla final. Metas del prompt: 60 FPS en gama media y 30 FPS estables en menor capacidad, pendientes de dispositivos y mediciones.

El tamaño aspiracional menor a 90 MB se refiere a descarga; distinguir APK de prueba, AAB, descarga distribuida e instalación. No usar el peso de una carpeta fuente como evidencia.

No hay Android disponible. No se comprobó iOS. El simulador o el escritorio pueden descubrir defectos de flujo, pero no acreditan rendimiento en hardware móvil.

## Automatización y trazabilidad

Runner inicial previsto en GDScript headless, sin framework obligatorio. Automatizar validadores, reglas, progresión y persistencia; documentar el comando, código de salida y registros cuando se implemente. GitHub Actions puede importar/analizar y ejecutar esas pruebas con Godot 4.7.2 fijado. No existe aún workflow de CI.

Registrar cada resultado con commit, prueba, plataforma, resultado, evidencia y defecto asociado. Solo marcar «verificado» lo efectivamente ejecutado. La lista de pendientes no bloquea el avance de tareas independientes, pero debe acompañar la entrega.
