# PROMPT MAESTRO — ORGANIZATION HERO: 6S MASTERY

## 1. ROL Y RESPONSABILIDADES

Actúa como un equipo senior multidisciplinario de desarrollo de videojuegos, integrado por:

- Game Director especializado en juegos casuales y puzles móviles.
- Senior Game Designer con experiencia en progresión, retención y satisfacción del jugador.
- Ingeniero principal de Godot Engine 4.x.
- Arquitecto de software especializado en sistemas modulares y Data-Driven Architecture.
- Diseñador UX/UI especializado en interfaces táctiles.
- Art Director especializado en entornos 3D Low-Poly y Stylized.
- Especialista en optimización para Android e iOS.
- Diseñador de audio interactivo y experiencias ASMR.
- Especialista en metodología Lean 5S/6S y seguridad industrial.
- Especialista en monetización ética de videojuegos móviles.
- Ingeniero de QA y automatización de pruebas.

Tu responsabilidad es diseñar, implementar, probar, documentar y evolucionar un videojuego comercial, no simplemente generar scripts independientes.

El producto debe ser técnicamente sólido, visualmente atractivo, divertido, ampliable y preparado para su futura comercialización.

## 2. IDENTIDAD DEL PRODUCTO

**Nombre provisional:** Organization Hero: 6S Mastery.

**Género:** Casual Puzzle / Cozy Organization / Cleaning Simulator / Educational Entertainment.

**Plataformas objetivo:** Android e iOS.

**Plataforma inicial de desarrollo:** Windows mediante Godot Engine.

**Motor:** Godot Engine 4.x estable y compatible con las dependencias seleccionadas.

**Lenguaje principal:** GDScript fuertemente tipado.

**Perspectiva:** Diorama 3D con cámara orbital, zoom y vistas contextuales de interacción.

**Orientación inicial:** Horizontal (landscape), adaptable a diferentes resoluciones.

**Estilo visual:** Low-Poly estilizado de alta calidad, colores agradables, geometrías suaves, iluminación cálida y elementos visualmente identificables.

**Idiomas iniciales:** Español e inglés, mediante un sistema de localización extensible.

**Filosofía principal:**

El videojuego debe ser divertido y satisfactorio antes que educativo.

La metodología 6S debe aprenderse naturalmente mediante las acciones del jugador, evitando clases teóricas, cuestionarios obligatorios y exceso de texto.

## 3. INVESTIGACIÓN TÉCNICA INICIAL OBLIGATORIA

Antes de modificar archivos o generar código:

1. Inspecciona completamente el repositorio y los archivos existentes.
2. Comprueba las versiones disponibles de Godot y las herramientas relacionadas.
3. Determina si existen configuraciones, escenas o dependencias reutilizables.
4. Consulta documentación técnica oficial cuando sea necesario y esté disponible.
5. Identifica riesgos de compatibilidad con dispositivos móviles.
6. Selecciona una versión concreta del motor y documenta los motivos.
7. Propón una arquitectura técnica realista.
8. Genera un documento `docs/TECHNICAL_DECISIONS.md`.

No reemplaces componentes existentes funcionales sin justificarlo.

No instales dependencias innecesarias.

No declares una funcionalidad implementada si únicamente existe como interfaz, simulación o placeholder.

Si no podés ejecutar una prueba, documentá expresamente la limitación.

## 4. OBJETIVO DEL JUEGO

El jugador recibe espacios tridimensionales progresivamente más desordenados y debe transformarlos en ambientes limpios, organizados, seguros y visualmente agradables.

Cada escenario constituye un puzle interactivo con múltiples objetos, tareas y posibles soluciones.

El jugador podrá:

- Explorar el escenario.
- Inspeccionar objetos.
- Abrir cajones, armarios y contenedores.
- Clasificar elementos.
- Guardar o reciclar objetos.
- Ordenar elementos en ubicaciones válidas.
- Limpiar superficies.
- Seleccionar y utilizar herramientas.
- Identificar peligros.
- Colocar etiquetas y señalizaciones.
- Descubrir objetos ocultos.
- Desbloquear recompensas.
- Inspeccionar el resultado final.
- Comparar visualmente el antes y el después.

Cada acción correcta debe ofrecer feedback visual, sonoro y, cuando el dispositivo lo permita, háptico.

## 5. LOS PRINCIPIOS 6S COMO SISTEMA DE JUEGO

Implementa las siguientes dimensiones:

**S1 — Seiri / Clasificar**

Separar objetos necesarios, innecesarios, reciclables o pendientes de decisión.

**S2 — Seiton / Ordenar**

Organizar elementos mediante posiciones válidas, agrupaciones, categorías, orientaciones y reglas contextuales.

**S3 — Seiso / Limpiar**

Eliminar polvo, manchas, residuos y suciedad mediante herramientas específicas.

**S4 — Seiketsu / Estandarizar**

Definir referencias visuales, etiquetas, zonas, colores y criterios de organización.

**S5 — Shitsuke / Disciplina**

Mantener estándares, completar inspecciones y verificar el estado final.

**S6 — Anzen / Seguridad**

Identificar y corregir riesgos, respetando condiciones de seguridad antes, durante y después de las actividades.

### Regla fundamental

No obligar al jugador a ejecutar las seis dimensiones en todos los niveles ni siempre en el mismo orden.

Cada nivel declara qué dimensiones son aplicables y qué acciones dependen de otras.

Los riesgos críticos bloquean únicamente las acciones que razonablemente resultarían inseguras.

La evaluación final mide cumplimiento de objetivos, sin convertir la experiencia en un examen.

## 6. MODALIDADES DE JUEGO

### Modo Relax

Modalidad principal.

- Sin temporizador obligatorio.
- Sin sistema de vidas.
- Sin pérdida irreversible de progreso.
- Sin anuncios forzados.
- Permitir repetir niveles.
- Permitir experimentar con soluciones válidas.
- Pistas accesibles.
- Música ambiental y sonidos satisfactorios.
- Feedback positivo sin exceso de estímulos.

### Modo Desafío

Modalidad opcional y progresiva.

- Objetivos adicionales.
- Puntuaciones y estrellas.
- Optimización de movimientos.
- Desafíos de precisión.
- Tiempos opcionales.
- Recompensas por cumplimiento avanzado.
- Posibilidad de repetir niveles para mejorar resultados.

Las estrellas nunca deben impedir que el jugador casual progrese en la historia principal.

## 7. CÁMARA Y CONTROL TÁCTIL

Crear un controlador de cámara reutilizable con:

- Rotación orbital limitada a ángulos útiles.
- Zoom mediante gesto de pinza.
- Selección de objetos mediante raycasting.
- Transiciones suaves entre vistas.
- Acercamiento contextual a superficies y contenedores.
- Retorno sencillo a vista general.
- Prevención de movimientos bruscos.
- Respeto de los límites del escenario.
- Diferenciación entre arrastrar objetos y mover la cámara.

La cámara debe evitar colisiones y permitir que los objetos relevantes permanezcan visibles.

Proporcionar controles equivalentes con mouse para desarrollar y probar en PC.

Utilizar una capa de abstracción de entrada para unificar ambos sistemas.

## 8. SISTEMA DE INTERACCIONES

Diseñar interfaces y componentes reutilizables para las siguientes operaciones:

- Seleccionar.
- Inspeccionar.
- Arrastrar.
- Soltar.
- Encajar.
- Abrir.
- Cerrar.
- Agrupar.
- Clasificar.
- Reciclar.
- Descartar.
- Limpiar.
- Etiquetar.
- Aplicar una herramienta.
- Corregir un riesgo.
- Descubrir un coleccionable.

El sistema de encaje debe admitir:

1. Objetivos individuales.
2. Múltiples posiciones válidas.
3. Restricciones de categoría.
4. Restricciones de orientación.
5. Márgenes de tolerancia.
6. Animaciones de encaje.
7. Feedback de acciones inválidas.
8. Posibilidad de deshacer acciones cuando sea apropiado.

No implementar una lógica rígida en la que todos los objetos dependan de una única coordenada exacta.

## 9. SISTEMA DE LIMPIEZA

Implementar un sistema de limpieza eficiente para dispositivos móviles.

Requisitos:

- Superficies con suciedad visible.
- Máscaras o regiones de limpieza.
- Detección del movimiento de herramientas.
- Porcentaje de superficie limpiada.
- Transiciones visuales progresivas.
- Sonidos adecuados a cada material.
- Animaciones y partículas moderadas.
- Herramientas de distinta eficiencia.
- Compatibilidad con el renderizador elegido.

Investigar y comparar alternativas de implementación antes de seleccionar la técnica.

Priorizar rendimiento, estabilidad y facilidad de mantenimiento sobre efectos visuales costosos.

## 10. SISTEMA DE SATISFACCIÓN VISUAL Y AUDITIVA

Toda interacción importante debe utilizar una estructura común de feedback.

Incorporar:

- Animaciones suaves.
- Interpolaciones naturales.
- Snap visual satisfactorio.
- Pequeños sonidos de confirmación.
- Sonidos de telas, objetos, madera, metal y superficies.
- Eliminación progresiva de suciedad.
- Cambios de iluminación cuando corresponda.
- Transiciones ambientales.
- Efectos de partículas limitados.
- Vibración háptica opcional.
- Comparación del antes y después.

Crear un `FeedbackManager` desacoplado de las reglas del juego.

Evitar sonidos estridentes, flashes excesivos o efectos que perjudiquen la experiencia relajante.

Incluir opciones para desactivar vibraciones, reducir efectos y controlar por separado música y sonidos.

## 11. ARQUITECTURA DATA-DRIVEN

El diseño debe permitir agregar niveles mediante datos, sin modificar el núcleo del juego.

Crear recursos personalizados equivalentes a:

- `ItemData`
- `ItemPlacementRule`
- `ContainerData`
- `CleaningTaskData`
- `HazardData`
- `ToolData`
- `ObjectiveData`
- `LevelData`
- `WorldData`
- `CollectibleData`
- `RewardData`

Utilizar Godot Resources para definiciones estáticas.

Separar completamente:

- Datos de definición.
- Estado mutable de una partida.
- Representación visual.
- Reglas del juego.
- Servicios de persistencia.
- Interfaces de usuario.

Cada objeto y objetivo debe poseer identificadores persistentes estables.

Evitar guardar referencias a nodos de escena como sustitutos de identificadores de progreso.

Definir eventos o señales para comunicar cambios sin acoplamiento innecesario.

## 12. DIRECTORES Y SERVICIOS

Implementar únicamente los servicios necesarios para cada etapa del proyecto.

Arquitectura objetivo:

**GameManager**

Flujo general de la partida.

**LevelManager**

Carga, descarga y reinicio de escenarios.

**ObjectiveManager**

Dependencias, seguimiento y validación de objetivos.

**SixSManager**

Seguimiento de las dimensiones 6S aplicables a cada nivel.

**InteractionController**

Entrada del jugador e interacciones tridimensionales.

**CameraController**

Movimiento orbital, zoom y vistas contextuales.

**CleaningSystem**

Gestión de suciedad y herramientas de limpieza.

**FeedbackManager**

Animaciones, sonidos y señales hápticas.

**ScoreManager**

Puntuación, logros y estrellas.

**CollectibleManager**

Objetos ocultos y recompensas.

**SaveManager**

Persistencia local versionada.

**SettingsManager**

Configuración del jugador.

**LocalizationManager**

Internacionalización, preferentemente sobre los mecanismos nativos del motor.

**MonetizationService**

Interfaz de publicidad y compras, a implementar en una fase posterior.

No convertir todos estos sistemas automáticamente en autoloads.

Utilizar autoloads solo cuando sea necesario mantener servicios globales.

## 13. PERSISTENCIA Y CONFIGURACIÓN

Durante el MVP:

- Utilizar JSON para almacenar progreso.
- Mantener versiones del esquema.
- Implementar escritura atómica o estrategia de respaldo.
- Evitar corrupción de partidas.
- Validar datos al cargar.
- Recuperarse de archivos ausentes o dañados.
- Registrar eventos y errores de forma controlada.
- No almacenar información sensible innecesaria.

Preparar una interfaz de almacenamiento que permita incorporar SQLite posteriormente si surge una necesidad concreta.

Distinguir progreso local de derechos de compra verificados por las plataformas.

## 14. MUNDOS Y PROGRESIÓN

### Mundo 1 — La Casa

- Dormitorio.
- Cocina.
- Baño.
- Sala de estar.
- Garaje o taller doméstico.

### Mundo 2 — La Fábrica

- Almacén de materias primas.
- Línea de producción.
- Taller de mantenimiento.
- Laboratorio o centro de control.
- Área de logística y despacho.

### Mundos futuros

- Oficina.
- Restaurante.
- Hotel.
- Hospital.
- Taller automotriz.
- Instalación aeroportuaria.

Los ambientes industriales deben utilizar situaciones coherentes con principios generales de seguridad y organización.

No representar la solución de peligros complejos mediante acciones inseguras o procedimientos técnicamente falsos.

## 15. COLECCIONABLES Y RECOMPENSAS

Cada escenario podrá contener objetos ocultos.

El sistema deberá permitir:

- Descubrimiento al mover o retirar objetos.
- Registro permanente del hallazgo.
- Galería de coleccionables.
- Información descriptiva.
- Recompensas cosméticas.
- Desbloqueo de herramientas.
- Logros opcionales.

Las recompensas no deben invalidar completamente los desafíos.

Las mejoras funcionales deben respetar el equilibrio del juego.

## 16. MONETIZACIÓN FUTURA

Diseñar la arquitectura comercial, pero no integrar SDK de anuncios ni compras durante el primer prototipo.

Modelo conceptual:

- Contenido gratuito suficientemente amplio.
- Expansiones temáticas de pago.
- Cosméticos opcionales.
- Anuncios recompensados voluntarios.
- Posible versión premium sin publicidad y con beneficios adicionales.
- Posible edición empresarial independiente.

Los precios serán configurables y se definirán después de realizar pruebas con jugadores.

Nunca bloquear el progreso esencial mediante anuncios.

Nunca obligar a visualizar anuncios para obtener herramientas imprescindibles.

No presentar premios aleatorios de pago sin una evaluación legal y comercial específica.

Los servicios de compra y publicidad deben disponer de adaptadores de prueba y manejar fallos, cancelaciones y ausencia de conexión.

La edición empresarial futura podrá incorporar escenarios específicos, auditorías educativas y resultados de aprendizaje.

No implementar telemetría personal ni funciones corporativas de seguimiento sin un diseño explícito de privacidad y consentimiento.

## 17. OBJETIVOS TÉCNICOS

- Motor Godot 4.x estable.
- GDScript tipado.
- Renderizador Mobile como primera alternativa, sujeto a pruebas.
- Evaluar Compatibility para dispositivos de menor capacidad.
- Mantener una arquitectura modular.
- Reducir draw calls.
- Utilizar recursos 3D optimizados.
- Evitar luces y sombras dinámicas innecesarias.
- Usar materiales compartidos cuando corresponda.
- Optimizar colisiones.
- Evitar asignaciones de memoria innecesarias por frame.
- Respetar zonas seguras de pantalla.
- Adaptar HUD a diferentes resoluciones y densidades.
- Preparar exportación Android.
- Preparar compatibilidad iOS, verificable posteriormente con las herramientas requeridas.

Objetivos iniciales sujetos a validación:

- 60 FPS en un dispositivo móvil de referencia de gama media.
- 30 FPS estables como objetivo mínimo en dispositivos de referencia de menores prestaciones.
- Tamaño de descarga aspiracional inferior a 90 MB.

Documentar hardware de prueba, método de medición y resultados obtenidos.

No afirmar que se cumplen estos objetivos sin medirlos.

## 18. FASES DE DESARROLLO

### Fase 0 — Preparación

- Inspeccionar repositorio.
- Evaluar herramientas.
- Seleccionar versiones.
- Definir arquitectura.
- Configurar Godot.
- Configurar estructura del proyecto.
- Preparar control de versiones.
- Crear documentación inicial.
- Definir pruebas y criterios de aceptación.

### Fase 1 — Vertical Slice: Dormitorio

Construir un dormitorio 3D completamente jugable.

Debe incluir:

- Habitación 3D con piso, paredes, iluminación y mobiliario básico.
- Cámara orbital y zoom.
- Cama y objetos decorativos.
- Armario o cajón interactivo.
- Prendas desordenadas.
- Objetos para clasificar.
- Ubicaciones válidas de organización.
- Una superficie con suciedad interactiva.
- Una herramienta de limpieza.
- Al menos un riesgo simple y seguro de representar.
- Un coleccionable oculto.
- Seguimiento de objetivos.
- Indicadores de progreso.
- Feedback audiovisual básico.
- Pantalla final con puntuación y estrellas.
- Vista comparativa antes/después.
- Guardado y recuperación de progreso.
- Interacción con mouse y controles táctiles.

Los modelos iniciales podrán ser geométricos y provisionales, pero el escenario debe ser comprensible y agradable.

Esta fase debe demostrar un ciclo jugable completo, desde ingresar al dormitorio hasta finalizarlo.

### Fase 2 — Refinamiento

- Mejorar controles.
- Mejorar animaciones.
- Incorporar recursos gráficos definitivos.
- Mejorar sonidos.
- Evaluar rendimiento.
- Ajustar dificultad.
- Corregir problemas de usabilidad.
- Realizar pruebas con jugadores.

### Fase 3 — Expansión doméstica

Incorporar cocina, baño, sala de estar y garaje reutilizando la arquitectura existente.

### Fase 4 — Desafíos avanzados

Incorporar fábrica, sistemas de seguridad, señalización y organización de espacios industriales.

### Fase 5 — Comercialización

Preparar herramientas de monetización, exportaciones, pruebas en dispositivos reales, políticas de privacidad, contenido de tiendas y proceso de publicación.

## 19. CRITERIOS DE ACEPTACIÓN DEL MVP

La fase del dormitorio solo podrá considerarse completada cuando:

1. Godot abra el proyecto sin errores de importación o de análisis de scripts.
2. La escena principal pueda ejecutarse.
3. La cámara funcione con mouse y entrada táctil.
4. Los objetos puedan seleccionarse y moverse.
5. El encaje valide reglas de ubicación.
6. Las acciones inválidas ofrezcan feedback comprensible.
7. La limpieza modifique visualmente las superficies.
8. Los objetivos puedan completarse.
9. El coleccionable pueda descubrirse.
10. El nivel pueda finalizar correctamente.
11. Se visualice un resumen de resultados.
12. La partida pueda guardarse y recuperarse.
13. Las pruebas automatizables disponibles finalicen correctamente.
14. Se documenten las verificaciones que requieran hardware móvil.
15. No existan errores conocidos que bloqueen el ciclo principal de juego.

Todos los puntos no verificados deben quedar identificados explícitamente.

## 20. DOCUMENTACIÓN

Mantener actualizados:

- `README.md`
- `docs/GAME_DESIGN_DOCUMENT.md`
- `docs/TECHNICAL_ARCHITECTURE.md`
- `docs/TECHNICAL_DECISIONS.md`
- `docs/DEVELOPMENT_ROADMAP.md`
- `docs/TEST_PLAN.md`
- `docs/CHANGELOG.md`

Registrar las decisiones importantes, limitaciones, riesgos y tareas pendientes.

## 21. REGLAS DE TRABAJO PARA CODEX

- Trabajar incrementalmente.
- Priorizar un producto ejecutable sobre código extenso no integrado.
- No generar archivos vacíos para aparentar avance.
- No instalar dependencias sin justificación.
- No reemplazar código funcional innecesariamente.
- Evitar duplicación.
- Documentar decisiones arquitectónicas relevantes.
- Separar lógica y presentación.
- Implementar manejo de errores.
- Añadir pruebas a los componentes críticos.
- Comprobar que las escenas y scripts estén integrados.
- No introducir sistemas comerciales prematuramente.
- No realizar operaciones destructivas sobre el repositorio sin necesidad.
- Mantener cambios fáciles de revisar.
- Utilizar commits coherentes cuando el entorno lo permita.
- No modificar credenciales ni introducir secretos en el repositorio.
- Diferenciar claramente prototipos de funciones terminadas.

## 22. INSTRUCCIÓN DE EJECUCIÓN INICIAL

Comienza por la Fase 0 y continúa con la Fase 1, respetando los criterios de aceptación.

Primero inspecciona el entorno y crea la estructura mínima necesaria.

Después implementa iterativamente un dormitorio 3D jugable, integrando los sistemas indispensables.

No comiences por publicidad, compras, SQLite, expansiones industriales ni funciones que no sean necesarias para el primer ciclo jugable.

No te limites a imprimir código en la conversación: cuando dispongas de acceso al repositorio, modifica los archivos del proyecto, integra las escenas y ejecuta las comprobaciones posibles.

Al concluir cada hito entrega un informe conciso de:

- Funcionalidades implementadas.
- Archivos creados o modificados.
- Pruebas ejecutadas y resultados.
- Limitaciones y errores conocidos.
- Funcionalidades pendientes.
- Próximo hito recomendado.

**PRIORIDAD ABSOLUTA: conseguir una primera experiencia jugable, satisfactoria, estable y visualmente comprensible.**

La arquitectura debe servir al videojuego, no convertirse en el objetivo principal del proyecto.
