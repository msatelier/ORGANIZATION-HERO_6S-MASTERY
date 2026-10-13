# Arquitectura técnica propuesta

Fecha: 13 de octubre de 2026. Diseño objetivo, todavía sin implementación.

## Capas y autoridad del estado

| Capa | Responsabilidad | Representación prevista |
| --- | --- | --- |
| Definiciones | Objetos, categorías, reglas, tareas, objetivos y nivel | Resources `.tres` con IDs estables |
| Estado de sesión | Ubicaciones, clasificación, apertura, cobertura, objetivos y hallazgos | Objetos de estado tipados; serialización explícita |
| Reglas | Validar acciones y evaluar condiciones/dependencias | Clases pequeñas que pueden probarse sin representación 3D |
| Presentación | Diorama, animaciones, sonido, HUD y efectos | Escenas y componentes Godot |
| Servicios | Guardar, configurar y cambiar niveles | Persistencia y coordinadores con alcance definido |

Las definiciones se tratan como inmutables durante una partida. No se guarda progreso mutando un Resource compartido. La sesión mantiene la verdad del nivel y los objetivos se evalúan desde ella. El progreso 6S se deriva de los objetivos aplicables para evitar contadores contradictorios.

Se permiten referencias a nodos para colaborar durante la ejecución; no se serializan como identidad de objetos o progreso. Los guardados utilizan IDs explícitos, no NodePath, orden de hijos ni direcciones de memoria.

## Flujo de una acción

Entrada → intención de InteractionController → validación de reglas y riesgos → aplicación a la sesión → señales de cambio → representación, objetivos y feedback → solicitud de guardado.

Durante un arrastre, la posición visible es provisional. El estado solo cambia al confirmar una acción válida. Cancelar recupera la ubicación anterior. La comprobación de ocupación y la aplicación del encaje suceden como una operación coherente; dos acciones no pueden ocupar un mismo hueco exclusivo.

Un rechazo comunica una causa concreta: categoría, capacidad, orientación, contenedor cerrado o riesgo. FeedbackManager presenta el resultado y nunca concede objetivos por su cuenta.

## Recursos por etapa

Para interacción: ItemData, ItemPlacementRule y un LevelData mínimo. Para completar el dormitorio: ContainerData, CleaningTaskData, HazardData, ToolData, ObjectiveData y CollectibleData. WorldData y RewardData se incorporan cuando exista una pantalla de mundos o una recompensa con comportamiento real.

No se crearán clases vacías para adelantar el catálogo objetivo. Cada recurso debe tener un consumidor y validación. Los IDs, destinos y dependencias tendrán validadores de duplicados, referencias inexistentes y ciclos.

ObjectiveData expresa condición, dimensión 6S, obligatoriedad y dependencias. Las dependencias son un grafo dirigido sin ciclos. Un riesgo añade precondiciones a las acciones afectadas, sin bloquear arbitrariamente el nivel completo.

## Componentes y alcance

El flujo de aplicación y la carga de niveles pueden comenzar en un coordinador pequeño y separarse si aparecen responsabilidades distintas. InteractionController, CameraController, evaluación de objetivos y CleaningSystem viven en la sesión o escena del nivel.

FeedbackManager puede comenzar como un componente de escena. SaveManager y SettingsManager solo serán autoloads si deben sobrevivir a cambios de escena. No se vuelve global cada nombre que enumera el prompt. Se usa la localización nativa de Godot; un LocalizationManager adicional necesita una función que el motor no cubra.

ScoreManager y CollectibleManager se añaden cuando el resumen y los hallazgos lo requieran. El seguimiento 6S puede ser una proyección del evaluador de objetivos sin un singleton separado. MonetizationService y sus adaptadores pertenecen a la etapa comercial.

## Cámara e interacción

Estados de entrada previstos: reposo, selección pendiente, arrastre, cámara, herramienta y bloqueo de interfaz/transición. Seguir el contacto que inició la interacción; cancelar correctamente al perder foco o cambiar de modo. Resolver de forma explícita la llegada de un segundo contacto.

Unificar mouse y touch en intenciones, evitando contar como dos acciones los eventos de emulación. HUD consume su entrada antes de interactuar con el mundo. Se usa raycasting para selección y una geometría de interacción controlada para mover y colocar.

CameraController limita órbita y zoom, ofrece vistas contextuales y considera la visibilidad de objetos/destinos. La forma del diorama ayuda a evitar oclusión antes de recurrir a soluciones de cámara costosas.

## Limpieza

CleaningTaskData declara superficie, región válida, herramientas, eficiencia y umbral. La cobertura debe medir zonas distintas recorridas; frotar repetidamente el mismo lugar no aumenta artificialmente el área total limpia.

Primera técnica candidata: máscara de baja resolución en coordenadas locales de una superficie plana, modificada por trazos y mostrada con un material sencillo. La actualización visual se agrupa y se limita a interacción activa; no se reconstruyen texturas cada frame sin necesidad.

La cuadrícula o máscara persistente es independiente de la representación. Permite guardar y reanudar cobertura, normalizar el porcentaje sobre el área limpiable y comparar técnicas visuales. Deben probarse bordes, huecos y recorridos rápidos para evitar manchas inaccesibles.

## Persistencia

JSON bajo `user://`, fuera del repositorio. Campos previstos: versión de esquema, versión de contenido, ID de nivel, objetos por ID, estados de contenedores, cobertura de limpieza, riesgos, coleccionables y resumen de progreso.

Guardar con temporal, validación y respaldo; comprobar comportamiento de reemplazo en cada plataforma. No se declarará escritura atómica portable sin verificarla. Recuperar desde respaldo si el archivo principal es inválido. Una versión futura desconocida se conserva sin sobrescribirla automáticamente.

Las migraciones son explícitas y pequeñas. Definir qué ocurre si una nueva versión del nivel retira un ID, agrega un objeto o cambia objetivos. Los ajustes del jugador se separan del progreso; los derechos de compra futuros provienen de verificación de plataforma.

Solicitar guardado tras acciones relevantes con agrupación razonable de escrituras y al suspender/cerrar cuando el sistema permita completar la operación. Probar fallo de escritura, interrupción y reanudación; no confiar solo en la salida normal de Windows.

## Estructura propuesta, a crear cuando tenga contenido

```text
project.godot
scenes/app/             arranque y flujo
scenes/levels/bedroom/  diorama y presentación del dormitorio
scenes/components/     objeto, contenedor, destino y superficie
scripts/data/          definiciones Resource
scripts/domain/        estado y reglas
scripts/interaction/   entrada y cámara
scripts/systems/       objetivos, limpieza y feedback
scripts/services/      persistencia y configuración
resources/levels/      definiciones de nivel
resources/items/       objetos y reglas reutilizables
assets/                modelos, materiales, audio y UI
localization/          traducciones y claves
tests/                 pruebas críticas ejecutables
tools/                 verificación reproducible
docs/                  documentación del proyecto
```

El árbol muestra una propuesta; actualmente solo existe documentación y configuración de Git. No se crean directorios vacíos como señal de avance.

## Extensibilidad comprobable

Antes de expandir, cargar una variante del dormitorio con otros IDs, cantidades y destinos. Después crear la cocina reutilizando selección, colocación, objetivos, guardado y limpieza. Si el núcleo requiere cambios para cada objeto nuevo, se revisan los contratos de datos antes de producir más habitaciones.

La optimización se guía por perfilado: materiales compartidos, colisiones simples, iluminación contenida y actividad por evento. Los límites de geometría, texturas, draw calls y memoria se fijarán tras medir una escena representativa.
