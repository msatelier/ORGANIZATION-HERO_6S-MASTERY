# Diseño del juego

Estado: propuesta inicial del 13 de octubre de 2026. Ninguna mecánica está implementada todavía.

## Promesa de experiencia

Convertir un espacio desordenado en un lugar agradable mediante acciones pequeñas, comprensibles y satisfactorias. El aprendizaje de las 6S surge de observar consecuencias: encontrar, elegir, colocar, limpiar y comprobar.

Android e iOS son las plataformas de producto. Windows es la plataforma inicial de desarrollo y prueba. Diorama 3D estilizado, orientación horizontal y español/inglés desde la base del contenido.

## Principios de diseño

- Relax es el modo principal: sin vidas, temporizador obligatorio, anuncios forzados ni castigos irreversibles.
- El jugador puede experimentar y encontrar varias soluciones válidas.
- Las ayudas muestran acciones posibles con poco texto y señales claras.
- Cada nivel declara sus dimensiones 6S; las dependencias responden a la situación.
- Las estrellas reconocen logros y nunca bloquean la historia principal.
- Los efectos y el audio acompañan; opciones permiten reducirlos o desactivarlos.

## Ciclo del dormitorio

Entrar y ver el estado inicial → explorar y abrir un contenedor → seleccionar y clasificar → colocar objetos en destinos válidos → limpiar una superficie → despejar un riesgo de tropiezo → descubrir el coleccionable → comprobar objetivos → terminar y comparar el resultado.

Es una descripción del ciclo, no una secuencia obligatoria. Por ejemplo, abrir el cajón puede ser necesario para guardar una prenda, mientras que limpiar una mesa despejada no necesita esperar a ordenar toda la habitación.

## Contenido acotado propuesto

| Elemento | Propuesta |
| --- | --- |
| Habitación | Piso, dos paredes que favorezcan la visibilidad, cama, mesa y armario/cajón |
| Objetos | 8 a 12 movibles entre prendas, libros y objetos de descarte/reciclaje |
| Destinos | Cajón, estante y contenedores de clasificación; al menos un destino alternativo |
| Limpieza | Una superficie plana visible, una mancha o polvo distribuido y un paño |
| Seguridad | Objeto blando que obstaculiza el paso; corrección mediante reubicación |
| Coleccionable | Uno oculto detrás o debajo de un objeto que pueda moverse |
| Duración | Hipótesis inicial de 5 a 10 minutos, a ajustar con jugadores |

El riesgo doméstico no requiere manipular electricidad, químicos ni maquinaria. En niveles industriales futuros, se diseñarán situaciones coherentes y se revisarán los procedimientos antes de incorporarlos.

## Controles y ayudas

Un gesto selecciona o inicia la manipulación según el contexto; el movimiento sobre fondo puede orbitar. El segundo contacto activa zoom/orbitado siguiendo reglas de cancelación claras. Una herramienta activa cambia el modo de interacción solo para superficies elegibles. Mouse debe permitir reproducir las acciones del flujo en PC.

Objetos y destinos necesitan superficies de selección tolerantes. Una ubicación inválida explica el motivo mediante un indicio visual o texto breve. Deshacer permite revertir acciones discretas de organización; la limpieza conserva su cobertura y la pista explica cómo completar zonas restantes. Clasificar o descartar dentro del nivel no destruye progreso irreversiblemente.

Los gestos concretos y sus umbrales se fijarán en el prototipo. Se revisará que la interfaz consuma sus propias interacciones y que la cámara no se mueva mientras el jugador arrastra un objeto.

## Objetivos y evaluación

Objetivos obligatorios propuestos: clasificar los objetos definidos, organizar los necesarios, limpiar la superficie hasta el umbral declarado y despejar el paso. Encontrar el coleccionable y mejorar la precisión pueden ser objetivos opcionales.

S1 agrupa clasificación; S2 ubicación; S3 limpieza; S6 el paso despejado. S5 puede aparecer como una comprobación final real del estado. S4 se reservará para un contenido que necesite etiquetar o estandarizar visualmente. Las etiquetas 6S son datos de los objetivos y no seis barras obligatorias por escenario.

El nivel termina cuando se satisfacen las condiciones obligatorias. El resumen muestra el resultado, los logros opcionales, puntuación/estrellas y el hallazgo si corresponde. Los pesos y umbrales de puntuación son ajustables en datos y están pendientes de calibración. En Relax no se penaliza por tardar ni se exige una puntuación para avanzar.

El antes/después debe mostrar la misma composición de cámara para que la mejora se entienda. Se investigará si usar dos capturas o reconstruir estados; no se ha elegido ni implementado la técnica.

## Presentación y recursos

Geometría inicial comprensible con materiales compartidos y colores cálidos. Los modelos provisionales se marcarán como tales. La mejora visual sucede después de probar escala, cámara, siluetas y legibilidad de destinos.

Audio básico por material y confirmaciones suaves. Mezclas separadas para música y efectos; háptica opcional donde sea compatible. Registrar fuente/licencia de cada recurso externo. No hay recursos de arte o audio incorporados todavía.

## Progresión y contenido posterior

Dormitorio validado → cocina que demuestre reutilización → baño, sala y garaje → fábrica y desafíos avanzados. Coleccionables permanentes y cosméticos pueden ampliar la motivación sin reemplazar la habilidad del jugador.

Publicidad y compras se diseñan posteriormente con adaptadores y fallos controlados. No forman parte del primer ciclo jugable.
