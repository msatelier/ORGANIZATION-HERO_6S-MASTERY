# Hoja de ruta y backlog inicial

Fecha: 13 de octubre de 2026. Actualizada tras el primer prototipo. Hitos por resultado; sin calendario comercial comprometido.

| Hito | Fase del prompt | Resultado | Estado |
| --- | --- | --- | --- |
| M0: preparación y base | 0 | Entorno auditado, plan y proyecto mínimo que abre/arranca | Base Windows completada; copia limpia verificada |
| M1: interacción fundamental | 1 | Cámara, objeto y destinos con reglas | Comprobado en PC; touch físico pendiente |
| M2: tareas del dormitorio | 1 | Clasificación, contenedor, limpieza, seguridad y coleccionable | Implementado y comprobado en PC |
| M3: ciclo completo | 1 | Objetivos, final, resumen, antes/después y reanudación | Prototipo completo comprobado desde fuente y paquete |
| M4: calidad y validación | 2 y cierre de 1 | Controles refinados, presentación y evidencia móvil | Pendiente; sin dispositivo Android |
| M5: casa ampliada | 3 | Cocina reutilizable, luego otros tres escenarios | Pendiente |
| M6: fábrica y retos | 4 | Escenarios industriales y desafío opcional | Pendiente |
| M7: comercialización | 5 | Servicios comerciales y entregas para tiendas | Pendiente |

## M0 — Preparación y base ejecutable

Realizado: auditoría, planificación, base ejecutable, importación limpia, comparación funcional de renderizadores y exportaciones. [Informe de implementación](PROTOTYPE_REPORT.md).

Trabajo realizado para la base:

- Crear project.godot y fijar versión del motor.
- Escena de arranque y dormitorio geométrico con materiales legibles.
- Configuración horizontal, escala de UI y entrada mouse/touch prevista.
- Configuración de edición y verificación reutilizable sin rutas de credenciales.
- Importar y arrancar sin errores; registrar resultado.
- Primera comparación Mobile/Compatibility y exportación Windows/Android de prueba cuando la escena esté lista.

Cierre: una copia limpia del repositorio permite abrir y arrancar el proyecto; README explica el procedimiento y sus límites. La documentación por sí sola no completa M0.

## M1 — Cámara y manipulación

- Órbita limitada, zoom y retorno a vista general.
- Selección por raycast y diferenciación objeto/fondo/UI.
- Arrastre con vista provisional, cancelación y soltado coherentes.
- Encaje por categoría, capacidad, orientación y tolerancia.
- Dos destinos válidos y uno inválido con motivo comprensible.
- Abrir/cerrar un contenedor y respetar sus condiciones de acceso.

Cierre: una demostración permite manipular y organizar sin mover accidentalmente la cámara; rechazo y cancelación conservan el estado. Mouse comprobado; gestos físicos documentados como pendientes hasta disponer de hardware.

## M2 — Acciones del puzle

- Clasificación con estados definidos y reversibilidad apropiada.
- Elegir técnica de limpieza tras comparación.
- Una herramienta que limpia zonas recorridas, con progreso visual real.
- Riesgo doméstico de tropiezo y corrección por reubicación.
- Hallazgo oculto que se descubre al cambiar la visibilidad.
- Feedback común de acciones válidas, inválidas y completadas.

Cierre: cada acción modifica estado, representación y objetivos previstos. Frotar el mismo punto no acredita cobertura adicional inexistente; el riesgo solo limita acciones relacionadas.

## M3 — Partida completa y recuperación

- Evaluar objetivos y dependencias desde el estado de sesión.
- HUD y pistas esenciales, localización español/inglés.
- Finalización válida, resumen con puntuación y estrellas opcionales.
- Comparación antes/después y repetición del dormitorio.
- Guardado versionado y reanudación, incluidos contenedor, limpieza y hallazgos.
- Pruebas de corrupción, archivo ausente, versión no soportada y respaldo.
- Ajustes de música/efectos, háptica y reducción de efectos.

Cierre: completar de principio a fin, reiniciar la aplicación y recuperar progreso coherente; pruebas críticas pasan. Las limitaciones de hardware permanecen visibles.

## M4 — Refinamiento y evidencia

- Sustituir recursos provisionales prioritarios con autoría/licencia registrada.
- Ajustar controles, animaciones, iluminación, audio y claridad de tareas.
- Probar con jugadores y corregir bloqueos de comprensión.
- APK de depuración, instalación y ciclo de vida en teléfono cuando esté disponible.
- Medir frame times, memoria, estabilidad sostenida y tamaño de entrega.
- Revisar los 15 criterios del MVP y cerrar o registrar cada pendiente.

Una versión de escritorio jugable puede entregarse antes de contar con Android. La aceptación móvil queda abierta: no se declararán 60/30 FPS ni calidad táctil con una medición de PC. No está disponible ahora un dispositivo Android.

## M5 — Expansión doméstica

Crear primero una variante de datos y luego cocina para comprobar reutilización. Incorporar baño, sala y garaje después de validar el coste por nivel. Separar las tareas comunes de aquellas que requieran una herramienta o regla realmente nueva.

Cierre por escenario: ciclo completo, recursos integrados, objetivos declarados, guardado compatible y pruebas de regresión relevantes. No producir cuatro niveles sobre contratos todavía inestables.

## M6 — Fábrica y desafío

Almacén, producción, mantenimiento, control y logística con reglas contextuales de organización y seguridad. Revisar coherencia de peligros y procedimientos. Incorporar señalización y estándares de manera jugable. El modo Desafío añade objetivos, precisión y tiempos opcionales sin restringir la historia Relax.

## M7 — Comercialización

Seleccionar modelo y proveedores después de validar la experiencia. Implementar adaptadores comerciales, simulación de fallos/cancelaciones/offline y separación entre progreso y derechos de compra. Preparar firma comercial, builds release, políticas y fichas de tiendas.

Para iOS: acceso a macOS/Xcode, firma, exportación y pruebas Apple. Para Android: teléfono, mediciones y proceso release. Las cuentas, recursos comerciales y requisitos actuales de tiendas se concretarán en esta etapa.

## Informe de cierre por hito

Cada entrega identifica comportamiento implementado, archivos afectados, pruebas y resultados, errores conocidos, comprobaciones pendientes y próximo hito. La estimación de fechas se revisa tras M1 y M3 con el ritmo real de implementación y contenido.
