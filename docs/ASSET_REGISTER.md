# Registro de arte y sonido

14 de octubre de 2026. Primera mejora de presentación, versión 0.1.2.

## Procedencia

Geometría, icono, colores, shader y síntesis sonora creados para este proyecto. No se descargaron modelos, texturas, música ni efectos de bancos externos. La tipografía predeterminada pertenece a la distribución de Godot; sus avisos se mantienen con el motor. La licencia general del repositorio queda por definir.

| Recurso | Fuente editable | Producción | Estado |
| --- | --- | --- | --- |
| Prendas y medias | scripts/view/item_visuals.gd | Polígonos extruidos, detalles de tela | Integrados; revisión visual en PC |
| Peluche | scripts/view/item_visuals.gd | Volúmenes redondeados, orejas, patas, hocico y lazo | Integrado; revisión visual en PC |
| Libros, botella y papel | scripts/view/item_visuals.gd | Cubiertas, páginas, etiqueta y hojas con líneas | Integrados; revisión visual en PC |
| Dormitorio | scripts/view/bedroom_view.gd | Mobiliario, cortinas, planta, lámpara, manta y alfombra | Integrado; arte estilizado de desarrollo |
| Icono | assets/icon.svg | Vector propio del proyecto | Integrado |
| Suciedad | assets/shaders/dirt.gdshader | Máscara de cobertura y shader | Integrado en ambos renderizadores |
| Materiales sonoros | scripts/systems/sound_palette.gd | Ruido filtrado, resonancias y envolventes, PCM mono 22.05 kHz | Cinco perfiles, tres variantes por perfil |
| Armario | scripts/systems/sound_palette.gd | Apertura y cierre diferenciados | Integrados |
| Roce del paño | scripts/systems/sound_palette.gd + feedback_manager.gd | Bucle con intensidad por movimiento, entrada/salida gradual | Integrado; silencio al detener/cancelar |
| Hallazgo y final | scripts/systems/sound_palette.gd | Frases tonales suaves | Integradas |
| Ambiente | scripts/systems/sound_palette.gd | Acorde periódico de ocho segundos | Integrado; escucha humana pendiente |

El perfil sonoro se declara en ItemData.sound_profile. La colocación identifica objeto y destino; GameRoot consulta sus datos y FeedbackManager reproduce el sonido. Las reglas no conocen buses ni formas de onda. Un perfil desconocido utiliza madera como alternativa.

## Construcción y coste

Los modelos se generan al iniciar la escena; no se regeneran al arrastrar o limpiar. MeshBatcher agrupa mallas de una superficie y material compartido entre hermanos con el mismo movimiento. Mantiene independientes colisionadores, etiquetas, pads, puerta y selección. No debe aplicarse a mallas con visibilidad o animación individual; admite una lista explícita de exclusiones. Usa [SurfaceTool](https://docs.godotengine.org/en/stable/classes/class_surfacetool.html) para conservar transformaciones y materiales.

La paleta genera 23 clips una vez por escena y se libera al salir. El paño usa una voz independiente de los tres efectos discretos. Ambos pasan por Effects; la música por Music. En Master se instala un único [AudioEffectHardLimiter](https://docs.godotengine.org/en/stable/classes/class_audioeffecthardlimiter.html) con techo de −1 dB, incluso al repetir. El limitador controla picos de la mezcla; no sustituye una revisión de volumen y comodidad con jugadores.

## Evidencia y muestra

tests/asset_tests.gd comprueba formato PCM, margen de amplitud, media, límites de clips, uniones de bucles, variantes y conservación de geometría/materiales al agrupar. Genera build/audio/material-preview.wav para escuchar desde Windows; ese archivo derivado se excluye de Git.

Orden de la muestra: tela, papel, plástico, objeto blando, madera, apertura de armario, roce, hallazgo y final. La muestra no reproduce los buses, el limitador ni los cambios de intensidad de una partida. Para juzgar el conjunto, usar el ejecutable y los controles de música/sonidos.

El recorrido gráfico comprueba perfiles al colocar, roce mientras se mueve, silencio al detener/cancelar, volumen de efectos a cero y ausencia de limitadores duplicados al repetir. No se ha realizado una escucha humana ni una prueba de auriculares/altavoces móviles. Sonidos sintetizados, sin pretender grabaciones foley ni ASMR definitivo.

Las capturas de docs/images provienen del viewport real del paquete exportado. La claridad en teléfonos, el coste de construcción en hardware móvil, el refinamiento artístico final y la mezcla percibida siguen pendientes.
