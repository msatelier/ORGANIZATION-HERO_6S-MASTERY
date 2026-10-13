# Análisis y orquestación del proyecto

Fecha: 13 de octubre de 2026. Este documento registra el análisis previo. El estado actual está en [PROTOTYPE_REPORT.md](PROTOTYPE_REPORT.md).

## Evaluación del prompt maestro

El documento define un producto coherente: organización satisfactoria en 3D, experiencia Relax como centro, aprendizaje 6S por acciones y arquitectura ampliable. Sus mejores decisiones son permitir varias soluciones válidas, no imponer las seis dimensiones en todos los niveles, evitar monetización temprana y exigir evidencia antes de declarar una función terminada.

Sirve como visión y contrato de calidad. Para ejecutar el proyecto necesita convertirse en tareas pequeñas, decisiones explícitas y entregas jugables. Enumerar once especialidades y catorce servicios no determina todavía el orden de construcción ni justifica implementar todos esos sistemas.

La primera solicitud fue de análisis y organización. La documentación y Git se prepararon en esa entrega; Matías autorizó después comenzar la creación y ya existe un primer ciclo jugable de escritorio.

## Aspectos que debemos concretar

| Tema del prompt | Interpretación de trabajo | Evidencia necesaria |
| --- | --- | --- |
| «Divertido y satisfactorio» | Manipular, ordenar y limpiar debe resultar comprensible y agradable | Observación de jugadores y ajustes de controles |
| Diorama orbital táctil | Diseñar la elección entre objeto, cámara y herramienta antes del contenido | Prueba de selección, arrastre, zoom y cancelación |
| Múltiples soluciones | Categorías, capacidad, orientación y tolerancias declaradas en datos | Dos destinos válidos y rechazo explicable de uno inválido |
| Limpieza progresiva | La huella de la herramienta modifica áreas realmente recorridas | Cobertura persistente, resultado visual y coste medido |
| Dimensiones 6S | Objetivos con etiquetas 6S; dependencias solo donde sean necesarias | Un objetivo independiente sigue disponible ante otro bloqueado |
| Seguridad | Riesgo doméstico sencillo; evitar enseñar procedimientos industriales falsos | Revisión del escenario y prueba del bloqueo específico |
| Disciplina | Inspección y comprobación final de estándares | Acciones y condiciones verificables, sin examen teórico |
| Data-driven | Definiciones de nivel separadas de reglas y estado | Crear una variante de contenido sin modificar el núcleo |
| Estrellas y Relax | Resumen y logros opcionales, sin bloquear historia | Finalización válida incluso con desempeño básico |
| 60/30 FPS y menos de 90 MB | Metas de producto pendientes de medición | Dispositivo, condiciones, tiempos de frame y descarga documentados |

## Alcance de la primera experiencia

La primera experiencia es un único dormitorio, con una sesión corta y un ciclo completo: entrar, explorar, clasificar, ordenar, limpiar, corregir un riesgo sencillo, encontrar un coleccionable y finalizar. Incluye guardado, reanudación, resultados, opciones esenciales y comparación antes/después.

Propuesta inicial para controlar el alcance: 8 a 12 objetos movibles, tres categorías, un contenedor que se abre, varias ubicaciones válidas, una superficie sucia, una herramienta, un riesgo y un coleccionable. Una sesión de 5 a 10 minutos es una hipótesis de diseño que ajustaremos con pruebas; no una duración demostrada.

Las dimensiones centrales propuestas son S1, S2, S3 y S6. La inspección final puede introducir S5; S4 se incorporará cuando una tarea de etiquetas o referencias visuales aporte algo al puzle. No forzaremos seis ejercicios artificiales en el dormitorio.

Quedan para después: fábrica, cuatro habitaciones domésticas adicionales, catálogo de herramientas, campaña amplia, retos cronometrados completos, tienda, SDK comerciales, SQLite, nube y edición empresarial. La puntuación básica del resumen sí pertenece al dormitorio; el modo Desafío completo es posterior.

## Responsabilidades y herramientas

| Responsable o herramienta | Responsabilidad |
| --- | --- |
| Matías, responsable del producto | Prioridades, dirección visual, sensación de juego, valoración de cada demostración y decisiones comerciales |
| Codex, coordinación e implementación | Descomponer requisitos, desarrollar, integrar, verificar, documentar y comunicar el estado real |
| Godot | Escenas, recursos, importación, ejecución, perfilado y exportación |
| VS Code | Edición de GDScript, búsqueda, revisión y depuración configurada |
| Git y GitHub | Historial, ramas, revisiones, tareas y entregas recuperables |

Las especialidades del prompt se aplicarán como revisiones concretas. Diseño y UX revisan la interacción; ingeniería revisa reglas y persistencia; arte y audio revisan claridad y satisfacción; QA revisa los criterios de aceptación. La revisión de seguridad industrial se vuelve más exigente al incorporar la fábrica. No equivale a contar ya con once profesionales ni a certificar formación industrial.

## Secuencia de ejecución

1. **Descubrimiento y base:** entorno, versión, decisiones, documentación, proyecto mínimo que abra y arranque.
2. **Prueba de interacción:** habitación geométrica, cámara, selección, arrastre, encaje, rechazo, cancelación y destino alternativo.
3. **Núcleo del puzle:** clasificación, contenedor, limpieza, riesgo sencillo, objetivos y hallazgo oculto.
4. **Ciclo completo:** finalización, resumen, antes/después, guardado/reanudación, opciones y localización.
5. **Validación y refinamiento:** errores, controles, arte, audio, APK, mediciones y pruebas con jugadores.
6. **Expansión:** cocina primero para probar reutilización; luego baño, sala y garaje. La fábrica sucede a la consolidación doméstica.
7. **Comercialización:** adaptadores, pruebas de fallos, firma, tiendas y documentación comercial cuando el juego esté validado.

Dependencia principal: entrada y cámara → manipulación → reglas y objetivos → progreso y resultados → refinamiento → expansión. La identidad visual puede investigarse mientras avanza la base, pero la producción masiva de modelos espera a que escala, encuadre y destinos funcionen.

## Cómo se gestiona cada hito

Cada tarea debe indicar el comportamiento esperado, los archivos o módulos afectados, sus dependencias y una prueba observable. «Crear sistema de limpieza» se descompone, por ejemplo, en mapear la herramienta a la superficie, modificar cobertura, representar el cambio y restaurarlo desde un guardado.

Trabajaremos por funcionalidad integrada. Un hito se cierra con una demostración y un informe de qué funciona, qué pruebas pasaron, qué quedó sin verificar y cuál es el siguiente paso. Un menú o un botón aislado no acredita una mecánica. Un proceso que arranca sin ventana no acredita controles, sonido ni calidad visual.

Estados de trabajo: propuesto, preparado para implementar, en curso, por verificar y completado. Una verificación dependiente de hardware se conserva como pendiente explícito. Los informes diferencian implementado, comprobado y pendiente; el avance no se medirá por cantidad de archivos.

GitHub Issues y milestones son la organización propuesta del backlog. Todavía no se han creado issues, milestones, protección de ramas ni flujos de CI. La hoja de ruta local contiene el backlog inicial y evita duplicar tareas antes de empezar la implementación.

## Flujo local y GitHub

La carpeta de trabajo es `C:\Users\Matia\OneDrive\Documentos\Juegos\ORGANIZATION-HERO_6S-MASTERY`. El repositorio remoto es `git@github.com:msatelier/ORGANIZATION-HERO_6S-MASTERY.git`, con rama inicial `main`. Es público según la consulta inicial de GitHub.

La primera documentación establece la base en `main`. Para implementar utilizaremos ramas cortas por hito, por ejemplo `feat/bedroom-interaction`, y commits pequeños. Los cambios deben ser reproducibles desde el repositorio antes de integrarse. Un PR agrupa una entrega comprensible; cada hito jugable puede tener una etiqueta de versión y un binario de prueba asociado.

Se versionan escenas, scripts, Resources, fuentes de arte/audio y documentación. Se excluyen la caché `.godot`, exportaciones, registros, partidas de usuario y credenciales. Los archivos `.uid` y los descriptores `.import` se conservan cuando existan. Git LFS se evaluará si el tamaño real de los recursos lo justifica; no se instala por anticipado.

OneDrive sincroniza archivos, mientras que Git registra versiones revisables. Para evitar conflictos durante importaciones y edición, este checkout tendrá una sola sesión de trabajo activa. Si aparecieran conflictos de sincronización o bloqueo, se evaluará mover la copia activa fuera de OneDrive conservando el historial y una copia de respaldo. No se ha realizado ese traslado.

## Riesgos y mitigación

| Riesgo | Respuesta |
| --- | --- |
| Construir demasiados sistemas antes de jugar | Entregar primero una interacción completa y añadir servicios por necesidad |
| Confusión entre arrastre, cámara y limpieza | Estados de entrada explícitos y prueba temprana de cancelación y multitáctil |
| Cámara oculta objetos o destinos | Limitar órbita, ajustar geometría y usar acercamientos contextuales |
| Limpieza vistosa pero cara o poco precisa | Comparar técnicas en una superficie real y medir coste y cobertura |
| Guardado pierde objetos o corrompe progreso | IDs estables, validación, respaldo, migraciones y pruebas de recuperación |
| Calidad móvil inferida desde una PC potente | Medir en teléfonos y documentar hardware; nunca extrapolar FPS |
| Nueva habitación exige reescribir el motor | Validar una variante de nivel y después la cocina con el mismo núcleo |
| Arte o audio sin derechos claros | Registrar autoría, fuente y licencia desde que se incorporan |
| iOS se descubre tarde | Mantener diseño portable y planificar macOS/Xcode antes de cerrar la producción |

## Decisiones pendientes

Matías confirmó que todavía no tiene un dispositivo Android. Se puede crear y exportar la APK en Windows; no se puede cerrar ahora la validación del rendimiento ni de los gestos en hardware real. Un emulador puede ayudar con resoluciones, ciclo de vida y flujo, pero no sustituye la prueba física de GPU, temperatura, batería, latencia o háptica. No se ha instalado un emulador.

Quedan por definir con evidencia: teléfono de referencia, cobertura mínima de dispositivos, presupuesto de arte/audio, estilo final, requisitos mínimos de sistema y acceso posterior a una Mac. Estas decisiones no impiden comenzar la base en Windows.

No fijaremos una fecha comercial a partir de una lista de requisitos. La primera interacción y el dormitorio completo permitirán estimar el ritmo, los costes de contenido y el calendario de los siguientes mundos.
