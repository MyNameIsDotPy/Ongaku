# Requerimientos — App de música sin anuncios

Oct 5, 2026 · @Angel

## Resumen y alcance

La app reemplaza YouTube Premium para escuchar música: buscar, armar listas y reproducir sin anuncios, con la pantalla apagada, en Android y en PC. Es de uso personal (un usuario, máximo unos pocos dispositivos) y no se publica en tiendas.

**Entra en v1**

- Búsqueda de canciones, artistas, álbumes y playlists de YouTube / YouTube Music.
- Reproducción de solo audio, con cola, shuffle, repeat y controles del sistema (pantalla de bloqueo, notificación, audífonos Bluetooth).
- Reproducción en segundo plano con la pantalla apagada (Android) y minimizada en la bandeja (PC).
- Playlists propias, favoritos e historial, sincronizados entre dispositivos.
- Importar playlists públicas de YouTube por URL.

**No entra en v1**

- Video (solo se reproduce audio).
- iOS (sideload complicado y sin reproducción en segundo plano confiable fuera de la App Store).
- Varios usuarios, cuentas o registro público.
- Iniciar sesión con la cuenta de Google ni sincronizar con la biblioteca de YouTube Music del usuario.
- Letras, Chromecast, ecualizador (van al backlog, sección de fases).

## Decisiones de arquitectura

Un backend propio en el homelab hace todo el trabajo con YouTube; los clientes Flutter solo hablan con ese backend. Así, cuando YouTube cambie algo, se actualiza un contenedor y no las apps.

&#91;embedded content: arquitectura · 2 clientes, 1 backend, 4 componentes\]

Las apps nunca contactan a YouTube: piden todo al backend por Tailscale, y el backend también hace de proxy del audio.

| Decisión | Elección | Por qué |
| --- | --- | --- |
| Extracción de streams | yt-dlp (como librería) + Deno | Es lo más mantenido; desde nov. 2025 necesita un runtime JS para los retos de YouTube |
| Búsqueda y metadatos | ytmusicapi | Búsqueda de YouTube Music sin login: canciones, álbumes, artistas, letras |
| Backend | Python + FastAPI, SQLite, Docker | yt-dlp y ytmusicapi son Python; llamarlos como librería evita lanzar procesos |
| Entrega del audio | El backend hace de proxy del audio (con soporte de `Range`) | Las URLs de googlevideo quedan atadas a la IP que las pidió; con el celular en datos móviles fallarían |
| Red | Tailscale entre dispositivos y homelab | Sin puertos abiertos a internet |
| Clientes | Flutter: Android + Windows/Linux | Un solo código de UI; ya usas Flutter |
| Audio en el cliente | `just_audio` + `audio_service` | Servicio en primer plano y MediaSession en Android; controles de medios en PC |

**División de trabajo.** La app Flutter se separa en dos capas con un contrato estable entre ellas:

- **UI (Angel):** pantallas, navegación, tema, animaciones, estado visual. Solo consume las interfaces de abajo.
- **Core (backend + capa de datos):** paquete Dart `core` que expone `CatalogRepository` (búsqueda, detalle), `LibraryRepository` (playlists, favoritos, historial), `PlayerController` (cola y reproducción, con `Stream`s de estado) y `DownloadManager`. Incluye el cliente HTTP, la caché local y la integración con `audio_service`.

Mientras el core no esté listo, la UI trabaja contra implementaciones falsas (`Fake*Repository`) con datos de ejemplo, así ambos frentes avanzan en paralelo.

## Casos de uso

Seis situaciones reales definen qué tiene que funcionar sí o sí; cada requerimiento de abajo se justifica con al menos una.

| ID | Situación | Qué espera el usuario |
| --- | --- | --- |
| CU-01 | En TransMilenio rumbo a la U, celular en el bolsillo con datos móviles | Pone una playlist, bloquea la pantalla y suena sin cortes; pausa y salta con los audífonos |
| CU-02 | Programando en el PC | Busca un álbum, lo pone a sonar y minimiza la app a la bandeja; controla con las teclas multimedia |
| CU-03 | Escucha algo en el PC y sale de la casa | Abre la app en el celular y encuentra el historial y sus playlists al día |
| CU-04 | Quiere una lista que ya tiene en YouTube | Pega la URL de la playlist y la importa como playlist propia |
| CU-05 | Va a un lugar sin señal | Descarga una playlist antes y la escucha offline |
| CU-06 | Descubre algo nuevo | Desde una canción abre el artista o álbum, o arranca una “radio” de canciones parecidas |

## Requerimientos funcionales

Son 32 requerimientos; los 20 marcados Must forman la v1 mínima usable (fase 1 y 2). La prioridad usa MoSCoW y se puede cambiar desde la columna.

| ID | Área | Requerimiento | Prioridad | Caso de uso |
| --- | --- | --- | --- | --- |
| RF-01 | Búsqueda | Buscar por texto; resultados agrupados en canciones, álbumes, artistas y playlists | Must | CU-02, CU-06 |
| RF-02 | Búsqueda | Sugerencias mientras se escribe | Should | CU-02 |
| RF-03 | Búsqueda | Búsquedas recientes, borrables una a una o todas | Could | CU-02 |
| RF-04 | Catálogo | Detalle de álbum (portada, año, pistas, duración total) y reproducirlo completo | Must | CU-02 |
| RF-05 | Catálogo | Detalle de artista: canciones populares, álbumes, sencillos | Should | CU-06 |
| RF-06 | Catálogo | Abrir una playlist pública de YouTube pegando su URL | Must | CU-04 |
| RF-07 | Reproducción | Reproducir solo audio en la mejor calidad disponible (opus o m4a) | Must | CU-01 |
| RF-08 | Reproducción | Cola: agregar al final, reproducir a continuación, reordenar arrastrando, quitar | Must | CU-01, CU-02 |
| RF-09 | Reproducción | Shuffle y repeat (apagado / una / todas) | Must | CU-01 |
| RF-10 | Reproducción | Barra de progreso con seek y tiempo transcurrido / total | Must | CU-01 |
| RF-11 | Reproducción | Segundo plano con pantalla apagada en Android y app minimizada a la bandeja en PC | Must | CU-01, CU-02 |
| RF-12 | Reproducción | Controles en notificación, pantalla de bloqueo, audífonos Bluetooth y teclas multimedia del PC | Must | CU-01, CU-02 |
| RF-13 | Reproducción | Pausar al desconectar audífonos y durante llamadas; bajar volumen ante notificaciones | Must | CU-01 |
| RF-14 | Reproducción | Precargar la siguiente canción para que no haya silencio entre pistas | Should | CU-01 |
| RF-15 | Reproducción | Radio: cola automática de canciones relacionadas a partir de una canción | Should | CU-06 |
| RF-16 | Reproducción | Restaurar cola, canción y posición al reabrir la app | Should | CU-01 |
| RF-17 | Reproducción | Temporizador de apagado (minutos o al terminar la canción) | Could | CU-01 |
| RF-18 | Reproducción | Normalización de volumen entre canciones | Could | CU-01 |
| RF-19 | Biblioteca | Crear, renombrar y borrar playlists; agregar, quitar y reordenar canciones | Must | CU-01, CU-03 |
| RF-20 | Biblioteca | Marcar y desmarcar favoritos con un toque | Must | CU-03 |
| RF-21 | Biblioteca | Historial de reproducción con fecha y dispositivo | Must | CU-03 |
| RF-22 | Biblioteca | Importar una playlist de YouTube como copia propia editable | Must | CU-04 |
| RF-23 | Biblioteca | Sincronizar playlists, favoritos e historial entre dispositivos a través del backend | Must | CU-03 |
| RF-24 | Biblioteca | Exportar e importar la biblioteca como JSON (respaldo) | Could | CU-03 |
| RF-25 | Descargas | Descargar canciones, álbumes o playlists para escuchar offline | Should | CU-05 |
| RF-26 | Descargas | Ver espacio usado, fijar un límite y borrar descargas | Should | CU-05 |
| RF-27 | Descargas | Opción de descargar solo con Wi-Fi | Should | CU-05 |
| RF-28 | Sistema | Primer arranque: configurar URL del backend y token, con prueba de conexión | Must | Todos |
| RF-29 | Sistema | Sin conexión al backend: avisarlo y dejar usables la biblioteca en caché y las descargas | Must | CU-05 |
| RF-30 | Extras | Letras (estáticas) de la canción actual | Could | CU-06 |
| RF-31 | Extras | Reproducción de video | Won't (v1) | — |
| RF-32 | Extras | Enviar a Chromecast o parlantes en red | Won't (v1) | — |

## Requerimientos no funcionales

Lo crítico es que la música arranque rápido y no se corte con la pantalla apagada; las metas de abajo son objetivos de diseño a medir en la fase 2.

| ID | Tema | Requerimiento | Meta |
| --- | --- | --- | --- |
| RNF-01 | Plataformas | Android 8.0 (API 26) o superior, target SDK actual; Windows 10+ y Linux (Wayland) | — |
| RNF-02 | Latencia | Tiempo desde tocar una canción hasta escuchar audio | ≤ 2,5 s en Wi-Fi, ≤ 4 s en 4G |
| RNF-03 | Latencia | Resultados de búsqueda | ≤ 1,5 s |
| RNF-04 | Continuidad | El audio no se corta con la pantalla apagada ni por ahorro de batería (Doze, MIUI, One UI) | 2 h seguidas sin cortes |
| RNF-05 | Android | Servicio en primer plano tipo `mediaPlayback` declarado (obligatorio desde Android 14) y permiso de notificaciones (Android 13+) | — |
| RNF-06 | Batería | Consumo con pantalla apagada comparable a YouTube Music | Medir y comparar en el mismo celular |
| RNF-07 | Datos móviles | Calidad configurable: alta (\~160 kbps, \~70 MB/h) y ahorro (\~50 kbps, \~22 MB/h) | — |
| RNF-08 | Seguridad | Backend accesible solo por Tailscale; token Bearer por dispositivo; nada de credenciales de Google | Cero puertos abiertos a internet |
| RNF-09 | Privacidad | Sin analítica ni telemetría de terceros | — |
| RNF-10 | Mantenibilidad | Actualizar yt-dlp sin recompilar la app ni la imagen (al arrancar el contenedor o con un job nocturno) | — |
| RNF-11 | Observabilidad | Endpoint `/health` que intenta extraer un video conocido y reporta si YouTube rompió algo | Revisión cada 6 h |
| RNF-12 | Resiliencia | Si falla la extracción de una canción, saltar a la siguiente y avisar, sin detener la cola | — |
| RNF-13 | Accesibilidad | Etiquetas para TalkBack, zonas táctiles de 48 dp mínimo, respeta el tamaño de texto del sistema | — |
| RNF-14 | Rendimiento UI | Listas largas (playlists de 1.000+ canciones) con scroll fluido | 60 fps |

En Linux, `just_audio` necesita el backend `just_audio_media_kit`, y los controles multimedia van por MPRIS; en Windows, por SMTC.

## Contrato de la API

API REST JSON versionada en `/v1`, con `Authorization: Bearer <token>` en cada llamada. La UI nunca la llama directo: pasa por los repositorios del paquete `core`.

| Método y ruta | Qué hace | RF |
| --- | --- | --- |
| `GET /v1/search?q=&type=all\|songs\|albums\|artists\|playlists` | Búsqueda agrupada o por tipo, paginada con `cursor` | RF-01 |
| `GET /v1/search/suggestions?q=` | Sugerencias de autocompletado | RF-02 |
| `GET /v1/tracks/{videoId}` | Metadatos de una canción | RF-07 |
| `GET /v1/albums/{albumId}` | Álbum con sus pistas | RF-04 |
| `GET /v1/artists/{artistId}` | Artista: populares, álbumes, sencillos | RF-05 |
| `GET /v1/yt-playlists/{playlistId}` | Playlist pública de YouTube (acepta también la URL completa codificada) | RF-06 |
| `GET /v1/radio/{videoId}` | Lista de canciones relacionadas para la radio | RF-15 |
| `GET /v1/stream/{videoId}?quality=high\|low` | Bytes del audio con soporte de `Range`; `Content-Type` `audio/webm` u `audio/mp4` | RF-07, RF-25 |
| `GET /v1/lyrics/{videoId}` | Letra, si existe | RF-30 |
| `GET·POST /v1/library/playlists` | Listar y crear playlists propias | RF-19 |
| `PATCH·DELETE /v1/library/playlists/{id}` | Renombrar o borrar | RF-19 |
| `PUT /v1/library/playlists/{id}/tracks` | Reemplaza la lista ordenada de canciones (cubre agregar, quitar y reordenar) | RF-19 |
| `POST /v1/library/playlists/import` | Body `{ "url": "…" }`; copia una playlist de YouTube | RF-22 |
| `PUT·DELETE /v1/library/favorites/{videoId}` | Marcar o quitar favorito | RF-20 |
| `POST /v1/library/history` | Registrar una reproducción (a partir de 30 s escuchados) | RF-21 |
| `GET /v1/library/history?cursor=` | Historial paginado | RF-21 |
| `GET /v1/sync?since=<cursor>` | Cambios de la biblioteca desde el último cursor | RF-23 |
| `GET /v1/export` · `POST /v1/import` | Respaldo JSON de la biblioteca | RF-24 |
| `GET /health` | Estado del backend y prueba de extracción | RNF-11 |

Respuesta de una canción (forma que usa toda la UI):

```json
{
  "videoId": "dQw4w9WgXcQ",
  "title": "Nombre de la canción",
  "artists": [{ "id": "UC...", "name": "Artista" }],
  "album": { "id": "MPREb_...", "name": "Álbum" },
  "durationMs": 213000,
  "thumbnails": { "small": "https://...", "large": "https://..." },
  "explicit": false,
  "isFavorite": true
}
```

Errores con forma única `{ "error": { "code": "EXTRACTION_FAILED", "message": "…" } }`. Códigos que la UI debe saber mostrar: `UNAUTHORIZED`, `NOT_FOUND`, `UNAVAILABLE` (video bloqueado o privado), `EXTRACTION_FAILED` (YouTube cambió algo), `RATE_LIMITED`, `BACKEND_OFFLINE` (lo genera el cliente).

## Pantallas, estados y flujos

Son 10 pantallas más un mini-reproductor persistente. Aquí va qué debe mostrar y permitir cada una; el diseño visual queda libre.

| Pantalla | Contenido | Acciones | RF |
| --- | --- | --- | --- |
| Conexión (primer arranque) | URL del backend, token, resultado de la prueba | Probar conexión, guardar; pedir permiso de notificaciones y desactivar la optimización de batería | RF-28 |
| Inicio | Seguir escuchando (historial reciente), playlists propias, favoritos, descargas | Reanudar, abrir una lista | RF-16, RF-21 |
| Búsqueda | Barra, sugerencias, búsquedas recientes, resultados por tipo | Buscar, filtrar por tipo, pegar URL de playlist | RF-01 a RF-03, RF-06 |
| Álbum | Portada, año, artista, pistas, duración total | Reproducir, shuffle, descargar, guardar como playlist | RF-04 |
| Artista | Foto, populares, álbumes, sencillos | Reproducir populares, abrir álbum, radio del artista | RF-05 |
| Playlist | Nombre, portada, número de canciones, duración, origen (propia o YouTube) | Reproducir, shuffle, descargar; si es propia: renombrar, reordenar, quitar; si es de YouTube: importar | RF-06, RF-19, RF-22 |
| Biblioteca | Pestañas: playlists, favoritos, descargas, historial | Crear playlist, ordenar, filtrar | RF-19 a RF-21, RF-25 |
| Reproductor | Portada grande, título, artistas, barra de progreso, controles | Play/pausa, anterior/siguiente, seek, shuffle, repeat, favorito, abrir cola, letras, temporizador | RF-07 a RF-18, RF-30 |
| Cola | Canción actual, “a continuación”, resto de la cola | Reordenar arrastrando, quitar, limpiar, guardar como playlist | RF-08 |
| Ajustes | Backend, calidad (Wi-Fi y datos), descargas y espacio, versión de app y backend | Cambiar valores, borrar caché, exportar e importar respaldo | RF-24, RF-26, RF-27, RNF-07 |

**Componentes compartidos**

- **Mini-reproductor:** visible en todas las pantallas excepto el reproductor; portada, título, play/pausa, progreso; tocarlo abre el reproductor.
- **Fila de canción:** portada, título, artista, duración, indicador de descargada o reproduciendo. Menú contextual: reproducir a continuación, agregar a la cola, agregar a playlist, favorito, ir al álbum, ir al artista, iniciar radio, descargar.
- **Indicador de conexión:** aviso discreto cuando el backend no responde.

**Estados que cada pantalla con datos debe diseñar:** cargando (skeleton), vacío (con una acción sugerida), error con reintentar, y sin backend (muestra solo lo que está en caché o descargado).

**Estados del reproductor** que expone `PlayerController`: `idle`, `loading`, `buffering`, `playing`, `paused`, `completed`, `error`. Cada uno necesita su representación en el reproductor, el mini-reproductor y la notificación.

**PC:** diseño de tres zonas (navegación lateral, contenido, cola opcional a la derecha) con barra de reproducción abajo. Atajos mínimos: `Espacio` play/pausa, `Ctrl+F` buscar, `Ctrl+→/←` siguiente/anterior, `Ctrl+L` favorito. Cerrar la ventana la manda a la bandeja.

**Flujos clave a prototipar primero:**

1. Buscar → tocar canción → suena → bloquear pantalla → controlar desde la notificación (CU-01).
2. Pegar URL de playlist → vista previa → importar → aparece en la biblioteca (CU-04).
3. Canción → menú → agregar a playlist (existente o nueva) sin salir de la pantalla actual.
4. Descargar playlist → progreso por canción → modo avión → sigue sonando (CU-05).

## Modelo de datos

El backend guarda la biblioteca en SQLite y es la fuente de verdad; cada cliente tiene una copia local (Drift sobre SQLite) para funcionar sin conexión.

| Entidad | Campos principales | Dónde vive |
| --- | --- | --- |
| `track` | `video_id` (PK), `title`, `artists_json`, `album_id`, `album_name`, `duration_ms`, `thumb_url`, `updated_at` | Backend y cliente (caché de metadatos) |
| `playlist` | `id` (UUID), `name`, `source` (`own` o `youtube`), `source_id`, `created_at`, `updated_at`, `deleted_at` | Backend y cliente |
| `playlist_track` | `playlist_id`, `video_id`, `position`, `added_at` | Backend y cliente |
| `favorite` | `video_id`, `added_at`, `deleted_at` | Backend y cliente |
| `play_event` | `id`, `video_id`, `device_id`, `played_at`, `listened_ms` | Backend y cliente |
| `device` | `id`, `name`, `token_hash`, `last_seen_at` | Solo backend |
| `change` | `seq` (cursor), `entity`, `entity_id`, `op`, `at` | Solo backend (alimenta `/v1/sync`) |
| `download` | `video_id`, `file_path`, `bytes`, `quality`, `status`, `downloaded_at` | Solo cliente |
| `stream_cache` | `video_id`, `quality`, `url`, `expires_at` | Solo backend (URLs de googlevideo, caducan en horas) |
| `audio_cache` | `video_id`, `quality`, `file_path`, `bytes`, `last_access` | Solo backend (caché LRU en disco de lo más escuchado) |

**Sincronización.** Cada cambio en el backend agrega una fila a `change`. El cliente guarda el último `seq` y pide `/v1/sync?since=<seq>` al abrir la app y cada vez que vuelve a primer plano. Los cambios hechos offline se encolan y se envían al reconectar; ante conflicto, gana la última escritura (`updated_at`). Los borrados son lógicos (`deleted_at`) para que se propaguen.

## Riesgos y mitigaciones

El riesgo mayor es que YouTube cambie algo y la extracción deje de funcionar; por eso toda esa lógica vive en el backend, que se actualiza en minutos.

| Riesgo | Impacto | Mitigación |
| --- | --- | --- |
| YouTube cambia su reproductor o sus retos JS y yt-dlp deja de extraer | No suena nada nuevo | Actualización automática de yt-dlp, `/health` con alerta, caché de audio y descargas para seguir escuchando lo frecuente |
| YouTube exige PO tokens o bloquea la IP del homelab | Errores 403 o “confirma que no eres un bot” | IP residencial (no VPS), pocas peticiones por minuto, plugin de PO token de yt-dlp si hace falta, cookies de una cuenta secundaria como último recurso |
| Cambia la API interna de YouTube Music y falla ytmusicapi | Búsqueda o detalle rotos | Fijar versión y actualizar al publicarse un arreglo; respaldo de búsqueda con `ytsearch` de yt-dlp |
| Ahorro de batería de fabricantes (Xiaomi, Samsung) mata el servicio | Se corta la música con la pantalla apagada | Servicio en primer plano con notificación, pedir excluir la app de la optimización de batería en el onboarding |
| Se cae el internet de la casa o el homelab | Sin streaming | Descargas offline, caché local de la biblioteca, mensaje claro en la UI |
| Subida de la casa limitada con varios dispositivos | Cortes en datos móviles | El audio pesa \~160 kbps; con 2 o 3 dispositivos alcanza; calidad baja como opción |
| Términos de servicio de YouTube | Bloqueo de cuenta si se usan cookies | Uso personal, sin publicar la app ni distribuir contenido, sin usar la cuenta principal |

## Plan por fases

Son cuatro fases, y cada una cierra con una prueba real en el celular. Desde la fase 1 ya puedes cancelar YouTube Premium.

&#91;embedded content: plan · 4 fases y sus pruebas de cierre\]

Cada rombo es la prueba que cierra la fase; no se pasa a la siguiente sin cumplirla.

**Criterios de aceptación**

Fase 0. Cimientos

- [ ] Backend en Docker en el homelab, accesible solo por Tailscale, con token
- [ ] `GET /v1/search` y `GET /v1/stream/{id}` funcionan; el audio suena en VLC del celular por Tailscale
- [ ] Paquete `core` con interfaces y `Fake*Repository`; la UI navega por las pantallas con datos falsos

Fase 1. Reproducir (MVP)

- [ ] Buscar, abrir un álbum y reproducirlo completo en Android
- [ ] 2 h seguidas con la pantalla apagada y datos móviles sin cortes (RNF-04)
- [ ] Controles en notificación, pantalla de bloqueo y audífonos Bluetooth
- [ ] Cola, shuffle y repeat; pausa al desconectar audífonos
- [ ] Primer sonido en ≤ 2,5 s en Wi-Fi (RNF-02)

Fase 2. Biblioteca y PC

- [ ] Crear, editar y borrar playlists; favoritos e historial
- [ ] Importar una playlist de YouTube de 200+ canciones
- [ ] Un cambio en el celular aparece en el PC al volver a abrir la app (CU-03)
- [ ] App de escritorio con bandeja y teclas multimedia en Windows y Linux

Fase 3. Offline y pulido

- [ ] Descargar una playlist y escucharla en modo avión (CU-05)
- [ ] Radio, restaurar la cola al reabrir, temporizador y letras
- [ ] Una semana de uso diario sin volver a abrir YouTube Music

## Preguntas abiertas

- [ ] Nombre de la app.
- [ ] Backend en Python/FastAPI (propuesto) o en Rust/Axum llamando a yt-dlp como proceso.
- [ ] Gestión de estado en Flutter: Riverpod, Bloc u otra; afecta cómo `core` expone sus `Stream`s.
- [ ] ¿Qué máquina del homelab corre el backend y cuánto disco se le da a la caché de audio?
- [ ] ¿La app de PC se usa en Windows, en Linux (Omarchy) o en ambos? Define dónde se prueba primero.
- [ ] ¿Se necesita alguna vez acceso sin Tailscale (por ejemplo, desde un PC ajeno)?
- [ ] Ya que el audio pasa por el backend, ¿se quiere importar también la biblioteca actual de YouTube Music con cookies, o se arma desde cero?

## Fuentes

- [yt-dlp requiere Deno u otro runtime de JavaScript para YouTube (Gigazine, nov. 2025)](https://wbgsv0a.gigazine.net/gsc_news/en/20251113-yt-dlp-required-deno-javascript-runtime)
- [Foro VideoLAN: el script de YouTube de VLC se rompe con cada cambio de Google](https://forum.videolan.org/viewtopic.php?p=485854)
