# Organization Hero: 6S Mastery

Juego casual de organización y limpieza en dioramas 3D para Android e iOS, desarrollado con Godot y GDScript tipado. La experiencia relajante y satisfactoria guía el aprendizaje de las 6S mediante acciones.

## Estado al 13 de octubre de 2026

Descubrimiento y planificación inicial documentados. Repositorio local conectado a GitHub. **Todavía no hay un proyecto Godot, escenas jugables ni pruebas del juego.** La Fase 0 continúa con la creación y validación de la base ejecutable; la Fase 1 será el dormitorio completo.

La primera entrega responde al pedido de analizar el prompt maestro y organizar el desarrollo. La instrucción de ejecución del documento adjunto se convierte en la hoja de ruta de las siguientes entregas.

## Documentación

- [Análisis y orquestación](docs/ORCHESTRATION_PLAN.md): alcance, responsabilidades, dependencias y decisiones pendientes.
- [Diseño del juego](docs/GAME_DESIGN_DOCUMENT.md): propuesta concreta del dormitorio.
- [Arquitectura técnica](docs/TECHNICAL_ARCHITECTURE.md): datos, estado, reglas, escenas y servicios.
- [Decisiones técnicas](docs/TECHNICAL_DECISIONS.md): herramientas verificadas y alternativas.
- [Hoja de ruta](docs/DEVELOPMENT_ROADMAP.md): hitos y criterios de cierre.
- [Plan de pruebas](docs/TEST_PLAN.md): cobertura de los 15 criterios del MVP.
- [Historial](docs/CHANGELOG.md): cambios y limitaciones.
- [Prompt maestro original](docs/MASTER_PROMPT.md): fuente de requisitos conservada sin cambios.

## Herramientas verificadas

Godot **4.7.2.stable.official.ed1daf0bf**, plantillas **4.7.2.stable**, VS Code **1.141.0**, Godot Tools **2.7.1**, Git **2.54.0.windows.1**, OpenJDK **17.0.20.1** y Android Platform Tools **37.0.1**.

Mobile será el primer candidato de renderizado para el diorama 3D. La elección definitiva dependerá de comparar una escena representativa con Compatibility. No se ha ejecutado todavía esa comparación.

El equipo disponible es Windows. Matías confirmó que **no dispone todavía de un dispositivo Android**. La preparación de Android puede realizarse aquí; la validación física sigue pendiente. iOS requiere posteriormente macOS con Xcode.

## Control de versiones

Repositorio: [msatelier/ORGANIZATION-HERO_6S-MASTERY](https://github.com/msatelier/ORGANIZATION-HERO_6S-MASTERY).

Origen SSH: `git@github.com:msatelier/ORGANIZATION-HERO_6S-MASTERY.git`.

Trabajar con cambios pequeños, commits coherentes, ramas cortas por hito y revisiones antes de integrar. `main` debe mantener una base comprobada. Los binarios de entrega irán en Releases o artefactos; las claves y los datos locales del jugador quedan fuera del repositorio.

La asociación de este checkout con la clave SSH existente está en su configuración local de Git, no en los archivos versionados. En otra computadora habrá que configurar su propia autenticación.

## Próxima entrega

Crear la base Godot, la habitación geométrica, una cámara orbital y una primera interacción con un objeto. Ejecutar importación y prueba de arranque, comparar renderizadores y registrar resultados. Aún no existe un comando de pruebas del juego ni una escena principal ejecutable.
