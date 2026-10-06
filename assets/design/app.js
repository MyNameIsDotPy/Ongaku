/* Onda — vistas, navegación y componentes compartidos */
(function () {
  const D = window.DATA, P = window.Player;
  const $ = (s, r = document) => r.querySelector(s), $$ = (s, r = document) => [...r.querySelectorAll(s)];
  const ic = (n, c = '') => `<svg class="i ${c}"><use href="#i-${n}"/></svg>`;
  const esc = s => String(s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
  const fmt = s => { s = Math.max(0, Math.floor(s)); return Math.floor(s / 60) + ':' + String(s % 60).padStart(2, '0'); };
  const fmtLong = s => { const m = Math.round(s / 60); return m >= 60 ? `${Math.floor(m / 60)} h ${m % 60} min` : `${m} min`; };
  const norm = s => s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
  const plural = (n, a, b) => `${n} ${n === 1 ? a : b}`;

  /* ── estado de la biblioteca (persistido) ── */
  const LS = 'onda.library';
  const st = Object.assign({
    playlists: D.PLAYLISTS.map(p => ({ ...p, tracks: p.tracks.slice(), inLibrary: p.source === 'own' })),
    favorites: D.FAVORITES.slice(), downloads: { ...D.DOWNLOADS }, history: D.HISTORY.slice(), recents: D.RECENT_SEARCHES.slice(),
    settings: { theme: 'light', qWifi: 'high', qData: 'low', wifiOnly: true, limit: 8, motion: 'full', reactive: true, url: 'http://homelab.tail3c2e1.ts.net:8080', token: 'od_7f3a9c21e5b84d06' },
  }, JSON.parse(localStorage.getItem(LS) || '{}'));
  const save = () => localStorage.setItem(LS, JSON.stringify(st));
  const pl = id => st.playlists.find(p => p.id === id);
  const isFav = id => st.favorites.includes(id);
  const isDownloaded = id => Object.keys(st.downloads).some(pid => (pl(pid) || {}).tracks?.includes(id)) || Object.keys(st.downloads).some(k => D.album(k)?.tracks.some(t => t.id === id));
  const plCovers = p => [...new Set(p.tracks.map(id => D.TRACKS[id]?.cover))].slice(0, 4);
  const plArt = p => { const c = plCovers(p); return c.length >= 4 ? `<div class="mosaic">${c.map(s => `<img src="${s}" alt="">`).join('')}</div>` : c.length ? `<img src="${c[0]}" alt="">` : `<div style="display:grid;place-items:center;height:100%">${ic('queue')}</div>`; };
  const plDur = p => p.tracks.reduce((s, id) => s + (D.TRACKS[id]?.dur || 0), 0);

  /* estados de demostración: #/ruta?estado=offline|cargando|vacio|error */
  let estado = null;
  const applyTheme = () => {
    const t = st.settings.theme === 'system' ? (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light') : st.settings.theme;
    document.documentElement.dataset.theme = t;
    document.documentElement.dataset.motion = st.settings.motion;
  };
  applyTheme();

  /* ── toasts ── */
  function toast(msg, opts = {}) {
    const el = document.createElement('div'); el.className = 'toast' + (opts.err ? ' err' : '');
    el.innerHTML = `<span>${msg}</span>${opts.action ? `<button>${opts.action}</button>` : '<span style="width:10px"></span>'}`;
    if (opts.action) el.querySelector('button').onclick = () => { opts.onAction(); kill(); };
    $('#toasts').append(el);
    const kill = () => { el.classList.add('out'); setTimeout(() => el.remove(), 260); };
    setTimeout(kill, opts.ms || 3200);
  }

  /* ── fila de canción ── */
  function row(t, i, o = {}) {
    const cur = P.current()?.id === t.id;
    const off = estado === 'offline' && !isDownloaded(t.id);
    return `<div class="row${cur ? ' playing' : ''}${t.unavailable || off ? ' unavail' : ''}" data-tid="${t.id}" data-idx="${i}" data-od-id="track-row-${t.id}">
      <div class="ix">${o.grip ? `<span class="grip" data-grip aria-label="Arrastrar para reordenar">${ic('grip', 'fill')}</span>` : `${cur && P.state === 'playing' ? '<span class="eq n"><i></i><i></i><i></i><i></i></span>' : `<span class="n">${o.num ?? i + 1}</span>`}<button class="pbtn" data-act="play-row" aria-label="Reproducir ${esc(t.title)}">${ic('play', 'fill')}</button>`}</div>
      <div class="who">${o.noArt ? '' : `<img src="${t.cover}" alt="" width="40" height="40" loading="lazy">`}<div style="min-width:0"><div class="rt">${esc(t.title)}</div><div class="ra">${t.unavailable ? '<span class="tag">No disponible</span>' : ''}${isDownloaded(t.id) ? ic('dl', 'dl-dot') : ''}<a href="#/artista/${t.artistId}">${esc(t.artist)}</a></div></div></div>
      <div class="rb"><a href="#/album/${t.albumId}" class="link">${esc(t.album)}</a></div>
      <div class="rd"><button class="icon-btn sm fav${isFav(t.id) ? ' on' : ''}" data-act="fav" aria-label="${isFav(t.id) ? 'Quitar de favoritos' : 'Agregar a favoritos'}" aria-pressed="${isFav(t.id)}">${ic('heart', isFav(t.id) ? 'fill' : '')}</button><span class="num">${fmt(t.dur)}</span></div>
      <button class="icon-btn sm" data-act="row-menu" aria-label="Más opciones para ${esc(t.title)}">${ic('more', 'fill')}</button>
      ${o.remove ? `<button class="icon-btn sm" data-act="pl-remove" aria-label="Quitar de la playlist">${ic('x')}</button>` : ''}
    </div>`;
  }
  const tracksBlock = (ts, o = {}) => `<div class="list-head${o.noAlb ? ' no-alb' : ''}${o.editable ? ' editable' : ''}"><span>#</span><span>Título</span>${o.noAlb ? '' : '<span>Álbum</span>'}<span style="text-align:right">Duración</span><span></span>${o.editable ? '<span></span>' : ''}</div>
    <div class="tracks${o.noAlb ? ' no-alb' : ''}${o.editable ? ' editable' : ''}" data-list="${o.list || ''}">${ts.map((t, i) => row(t, i, o)).join('')}</div>`;

  const card = (href, img, t, s, playAct, id) => `<div class="card" data-od-id="${id}"><a href="${href}" class="art">${img}</a>${playAct ? `<button class="hover-play" ${playAct} aria-label="Reproducir ${esc(t)}">${ic('play', 'fill')}</button>` : ''}<a href="${href}"><div class="t">${esc(t)}</div><div class="s">${s}</div></a></div>`;
  const albumCard = a => card(`#/album/${a.id}`, `<img src="${a.cover}" alt="Portada de ${esc(a.title)}" width="600" height="600" loading="lazy">`, a.title, `${a.year} · ${esc(a.artist)}`, `data-act="play-album" data-id="${a.id}"`, 'album-card-' + a.id);
  const plCard = p => card(`#/playlist/${p.id}`, plArt(p), p.name, `${plural(p.tracks.length, 'canción', 'canciones')}${p.source === 'youtube' ? ' · YouTube' : ''}`, `data-act="play-pl" data-id="${p.id}"`, 'playlist-card-' + p.id);

  const emptyState = (icon, h, p, cta) => `<div class="empty" data-od-id="empty-state"><div class="ic">${ic(icon)}</div><h3>${h}</h3><p>${p}</p>${cta || ''}</div>`;
  const errorState = () => `<div class="empty" data-od-id="error-state"><div class="ic" style="color:var(--err)">${ic('off')}</div><h3>No pudimos cargar esto</h3><p class="mono" style="font-size:13px">EXTRACTION_FAILED · YouTube cambió algo y el backend aún no se actualiza.</p><button class="btn btn-secondary" data-act="retry">${ic('retry')}Reintentar</button></div>`;
  const skeleton = () => `<div style="display:flex;gap:28px;align-items:flex-end;margin-bottom:32px"><div class="skel" style="width:200px;height:200px;border-radius:14px"></div><div style="flex:1"><div class="skel" style="width:30%;height:14px"></div><div class="skel" style="width:60%;height:44px;margin:14px 0"></div><div class="skel" style="width:40%;height:14px"></div></div></div>${Array.from({ length: 7 }, () => `<div style="display:flex;gap:14px;align-items:center;padding:8px"><div class="skel" style="width:40px;height:40px"></div><div style="flex:1"><div class="skel" style="width:40%;height:12px"></div><div class="skel" style="width:24%;height:10px;margin-top:8px"></div></div><div class="skel" style="width:40px;height:12px"></div></div>`).join('')}`;

  /* ── vistas ── */
  const V = {};
  V.inicio = () => {
    const h = new Date().getHours();
    const hi = h < 12 ? 'Buenos días' : h < 19 ? 'Buenas tardes' : 'Buenas noches';
    if (estado === 'vacio') return `<div class="view-head"><h1>${hi}</h1></div>${emptyState('search', 'Todavía no has escuchado nada', 'Busca una canción o pega el enlace de una playlist de YouTube para empezar.', '<a class="btn btn-secondary" href="#/buscar">Ir a buscar</a>')}`;
    const seen = []; st.history.forEach(e => { if (!seen.includes(e.id)) seen.push(e.id); });
    const cur = P.current();
    const resume = (cur ? [cur.id, ...seen.filter(x => x !== cur.id)] : seen).slice(0, 4).map(id => D.TRACKS[id]);
    const albums = [...new Set(seen.map(id => D.TRACKS[id].albumId))].map(D.album);
    const own = st.playlists.filter(p => p.inLibrary);
    const dlCount = Object.keys(st.downloads).length;
    return `<div class="view-head" data-od-id="home-head"><div><p class="eyebrow" style="margin-bottom:10px">${new Date().toLocaleDateString('es-CO', { weekday: 'long', day: 'numeric', month: 'long' })}</p><h1>${hi}</h1></div></div>
    <section data-od-id="home-resume"><div class="block-head"><h2>Seguir escuchando</h2><a class="link" href="#/biblioteca/historial">Historial</a></div>
      <div class="resume-row">${resume.map((t, i) => `<button class="resume" data-act="resume" data-id="${t.id}" data-od-id="resume-${t.id}"><img src="${t.cover}" alt="" width="56" height="56"><span style="min-width:0;flex:1"><span class="t" style="display:block">${esc(t.title)}</span><span class="meta" style="display:block">${esc(t.artist)}${i === 0 && cur ? ' · ' + fmt(P.position()) + ' de ' + fmt(t.dur) : ''}</span>${i === 0 && cur ? `<span class="bar-mini" style="display:block"><i style="width:${(P.position() / t.dur) * 100}%"></i></span>` : ''}</span></button>`).join('')}</div></section>
    <section class="block" data-od-id="home-shortcuts"><div class="tiles">
      <a class="tile" href="#/biblioteca/favoritos" data-od-id="tile-favoritos"><span class="art-sm">${ic('heart', 'fill')}</span><span>Favoritos<span class="meta" style="display:block;font-weight:400">${plural(st.favorites.length, 'canción', 'canciones')}</span></span></a>
      <a class="tile" href="#/biblioteca/descargas" data-od-id="tile-descargas"><span class="art-sm">${ic('dl')}</span><span>Descargas<span class="meta" style="display:block;font-weight:400">${plural(dlCount, 'lista', 'listas')} · disponibles sin conexión</span></span></a>
      ${own.slice(0, 2).map(p => `<a class="tile" href="#/playlist/${p.id}"><span class="art-sm">${plArt(p)}</span><span>${esc(p.name)}<span class="meta" style="display:block;font-weight:400">${plural(p.tracks.length, 'canción', 'canciones')}</span></span></a>`).join('')}
    </div></section>
    <section class="block" data-od-id="home-playlists"><div class="block-head"><h2>Tus playlists</h2><a class="link" href="#/biblioteca">Ver biblioteca</a></div><div class="grid-cards">${own.map(plCard).join('')}</div></section>
    <section class="block" data-od-id="home-albums"><div class="block-head"><h2>Escuchado recientemente</h2></div><div class="grid-cards">${albums.map(albumCard).join('')}</div></section>`;
  };

  let q = '', filter = 'all';
  V.buscar = () => `<div class="view-head"><h1>Buscar</h1></div>
    <div class="search-box" data-od-id="search-box">${ic('search')}<input id="q" type="search" placeholder="Canciones, artistas, álbumes o enlace de YouTube" value="${esc(q)}" autocomplete="off" aria-label="Buscar" ${estado === 'offline' ? 'disabled' : ''}><button class="icon-btn clear" data-act="search-clear" aria-label="Borrar búsqueda" style="${q ? '' : 'display:none'}">${ic('x')}</button><div id="suggest"></div></div>
    <div id="results">${estado === 'offline' ? '<div class="block">' + emptyState('off', 'La búsqueda necesita el backend', 'Mientras tanto puedes escuchar tus descargas y la biblioteca guardada en caché.', '<a class="btn btn-secondary" href="#/biblioteca/descargas">Ver descargas</a>') + '</div>' : results()}</div>`;
  const isYtUrl = s => /(youtube\.com|youtu\.be).*(list=)/i.test(s);
  function search(s) {
    const n = norm(s.trim()); if (!n) return null;
    const tracks = Object.values(D.TRACKS).filter(t => norm(t.title + ' ' + t.artist).includes(n));
    const albums = D.ALBUMS.filter(a => norm(a.title + ' ' + a.artist).includes(n));
    const artists = Object.values(D.ARTISTS).filter(a => norm(a.name).includes(n));
    const pls = st.playlists.filter(p => p.inLibrary && norm(p.name).includes(n));
    return { tracks, albums, artists, pls };
  }
  function results() {
    if (!q.trim()) return `<section class="block" data-od-id="search-recents"><div class="block-head"><h2>Búsquedas recientes</h2>${st.recents.length ? '<button class="link" data-act="recents-clear">Borrar todas</button>' : ''}</div>
      ${st.recents.length ? `<div class="recents">${st.recents.map((r, i) => `<span class="chip"><button data-act="recent" data-q="${esc(r)}">${esc(r)}</button><button class="x" data-act="recent-del" data-i="${i}" aria-label="Quitar ${esc(r)}">${ic('x')}</button></span>`).join('')}</div>` : '<p class="meta">Sin búsquedas recientes.</p>'}
      <p class="meta" style="margin-top:28px;display:flex;gap:8px;align-items:center">${ic('link')} También puedes pegar el enlace de una playlist pública de YouTube para importarla.</p></section>
      <section class="block"><div class="block-head"><h2>Explorar tu catálogo</h2></div><div class="grid-cards">${D.ALBUMS.slice(0, 6).map(albumCard).join('')}</div></section>`;
    if (isYtUrl(q)) {
      const p = pl('pl-yt-cumbia');
      return `<div class="url-card" data-od-id="search-url-card"><div style="width:64px;height:64px;border-radius:10px;overflow:hidden">${plArt(p)}</div><div style="flex:1;min-width:200px"><span class="tag">${ic('link')} Playlist de YouTube detectada</span><div style="font-weight:650;margin-top:6px">${esc(p.name)}</div><div class="meta">${plural(p.tracks.length, 'canción', 'canciones')} · ${fmtLong(plDur(p))} · ${esc(p.owner)}</div></div><a class="btn btn-secondary" href="#/playlist/${p.id}">Ver vista previa</a></div>`;
    }
    const r = search(q);
    const total = r.tracks.length + r.albums.length + r.artists.length + r.pls.length;
    if (!total) return `<div class="block">${emptyState('search', `Sin resultados para “${esc(q)}”`, 'Revisa la ortografía o prueba con el nombre del artista.')}</div>`;
    const chips = [['all', 'Todo'], ['songs', 'Canciones'], ['albums', 'Álbumes'], ['artists', 'Artistas'], ['playlists', 'Playlists']];
    const top = r.artists[0] ? { kind: 'Artista', t: r.artists[0].name, img: D.album(r.artists[0].albums[0]).cover, href: `#/artista/${r.artists[0].id}`, act: `data-act="radio-artist" data-id="${r.artists[0].id}"` } : r.albums[0] ? { kind: 'Álbum', t: r.albums[0].title, img: r.albums[0].cover, href: `#/album/${r.albums[0].id}`, act: `data-act="play-album" data-id="${r.albums[0].id}"` } : { kind: 'Canción', t: r.tracks[0].title, img: r.tracks[0].cover, href: `#/album/${r.tracks[0].albumId}`, act: `data-act="play-one" data-id="${r.tracks[0].id}"` };
    let body = '';
    if (filter === 'all') body = `<div class="top-result block" style="margin-top:20px"><div><div class="block-head"><h2>Mejor resultado</h2></div><div class="top-card" data-od-id="search-top"><a href="${top.href}"><img src="${top.img}" alt="" width="96" height="96"></a><a href="${top.href}"><h3>${esc(top.t)}</h3></a><span class="tag" style="align-self:flex-start">${top.kind}</span><button class="hover-play" style="opacity:1;transform:none;right:20px;bottom:20px" ${top.act} aria-label="Reproducir">${ic('play', 'fill')}</button></div></div>
      <div><div class="block-head"><h2>Canciones</h2></div><div class="tracks no-alb">${r.tracks.slice(0, 4).map((t, i) => row(t, i)).join('') || '<p class="meta">Sin canciones.</p>'}</div></div></div>
      ${r.albums.length ? `<section class="block"><div class="block-head"><h2>Álbumes</h2></div><div class="grid-cards">${r.albums.map(albumCard).join('')}</div></section>` : ''}
      ${r.pls.length ? `<section class="block"><div class="block-head"><h2>Playlists</h2></div><div class="grid-cards">${r.pls.map(plCard).join('')}</div></section>` : ''}`;
    if (filter === 'songs') body = `<div class="block" style="margin-top:20px">${tracksBlock(r.tracks)}</div>`;
    if (filter === 'albums') body = `<div class="grid-cards block" style="margin-top:20px">${r.albums.map(albumCard).join('') || '<p class="meta">Sin álbumes.</p>'}</div>`;
    if (filter === 'artists') body = `<div class="grid-cards block" style="margin-top:20px">${r.artists.map(a => card(`#/artista/${a.id}`, `<img src="${a.photo ? a.photo.src : D.album(a.albums[0]).cover}" alt="${esc(a.name)}" style="object-fit:cover">`, a.name, 'Artista', '', 'artist-card-' + a.id)).join('') || '<p class="meta">Sin artistas.</p>'}</div>`;
    if (filter === 'playlists') body = `<div class="grid-cards block" style="margin-top:20px">${r.pls.map(plCard).join('') || '<p class="meta">Sin playlists propias con ese nombre.</p>'}</div>`;
    return `<div class="row-chips" style="display:flex;gap:8px;flex-wrap:wrap;margin-top:20px" role="group" aria-label="Filtrar por tipo" data-od-id="search-filters">${chips.map(([v, l]) => `<button class="chip" data-act="filter" data-v="${v}" aria-pressed="${filter === v}">${l}</button>`).join('')}</div>${body}`;
  }

  const dlBtn = key => `<button class="icon-btn" data-act="download" data-id="${key}" aria-label="${st.downloads[key] ? 'Descargado' : 'Descargar'}" id="dl-${key}">${ic(st.downloads[key] ? 'check' : 'dl')}</button>`;
  const tint = p => `<div class="tint" style="--tint: rgb(${p[0].join(' ')})"></div>`;

  V.album = id => {
    const a = D.album(id); if (!a) return emptyState('album', 'Álbum no encontrado', 'NOT_FOUND');
    const more = D.ARTISTS[a.artistId].albums.filter(x => x !== id).map(D.album);
    return `${tint(a.palette)}<section class="hero" data-od-id="album-hero" style="--glow: rgb(${a.palette[0].join(' ')} / .6)"><div class="cover"><img src="${a.cover}" alt="Portada de ${esc(a.title)}" width="600" height="600"></div>
      <div><span class="eyebrow">Álbum · ${esc(a.genre)}</span><h1>${esc(a.title)}</h1><div class="facts"><a href="#/artista/${a.artistId}">${esc(a.artist)}</a><span class="num">${a.year}</span><span>${plural(a.tracks.length, 'canción', 'canciones')}</span><span class="num">${fmtLong(a.total)}</span></div></div></section>
      <div class="actions" data-od-id="album-actions"><button class="play-btn" data-act="play-album" data-id="${id}" aria-label="Reproducir álbum">${ic('play', 'fill')}</button><button class="icon-btn" data-act="shuffle-album" data-id="${id}" aria-label="Reproducir en aleatorio">${ic('shuffle')}</button>${dlBtn(id)}<button class="btn btn-ghost" data-act="save-as-pl" data-id="${id}">${ic('plus')}Guardar como playlist</button></div>
      <section data-od-id="album-tracks">${tracksBlock(a.tracks, { noAlb: true, noArt: true, list: 'album:' + id })}</section>
      <p class="meta" style="margin-top:20px">© ${a.year} ${esc(a.artist)}</p>
      ${more.length ? `<section class="block" data-od-id="album-more"><div class="block-head"><h2>Más de ${esc(a.artist)}</h2><a class="link" href="#/artista/${a.artistId}">Ver artista</a></div><div class="grid-cards">${more.map(albumCard).join('')}</div></section>` : ''}`;
  };

  V.artista = id => {
    const ar = D.ARTISTS[id]; if (!ar) return emptyState('user', 'Artista no encontrado', 'NOT_FOUND');
    const albums = ar.albums.map(D.album);
    const popular = (ar.popular || albums.flatMap(a => a.tracks.slice(0, 3))).slice(0, 6).map(x => typeof x === 'string' ? D.TRACKS[x] : x);
    const heroImg = ar.photo ? `<div class="artist-hero" data-od-id="artist-hero"><img src="${ar.photo.src}" alt="${esc(ar.name)} en vivo" width="${ar.photo.w}" height="${ar.photo.h}"><div class="cap"><div><span class="eyebrow" style="color:oklch(92% 0 0)">Artista</span><h1>${esc(ar.name)}</h1></div><span class="credit">${ar.photo.credit}</span></div></div>`
      : `${tint(albums[0].palette)}<section class="hero" data-od-id="artist-hero"><div class="cover" style="border-radius:50%"><img src="${albums[0].cover}" alt="" width="600" height="600"></div><div><span class="eyebrow">Artista</span><h1>${esc(ar.name)}</h1><div class="facts"><span>${plural(albums.length, 'álbum', 'álbumes')} en el catálogo de ejemplo</span></div></div></section>`;
    return `${heroImg}<div class="actions" data-od-id="artist-actions"><button class="play-btn" data-act="play-ids" data-ids="${popular.map(t => t.id).join(',')}" aria-label="Reproducir populares">${ic('play', 'fill')}</button><button class="btn btn-secondary" data-act="radio-artist" data-id="${id}">${ic('radio')}Radio del artista</button></div>
      <section data-od-id="artist-popular"><div class="block-head"><h2>Populares</h2></div>${tracksBlock(popular, { list: 'ids:' + popular.map(t => t.id).join(',') })}</section>
      <section class="block" data-od-id="artist-albums"><div class="block-head"><h2>Álbumes</h2></div><div class="grid-cards">${albums.map(albumCard).join('')}</div></section>
      <section class="block" data-od-id="artist-singles"><div class="block-head"><h2>Sencillos</h2></div><p class="meta">Los datos de ejemplo no incluyen sencillos; en la app los entrega <span class="mono">GET /v1/artists/{id}</span>.</p></section>`;
  };

  let editing = false;
  V.playlist = id => {
    const p = pl(id); if (!p) return emptyState('queue', 'Playlist no encontrada', 'Puede que se haya borrado en otro dispositivo.', '<a class="btn btn-secondary" href="#/biblioteca">Ir a la biblioteca</a>');
    const ts = estado === 'vacio' ? [] : p.tracks.map(x => D.TRACKS[x]);
    const own = p.source === 'own';
    const first = D.TRACKS[p.tracks[0]];
    return `${first ? tint(first.palette) : ''}<section class="hero" data-od-id="playlist-hero"><div class="cover">${plArt(p)}</div>
      <div><span class="eyebrow">${own ? 'Playlist propia' : p.inLibrary ? 'Importada de YouTube' : 'Playlist de YouTube · vista previa'}</span>
      ${editing ? `<form data-form="rename" style="margin:10px 0 14px;display:flex;gap:8px;max-width:520px"><input class="input" name="name" value="${esc(p.name)}" aria-label="Nombre de la playlist" maxlength="60" style="font-size:22px;height:52px;font-weight:650"><button class="btn btn-secondary" type="submit">Guardar</button></form>` : `<h1>${esc(p.name)}</h1>`}
      <div class="facts"><span>${plural(ts.length, 'canción', 'canciones')}</span><span class="num">${fmtLong(ts.reduce((s, t) => s + t.dur, 0))}</span>${own ? `<span>Creada el ${new Date(p.created).toLocaleDateString('es-CO', { day: 'numeric', month: 'short' })}</span>` : `<span class="tag">${ic('link')} youtube.com/playlist?list=${p.sourceId}</span>`}</div></div></section>
      <div class="actions" data-od-id="playlist-actions"><button class="play-btn" data-act="play-pl" data-id="${id}" aria-label="Reproducir playlist" ${ts.length ? '' : 'disabled'}>${ic('play', 'fill')}</button><button class="icon-btn" data-act="shuffle-pl" data-id="${id}" aria-label="Reproducir en aleatorio">${ic('shuffle')}</button>${dlBtn(id)}
      ${own ? `<button class="icon-btn" data-act="rename" aria-label="Renombrar">${ic('edit')}</button><button class="icon-btn" data-act="pl-delete" data-id="${id}" aria-label="Borrar playlist">${ic('trash')}</button>` : p.inLibrary ? '' : `<button class="btn btn-secondary" data-act="import" data-id="${id}" data-od-id="import-cta">${ic('plus')}Importar a mi biblioteca</button>`}</div>
      <section data-od-id="playlist-tracks">${ts.length ? tracksBlock(ts, { grip: own, remove: own, editable: own, list: 'pl:' + id }) : emptyState('search', 'Esta playlist está vacía', 'Agrega canciones desde la búsqueda con el menú ⋯ de cada fila.', '<a class="btn btn-secondary" href="#/buscar">Buscar canciones</a>')}</section>
      ${own && ts.length ? '<p class="meta" style="margin-top:14px">Arrastra desde ⠿ para reordenar. Los cambios se sincronizan con tus otros dispositivos.</p>' : ''}`;
  };

  let libTab = 'playlists', libSort = 'recent';
  V.biblioteca = tab => {
    libTab = tab || libTab;
    const tabs = [['playlists', 'Playlists'], ['favoritos', 'Favoritos'], ['descargas', 'Descargas'], ['historial', 'Historial']];
    return `<div class="view-head"><h1>Biblioteca</h1><button class="btn btn-secondary" data-act="new-pl" data-od-id="new-playlist" ${libTab === 'playlists' ? '' : 'hidden'}>${ic('plus')}Nueva playlist</button></div>
      <div class="tabs" role="tablist" data-od-id="library-tabs">${tabs.map(([v, l]) => `<a class="tab" role="tab" href="#/biblioteca/${v}" aria-selected="${libTab === v}" data-tab="${v}" style="display:inline-flex;align-items:center">${l}</a>`).join('')}<span class="ind"></span></div>
      <div id="lib-body" data-od-id="library-${libTab}">${libBody()}</div>`;
  };
  function libBody() {
    if (estado === 'vacio') return emptyState(libTab === 'favoritos' ? 'heart' : libTab === 'descargas' ? 'dl' : 'queue', { playlists: 'Aún no tienes playlists', favoritos: 'Sin favoritos', descargas: 'Nada descargado', historial: 'Sin historial' }[libTab], { playlists: 'Crea una o importa una playlist de YouTube pegando su enlace.', favoritos: 'Toca el corazón de cualquier canción para guardarla aquí.', descargas: 'Descarga una playlist antes de quedarte sin señal.', historial: 'Lo que escuches en el celular y en el PC aparece aquí.' }[libTab], libTab === 'playlists' ? '<button class="btn btn-secondary" data-act="new-pl">Crear playlist</button>' : '');
    if (libTab === 'playlists') {
      let ps = st.playlists.filter(p => p.inLibrary);
      ps = libSort === 'az' ? ps.slice().sort((a, b) => a.name.localeCompare(b.name, 'es')) : ps.slice().sort((a, b) => b.created.localeCompare(a.created));
      return `<div style="display:flex;justify-content:flex-end;margin-bottom:16px">${seg('lib-sort', [['recent', 'Recientes'], ['az', 'A–Z']], libSort)}</div><div class="grid-cards">${ps.map(plCard).join('')}</div>`;
    }
    if (libTab === 'favoritos') return st.favorites.length ? tracksBlock(st.favorites.map(x => D.TRACKS[x]), { list: 'fav' }) : emptyState('heart', 'Sin favoritos', 'Toca el corazón de cualquier canción para guardarla aquí.');
    if (libTab === 'descargas') {
      const keys = Object.keys(st.downloads); const used = keys.reduce((s, k) => s + st.downloads[k].size, 0);
      return `<div class="set-group" style="padding:18px" data-od-id="downloads-usage"><div style="display:flex;justify-content:space-between;gap:12px;flex-wrap:wrap"><b>Espacio usado</b><span class="num meta">${used.toFixed(1)} MB de ${st.settings.limit} GB</span></div><div class="usage" aria-hidden="true"><i style="width:${Math.max(1.5, used / (st.settings.limit * 1024) * 100)}%"></i></div><p class="meta" style="margin-top:10px">${st.settings.wifiOnly ? 'Las descargas solo se hacen con Wi-Fi.' : 'Las descargas también usan datos móviles.'} <a class="link" href="#/ajustes">Cambiar</a></p></div>
        ${keys.length ? `<div class="tracks">${keys.map(k => { const p = pl(k), a = D.album(k), o = p || a; return `<div class="row" style="grid-template-columns:56px 1fr auto 44px" data-od-id="download-${k}"><a href="#/${p ? 'playlist' : 'album'}/${k}" style="width:52px;height:52px;border-radius:8px;overflow:hidden">${p ? plArt(p) : `<img src="${a.cover}" alt="">`}</a><a href="#/${p ? 'playlist' : 'album'}/${k}"><div class="rt">${esc(p ? p.name : a.title)}</div><div class="ra">${ic('check', 'dl-dot')}${plural(o.tracks.length, 'canción', 'canciones')} descargadas</div></a><span class="num meta">${st.downloads[k].size.toFixed(1)} MB</span><button class="icon-btn sm" data-act="dl-del" data-id="${k}" aria-label="Borrar descarga">${ic('trash')}</button></div>`; }).join('')}</div>` : emptyState('dl', 'Nada descargado', 'Descarga una playlist antes de quedarte sin señal.')}`;
    }
    const groups = {};
    st.history.forEach(e => { const d = e.at.slice(0, 10); (groups[d] = groups[d] || []).push(e); });
    const today = '2026-10-05';
    const label = d => d === today ? 'Hoy' : d === '2026-10-04' ? 'Ayer' : new Date(d + 'T12:00').toLocaleDateString('es-CO', { weekday: 'long', day: 'numeric', month: 'short' });
    return Object.entries(groups).map(([d, es]) => `<section class="block" style="margin-top:24px"><div class="block-head"><h2 style="font-size:16px;text-transform:capitalize">${label(d)}</h2></div><div class="tracks no-alb">${es.map((e, i) => { const t = D.TRACKS[e.id]; return row(t, i, { num: '' }).replace('<span class="num">', `<span class="tag" style="margin-right:6px">${ic(e.device === 'PC' ? 'pc' : 'phone')}${e.device} · ${e.at.slice(11)}</span><span class="num">`); }).join('')}</div></section>`).join('');
  }
  const seg = (name, opts, val) => `<div class="seg" data-seg="${name}" role="group">${'<span class="thumb"></span>'}${opts.map(([v, l]) => `<button data-v="${v}" aria-pressed="${val === v}">${l}</button>`).join('')}</div>`;

  V.ajustes = () => {
    const s = st.settings;
    return `<div class="view-head"><h1>Ajustes</h1></div><div style="max-width:760px">
      <section class="set-group" data-od-id="settings-backend"><h2>Backend</h2>
        <div class="set-row"><div class="l"><b>Servidor</b><span class="meta mono">${esc(s.url)}</span></div><span class="status ${estado === 'offline' ? 'bad' : 'ok'}" id="conn-status">${ic(estado === 'offline' ? 'off' : 'check')}${estado === 'offline' ? 'Sin respuesta' : 'Conectado · yt-dlp al día'}</span></div>
        <div class="set-row"><div class="l"><b>Token del dispositivo</b><span class="meta mono">${s.token.slice(0, 6)}••••••••••</span></div><div style="display:flex;gap:8px"><button class="btn btn-secondary" data-act="test-conn">Probar conexión</button><a class="btn btn-ghost" href="#/conexion">Configurar</a></div></div></section>
      <section class="set-group" data-od-id="settings-quality"><h2>Calidad de audio</h2>
        <div class="set-row"><div class="l"><b>Con Wi-Fi</b><span class="meta">Alta ≈ 160 kbps · ≈ 70 MB por hora</span></div>${seg('qWifi', [['high', 'Alta'], ['low', 'Ahorro']], s.qWifi)}</div>
        <div class="set-row"><div class="l"><b>Con datos móviles</b><span class="meta">Ahorro ≈ 50 kbps · ≈ 22 MB por hora</span></div>${seg('qData', [['high', 'Alta'], ['low', 'Ahorro']], s.qData)}</div></section>
      <section class="set-group" data-od-id="settings-downloads"><h2>Descargas</h2>
        <div class="set-row"><div class="l"><b>Descargar solo con Wi-Fi</b></div><button class="switch" role="switch" aria-checked="${s.wifiOnly}" data-act="sw" data-k="wifiOnly" aria-label="Descargar solo con Wi-Fi"></button></div>
        <div class="set-row"><div class="l"><b>Límite de espacio</b><span class="meta num" id="limit-val">${s.limit} GB</span></div><input type="range" min="1" max="32" value="${s.limit}" data-k="limit" aria-label="Límite de espacio en GB"></div>
        <div class="set-row"><div class="l"><b>Borrar todas las descargas</b><span class="meta">${plural(Object.keys(st.downloads).length, 'lista', 'listas')} descargadas</span></div><button class="btn btn-secondary" data-act="dl-clear">Borrar</button></div></section>
      <section class="set-group" data-od-id="settings-appearance"><h2>Apariencia y movimiento</h2>
        <div class="set-row"><div class="l"><b>Tema</b></div>${seg('theme', [['light', 'Claro'], ['dark', 'Oscuro'], ['system', 'Sistema']], s.theme)}</div>
        <div class="set-row"><div class="l"><b>Animaciones</b><span class="meta">Reducidas desactiva el aura y el desplazamiento de la letra</span></div>${seg('motion', [['full', 'Completas'], ['reduced', 'Reducidas']], s.motion)}</div>
        <div class="set-row"><div class="l"><b>Visualizador al ritmo</b><span class="meta">La portada y el aura reaccionan al audio</span></div><button class="switch" role="switch" aria-checked="${s.reactive}" data-act="sw" data-k="reactive" aria-label="Visualizador al ritmo"></button></div></section>
      <section class="set-group" data-od-id="settings-backup"><h2>Respaldo y caché</h2>
        <div class="set-row"><div class="l"><b>Biblioteca en JSON</b><span class="meta">Playlists, favoritos e historial</span></div><div style="display:flex;gap:8px"><button class="btn btn-secondary" data-act="export">Exportar</button><label class="btn btn-ghost" style="cursor:pointer">Importar<input type="file" accept="application/json" data-act="import-json" class="sr"></label></div></div>
        <div class="set-row"><div class="l"><b>Caché de metadatos y portadas</b></div><button class="btn btn-secondary" data-act="cache-clear">Borrar caché</button></div>
        <div class="set-row"><div class="l"><b>Versión</b><span class="meta mono">App 0.1.0 (prototipo) · Backend: sin datos en el prototipo</span></div></div></section></div>`;
  };

  let onbStep = 0, testRes = null;
  V.conexion = () => {
    const s = st.settings;
    const steps = `<div class="steps" aria-label="Paso ${onbStep + 1} de 3">${[0, 1, 2].map(i => `<i style="--p:${i <= onbStep ? 1 : 0}"></i>`).join('')}</div>`;
    let body;
    if (onbStep === 0) body = `<p class="eyebrow">Paso 1 de 3 · Conexión</p><h1 style="margin-top:12px">Conecta tu backend</h1><p class="lead">La app solo habla con tu servidor del homelab por Tailscale. Nunca contacta a YouTube directamente.</p>
      <form data-form="conn" style="display:flex;flex-direction:column;gap:16px"><div class="field"><label for="f-url">URL del backend</label><input class="input mono" id="f-url" name="url" value="${esc(s.url)}" required></div>
      <div class="field"><label for="f-token">Token del dispositivo</label><input class="input mono${testRes === 'bad' ? ' bad' : ''}" id="f-token" name="token" value="${esc(s.token)}" required></div>
      <div id="test-out" style="min-height:24px">${testRes === 'ok' ? `<span class="status ok">${ic('check')}Conexión correcta · el backend responde y la extracción funciona</span>` : testRes === 'bad' ? `<span class="status bad">${ic('x')}UNAUTHORIZED · revisa el token</span>` : testRes === 'run' ? '<span class="status meta"><span class="spin"></span>Probando conexión…</span>' : '<span class="meta">Prueba: cualquier token que empiece por “od_” funciona.</span>'}</div>
      <div style="display:flex;gap:10px;justify-content:space-between;flex-wrap:wrap"><button class="btn btn-secondary" type="button" data-act="onb-test">Probar conexión</button><button class="btn btn-primary" type="submit" ${testRes === 'ok' ? '' : 'disabled'}>Guardar y continuar</button></div></form>`;
    if (onbStep === 1) body = `<p class="eyebrow">Paso 2 de 3 · Segundo plano</p><h1 style="margin-top:12px">Que no se corte con la pantalla apagada</h1><p class="lead">Android necesita dos permisos para mantener la música sonando en el bolsillo.</p>
      <div class="perm"><span class="ic">${ic('bell')}</span><div style="flex:1"><b>Notificaciones</b><p class="meta">Muestra los controles en la notificación y en la pantalla de bloqueo.</p></div><button class="switch" role="switch" aria-checked="false" data-act="perm" aria-label="Permitir notificaciones"></button></div>
      <div class="perm"><span class="ic">${ic('battery')}</span><div style="flex:1"><b>Excluir de la optimización de batería</b><p class="meta">Evita que MIUI o One UI cierren el servicio de reproducción.</p></div><button class="switch" role="switch" aria-checked="false" data-act="perm" aria-label="Excluir de la optimización de batería"></button></div>
      <div style="display:flex;justify-content:space-between;margin-top:20px"><button class="btn btn-ghost" data-act="onb-back">Atrás</button><button class="btn btn-primary" data-act="onb-next">Continuar</button></div>`;
    if (onbStep === 2) body = `<p class="eyebrow">Paso 3 de 3 · Listo</p><h1 style="margin-top:12px">Todo listo</h1><p class="lead">Tu biblioteca se sincronizó desde el backend: ${plural(st.playlists.filter(p => p.inLibrary).length, 'playlist', 'playlists')}, ${plural(st.favorites.length, 'favorito', 'favoritos')} y tu historial.</p>
      <div style="display:flex;justify-content:space-between;margin-top:8px"><button class="btn btn-ghost" data-act="onb-back">Atrás</button><a class="btn btn-primary" href="#/inicio">Empezar a escuchar</a></div>`;
    return `<div class="onb" data-od-id="onboarding"><div class="onb-card"><div class="brand" style="padding:0 0 28px"><span class="brand-mark"><svg class="i"><use href="#i-wave"/></svg></span>Onda</div>${steps}${body}</div></div>`;
  };

  /* ── router ── */
  let route = '';
  function render(keepScroll) {
    const [path, qs] = (location.hash.slice(1) || '/inicio').split('?');
    const params = new URLSearchParams(qs || '');
    if (params.has('estado')) estado = params.get('estado');
    document.body.classList.toggle('is-offline', estado === 'offline');
    $('#conn').classList.toggle('off', estado === 'offline');
    $('#conn').textContent = estado === 'offline' ? 'Sin conexión' : 'Conectado · homelab';
    const [, name, arg] = path.split('/');
    const view = V[name] ? name : 'inicio';
    // cambio de pestaña dentro de Biblioteca: solo cambia el cuerpo; el indicador se estira
    if (view === 'biblioteca' && route === 'biblioteca' && $('#lib-body') && !estado) {
      libTab = arg || libTab;
      $$('.tabs .tab').forEach(t => t.setAttribute('aria-selected', t.dataset.tab === libTab));
      const body = $('#lib-body'); body.dataset.odId = 'library-' + libTab;
      body.innerHTML = libBody(); body.classList.remove('swap'); void body.offsetWidth; body.classList.add('swap');
      $('[data-od-id="new-playlist"]').hidden = libTab !== 'playlists';
      afterRender(); return;
    }
    route = view;
    const html = estado === 'cargando' && !['ajustes', 'conexion', 'buscar'].includes(view) ? skeleton() : estado === 'error' && !['ajustes', 'conexion'].includes(view) ? errorState() : V[view](arg);
    const el = $('#view');
    el.className = 'view'; el.innerHTML = html;
    [...el.children].forEach((c, i) => c.style.setProperty('--i', Math.min(i, 8)));
    $('#app').classList.toggle('solo', view === 'conexion');
    $$('.side, .bar, .tabbar, .qpanel').forEach(x => x.style.display = view === 'conexion' ? 'none' : '');
    $$('[data-nav]').forEach(a => a.setAttribute('aria-current', a.dataset.nav === (['album', 'artista', 'playlist'].includes(view) ? '' : view) ? 'page' : 'false'));
    if (!keepScroll) $('#main').scrollTo({ top: 0 });
    afterRender();
    placePills();
    flyIn();
  }
  /* indicadores elásticos de navegación (barra lateral y pestañas móviles) */
  function placePills() {
    const a = $('.side .nav-item[aria-current="page"]');
    Liquid.stretch($('.nav-pill'), a ? { p: a.offsetTop, s: a.offsetHeight } : { p: 0, s: 40, hide: true }, 'y');
    const b = $('.tabbar a[aria-current="page"]');
    if ($('.tabbar').offsetWidth) Liquid.stretch($('.tab-blob'), b ? { p: b.offsetLeft + b.offsetWidth / 2 - 30, s: 60 } : { p: 0, s: 60, hide: true });
  }
  addEventListener('resize', () => { $$('.nav-pill, .tab-blob').forEach(x => { x.style.left = x.style.top = ''; }); placePills(); });
  /* la portada de la tarjeta fluye hasta la portada del detalle */
  let fly = null;
  document.addEventListener('click', e => { const art = e.target.closest('.card .art, .resume'); const img = art && art.querySelector('img'); fly = img && !Liquid.reduced() ? { r: img.getBoundingClientRect(), at: performance.now() } : null; }, true);
  function flyIn() {
    if (!fly || performance.now() - fly.at > 800) { fly = null; return; }
    const c = $('.hero .cover'); if (!c) { fly = null; return; }
    const r = c.getBoundingClientRect(), f = fly.r; fly = null;
    c.animate([
      { transform: `translate(${f.left - r.left}px, ${f.top - r.top - 10}px) scale(${f.width / r.width})`, borderRadius: '12px', transformOrigin: '0 0' },
      { borderRadius: '42% 58% 50% 50% / 55% 45% 55% 45%', offset: 0.55, transformOrigin: '0 0' },
      { transform: 'none', borderRadius: '14px', transformOrigin: '0 0' }
    ], { duration: 640, easing: 'cubic-bezier(.2,.8,.2,1)' });
  }
  function afterRender() {
    $$('.tabs').forEach(t => { const a = t.querySelector('[aria-selected="true"]'), ind = t.querySelector('.ind'); if (a && ind) { if (!ind.style.width && lastInd) { ind.style.left = lastInd.p + 'px'; ind.style.width = lastInd.s + 'px'; } lastInd = { p: a.offsetLeft, s: a.offsetWidth }; Liquid.stretch(ind, lastInd); } });
    $$('.seg').forEach(placeThumb);
    const qi = $('#q'); if (qi && route === 'buscar' && !qi.dataset.bound) { qi.dataset.bound = 1; qi.addEventListener('input', onSearchInput); qi.addEventListener('keydown', onSearchKey); if (matchMedia('(min-width: 821px)').matches) qi.focus(); }
    $$('.tracks.editable').forEach(l => sortable(l, '.row', (from, to) => { const p = pl(l.dataset.list.slice(3)); const [x] = p.tracks.splice(from, 1); p.tracks.splice(to, 0, x); save(); toast('Orden guardado · se sincronizará'); render(true); }));
    renderSide();
  }
  let lastInd = null;
  function placeThumb(sg) { const on = sg.querySelector('button[aria-pressed="true"]'), th = sg.querySelector('.thumb'); if (on && th && on.offsetWidth) Liquid.stretch(th, { p: on.offsetLeft, s: on.offsetWidth }); }
  function renderSide() {
    $('#side-pls').innerHTML = st.playlists.filter(p => p.inLibrary).map(p => `<a class="side-pl" href="#/playlist/${p.id}" data-od-id="side-playlist-${p.id}">${plCovers(p)[0] ? `<img src="${plCovers(p)[0]}" alt="">` : ''}<span style="min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${esc(p.name)}</span></a>`).join('');
  }
  window.addEventListener('hashchange', () => { closeMenus(); editing = false; render(); });

  /* ── búsqueda en vivo ── */
  let hl = -1;
  function onSearchInput(e) {
    q = e.target.value; filter = 'all';
    $('.search-box .clear').style.display = q ? '' : 'none';
    $('#results').innerHTML = results(); afterRender();
    const n = norm(q.trim()); const box = $('#suggest'); hl = -1;
    if (!n || isYtUrl(q)) { box.innerHTML = ''; return; }
    const pool = [...new Set([...Object.values(D.ARTISTS).map(a => a.name), ...D.ALBUMS.map(a => a.title), ...Object.values(D.TRACKS).map(t => t.title)])];
    const sug = pool.filter(s => norm(s).includes(n) && norm(s) !== n).slice(0, 5);
    box.innerHTML = sug.length ? `<div class="suggest" role="listbox">${sug.map(s => { const i = norm(s).indexOf(n); return `<button role="option" data-act="sug" data-q="${esc(s)}">${ic('search')}<span>${esc(s.slice(0, i))}<b>${esc(s.slice(i, i + n.length))}</b>${esc(s.slice(i + n.length))}</span></button>`; }).join('')}</div>` : '';
  }
  function onSearchKey(e) {
    const opts = $$('#suggest button');
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') { e.preventDefault(); hl = (hl + (e.key === 'ArrowDown' ? 1 : -1) + opts.length) % opts.length; opts.forEach((o, i) => o.classList.toggle('hl', i === hl)); }
    if (e.key === 'Enter') { if (hl >= 0 && opts[hl]) opts[hl].click(); else commitSearch(q); }
    if (e.key === 'Escape') $('#suggest').innerHTML = '';
  }
  function commitSearch(s) {
    q = s; $('#q').value = s; $('#suggest').innerHTML = '';
    if (s.trim() && !isYtUrl(s)) { st.recents = [s.trim().toLowerCase(), ...st.recents.filter(r => r !== s.trim().toLowerCase())].slice(0, 8); save(); }
    $('.search-box .clear').style.display = s ? '' : 'none';
    $('#results').innerHTML = results(); afterRender();
  }

  /* ── menús y diálogos ── */
  function closeMenus() { $$('.menu, .scrim').forEach(x => x.remove()); }
  function menu(anchor, items) {
    closeMenus();
    const scrim = document.createElement('div'); scrim.className = 'scrim'; scrim.onclick = closeMenus;
    const m = document.createElement('div'); m.className = 'menu'; m.setAttribute('role', 'menu');
    m.innerHTML = items.map(it => it === '-' ? '<hr>' : `<button role="menuitem" data-k="${it[0]}">${ic(it[1], it[3] || '')}${it[2]}</button>`).join('');
    document.body.append(scrim, m);
    const r = anchor.getBoundingClientRect(), mh = m.offsetHeight, mw = m.offsetWidth;
    m.style.top = Math.max(8, r.bottom + mh + 8 > innerHeight ? r.top - mh - 6 : r.bottom + 6) + 'px';
    m.style.left = Math.max(8, Math.min(innerWidth - mw - 8, r.right - mw)) + 'px';
    m.querySelector('button').focus();
    return new Promise(res => m.addEventListener('click', e => { const b = e.target.closest('button'); if (b) { closeMenus(); res(b.dataset.k); } }));
  }
  function dialog(html, onSubmit) {
    const w = document.createElement('div'); w.className = 'dialog-wrap';
    w.innerHTML = `<div class="dialog" role="dialog" aria-modal="true">${html}</div>`;
    document.body.append(w);
    const close = () => w.remove();
    w.addEventListener('click', e => { if (e.target === w || e.target.closest('[data-close]')) close(); });
    w.addEventListener('keydown', e => { if (e.key === 'Escape') close(); });
    w.querySelector('form')?.addEventListener('submit', e => { e.preventDefault(); onSubmit(new FormData(e.target), close); });
    (w.querySelector('input') || w.querySelector('button')).focus();
    return { el: w, close };
  }
  function newPlaylist(seed, then) {
    dialog(`<h2>Nueva playlist</h2><p class="meta">Se sincroniza con tus otros dispositivos.</p><form style="margin-top:16px"><div class="field"><label for="np-name">Nombre</label><input class="input" id="np-name" name="name" required maxlength="60" placeholder="Por ejemplo: Para correr"></div><div class="dialog-actions"><button type="button" class="btn btn-ghost" data-close>Cancelar</button><button class="btn btn-primary" type="submit">Crear</button></div></form>`, (fd, close) => {
      const p = { id: 'pl-' + Date.now().toString(36), name: fd.get('name').trim(), source: 'own', created: new Date().toISOString().slice(0, 10), tracks: seed || [], inLibrary: true };
      st.playlists.unshift(p); save(); close(); renderSide();
      then ? then(p) : (toast(`Playlist “${esc(p.name)}” creada`, { action: 'Abrir', onAction: () => location.hash = '#/playlist/' + p.id }), render(true));
    });
  }
  function addToPlaylist(tid) {
    const own = st.playlists.filter(p => p.source === 'own' && p.inLibrary);
    const d = dialog(`<h2>Agregar a playlist</h2><p class="meta">${esc(D.TRACKS[tid].title)} · ${esc(D.TRACKS[tid].artist)}</p><div class="opts"><button data-new>${'<span style="width:44px;height:44px;border-radius:6px;display:grid;place-items:center;background:var(--fg-soft-2)">' + ic('plus') + '</span>'}Nueva playlist</button>${own.map(p => `<button data-pl="${p.id}"><span style="width:44px;height:44px;border-radius:6px;overflow:hidden;flex:none">${plArt(p)}</span><span>${esc(p.name)}<span class="meta" style="display:block;font-weight:400">${p.tracks.includes(tid) ? 'Ya está en esta playlist' : plural(p.tracks.length, 'canción', 'canciones')}</span></span></button>`).join('')}</div><div class="dialog-actions"><button class="btn btn-ghost" data-close>Cancelar</button></div>`);
    d.el.addEventListener('click', e => {
      const b = e.target.closest('[data-pl],[data-new]'); if (!b) return;
      d.close();
      const done = p => { if (!p.tracks.includes(tid)) p.tracks.push(tid); save(); renderSide(); toast(`Agregada a “${esc(p.name)}”`, { action: 'Ver', onAction: () => location.hash = '#/playlist/' + p.id }); if (route === 'playlist') render(true); };
      if (b.dataset.new !== undefined) newPlaylist([tid], done); else done(pl(b.dataset.pl));
    });
  }
  async function rowMenu(btn, tid) {
    const t = D.TRACKS[tid], f = isFav(tid);
    const k = await menu(btn, [['next', 'queue', 'Reproducir a continuación'], ['queue', 'plus', 'Agregar a la cola'], ['pl', 'lib', 'Agregar a playlist…'], ['fav', 'heart', f ? 'Quitar de favoritos' : 'Agregar a favoritos', f ? 'fill' : ''], '-', ['album', 'album', 'Ir al álbum'], ['artist', 'user', 'Ir al artista'], ['radio', 'radio', 'Iniciar radio'], ['dl', 'dl', 'Descargar']]);
    if (k === 'next') { P.playNext(tid); toast('Sonará a continuación'); }
    if (k === 'queue') { P.addToQueue(tid); toast('Agregada a la cola'); }
    if (k === 'pl') addToPlaylist(tid);
    if (k === 'fav') toggleFav(tid);
    if (k === 'album') location.hash = '#/album/' + t.albumId;
    if (k === 'artist') location.hash = '#/artista/' + t.artistId;
    if (k === 'radio') startRadio(t);
    if (k === 'dl') toast(`Descargando “${esc(t.title)}”…`);
  }
  function startRadio(t) {
    const pool = Object.values(D.TRACKS).filter(x => x.id !== t.id && !x.unavailable && (x.artistId === t.artistId || D.album(x.albumId).genre === D.album(t.albumId).genre));
    const rest = Object.values(D.TRACKS).filter(x => !pool.includes(x) && x.id !== t.id && !x.unavailable).sort(() => Math.random() - .5);
    P.play([t.id, ...pool.sort(() => Math.random() - .5), ...rest].slice(0, 25).map(x => x.id));
    window.NP && (window.NP.from = 'Radio de ' + t.title);
    toast(`Radio de “${esc(t.title)}” · 25 canciones relacionadas`);
  }
  function toggleFav(tid) {
    const on = !isFav(tid);
    st.favorites = on ? [tid, ...st.favorites] : st.favorites.filter(x => x !== tid); save();
    $$(`[data-tid="${tid}"] .fav`).forEach(b => { b.classList.toggle('on', on); b.setAttribute('aria-pressed', on); b.innerHTML = ic('heart', on ? 'fill' : ''); });
    syncFavButtons();
    toast(on ? 'Agregada a favoritos' : 'Quitada de favoritos', { action: 'Deshacer', onAction: () => toggleFav(tid) });
    if (route === 'biblioteca' && libTab === 'favoritos') render(true);
  }
  function syncFavButtons() { const t = P.current(); if (!t) return; const on = isFav(t.id); ['#bar-fav', '#np-fav'].forEach(s => { const b = $(s); if (b) { b.innerHTML = ic('heart', on ? 'fill' : ''); b.classList.toggle('on', on); b.setAttribute('aria-pressed', on); } }); }

  function download(key, btn) {
    if (st.downloads[key]) { toast('Ya está disponible sin conexión'); return; }
    const o = pl(key) || D.album(key); const n = o.tracks.length; let i = 0;
    btn.innerHTML = `<svg viewBox="0 0 36 36" width="28" height="28" aria-hidden="true"><circle cx="18" cy="18" r="14" fill="none" stroke="var(--fg-soft-2)" stroke-width="3"/><circle id="ring" cx="18" cy="18" r="14" fill="none" stroke="var(--fg)" stroke-width="3" stroke-linecap="round" stroke-dasharray="88" stroke-dashoffset="88" transform="rotate(-90 18 18)" style="transition:stroke-dashoffset .3s"/></svg>`;
    btn.setAttribute('aria-label', 'Descargando');
    const tm = setInterval(() => {
      i++; const r = btn.querySelector('#ring'); if (r) r.style.strokeDashoffset = 88 - 88 * i / n;
      const rowEl = $$('.tracks .row')[i - 1]; if (rowEl) rowEl.querySelector('.ra')?.insertAdjacentHTML('afterbegin', ic('dl', 'dl-dot'));
      if (i >= n) { clearInterval(tm); st.downloads[key] = { size: +(n * 3.4).toFixed(1) }; save(); btn.innerHTML = ic('check'); btn.setAttribute('aria-label', 'Descargado'); toast(`${plural(n, 'canción descargada', 'canciones descargadas')} · disponible sin conexión`); }
    }, 260);
  }

  /* ── reordenar arrastrando (cola y playlists propias) ── */
  function sortable(list, sel, onDrop) {
    list.addEventListener('pointerdown', e => {
      const g = e.target.closest('[data-grip]'); if (!g) return;
      const item = g.closest(sel), items = $$(sel, list), from = items.indexOf(item);
      const h = item.offsetHeight, y0 = e.clientY; let to = from;
      item.classList.add('dragging'); item.setPointerCapture(e.pointerId); e.preventDefault();
      const move = ev => {
        const dy = ev.clientY - y0; item.style.transform = `translateY(${dy}px)`;
        to = Math.max(0, Math.min(items.length - 1, from + Math.round(dy / h)));
        items.forEach((it, i) => { if (it === item) return; const shift = (i > from && i <= to) ? -h : (i < from && i >= to) ? h : 0; it.style.transform = shift ? `translateY(${shift}px)` : ''; });
      };
      const up = () => { item.removeEventListener('pointermove', move); item.removeEventListener('pointerup', up); items.forEach(it => { it.style.transform = ''; }); item.classList.remove('dragging'); if (to !== from) onDrop(from, to); };
      item.addEventListener('pointermove', move); item.addEventListener('pointerup', up);
    });
  }

  /* ── cola (panel lateral y dentro del reproductor) ── */
  function queueHTML() {
    const cur = P.current();
    if (!cur) return emptyState('queue', 'La cola está vacía', 'Reproduce una canción o una playlist.');
    const qrow = (id, i) => { const t = D.TRACKS[id]; return `<div class="qrow${i === P.index ? ' current' : ''}" data-qi="${i}" data-od-id="queue-item-${i}"><span class="grip" data-grip aria-label="Arrastrar">${i === P.index ? '' : ic('grip', 'fill')}</span><img src="${t.cover}" alt="" width="40" height="40"><button style="min-width:0;text-align:left" data-act="q-play" data-i="${i}"><div class="rt">${esc(t.title)}</div><div class="ra">${esc(t.artist)}</div></button>${i === P.index ? '<span class="eq" style="justify-self:center"><i></i><i></i><i></i><i></i></span>' : `<button class="icon-btn sm" data-act="q-remove" data-i="${i}" aria-label="Quitar de la cola">${ic('x')}</button>`}</div>`; };
    const nextEnd = P.index + 1 + P.upNext;
    const up = P.queue.slice(P.index + 1, nextEnd), rest = P.queue.slice(nextEnd);
    return `<div class="q-head"><h2>Cola</h2><div style="display:flex;gap:4px"><button class="btn btn-ghost" style="height:36px;padding:0 10px" data-act="q-save">Guardar como playlist</button></div></div>
      <p class="eyebrow q-label">Sonando</p><div class="qlist" data-base="${P.index}">${qrow(P.queue[P.index], P.index)}</div>
      ${up.length ? `<p class="eyebrow q-label">A continuación</p><div class="qlist sortable" data-base="${P.index + 1}">${up.map((id, k) => qrow(id, P.index + 1 + k)).join('')}</div>` : ''}
      <div class="row-between" style="display:flex;justify-content:space-between;align-items:center"><p class="eyebrow q-label">${P.shuffle ? 'Después · aleatorio' : 'Después'}</p>${rest.length ? '<button class="link" data-act="q-clear" style="padding-top:10px">Limpiar</button>' : ''}</div>
      <div class="qlist sortable" data-base="${nextEnd}">${rest.map((id, k) => qrow(id, nextEnd + k)).join('') || '<p class="meta" style="padding:0 8px">No hay más canciones. Al terminar, la cola se detiene.</p>'}</div>`;
  }
  function renderQueues() {
    [$('#qpanel'), $('#np-queue')].forEach(c => {
      if (!c) return; c.innerHTML = queueHTML();
      $$('.qlist.sortable', c).forEach(l => sortable(l, '.qrow', (from, to) => { const b = +l.dataset.base; P.move(b + from, b + to); }));
    });
  }

  /* ── barra de reproducción ── */
  const playIcon = () => P.state === 'loading' || P.state === 'buffering' ? '<span class="spin"></span>' : ic(P.state === 'playing' ? 'pause' : 'play', 'fill');
  function renderBar() {
    const t = P.current(); if (!t) return;
    $('#bar-cover').src = t.cover; $('#bar-cover').alt = 'Portada de ' + t.album;
    $('#bar-title').textContent = t.title; $('#bar-artist').textContent = t.artist;
    $('#bar-dur').textContent = fmt(t.dur);
    ['#bar-play', '#bar-play-m'].forEach(s => { Liquid.playBtn($(s), P.state); $(s).setAttribute('aria-label', P.state === 'playing' ? 'Pausar' : 'Reproducir'); });
    $('#bar-shuffle').classList.toggle('on', P.shuffle); $('#bar-shuffle').setAttribute('aria-pressed', P.shuffle);
    $('#bar-repeat').classList.toggle('on', P.repeat !== 'off'); $('#bar-repeat').innerHTML = ic(P.repeat === 'one' ? 'repeat1' : 'repeat');
    $('#bar-repeat').setAttribute('aria-label', { off: 'Repetir: apagado', all: 'Repetir: todas', one: 'Repetir: una' }[P.repeat]);
    syncFavButtons();
    $$('.row').forEach(r => r.classList.toggle('playing', r.dataset.tid === t.id));
  }
  function seekBar(el, getDur) {
    const at = e => { const r = el.getBoundingClientRect(); return Math.max(0, Math.min(1, (e.clientX - r.left) / r.width)) * getDur(); };
    el.addEventListener('pointerdown', e => { el.classList.add('drag'); el.setPointerCapture(e.pointerId); el._drag = at(e); const mv = ev => { el._drag = at(ev); }; const up = ev => { el.classList.remove('drag'); el.removeEventListener('pointermove', mv); el.removeEventListener('pointerup', up); P.seek(at(ev)); el._drag = null; }; el.addEventListener('pointermove', mv); el.addEventListener('pointerup', up); });
    el.addEventListener('keydown', e => { if (e.key === 'ArrowRight') P.seek(P.position() + 5); if (e.key === 'ArrowLeft') P.seek(P.position() - 5); });
  }
  seekBar($('#bar-seek'), () => P.duration());
  const barWave = Liquid.wave($('#bar-seek'));
  let lastT = performance.now();
  window.UI = { addToPlaylist: id => addToPlaylist(id), fmt, ic, esc, seekBar, renderQueues, playIcon, isFav, toggleFav, menu, toast, startRadio, get settings() { return st.settings; }, plName: id => pl(id)?.name };

  function frame(now = performance.now()) {
    const t = P.current(), dt = Math.min(64, now - lastT); lastT = now;
    if (t) {
      const pos = $('#bar-seek')._drag ?? P.position(), pct = Math.min(100, pos / t.dur * 100);
      $('#bar-seek .fill').style.width = pct + '%'; $('#bar-seek .knob').style.left = pct + '%';
      $('#bar-pos').textContent = fmt(pos); $('#mini-prog').style.width = pct + '%';
      $('#bar-seek').setAttribute('aria-valuenow', Math.round(pos)); $('#bar-seek').setAttribute('aria-valuetext', fmt(pos) + ' de ' + fmt(t.dur));
      const L = P.levels(), b = L.bands;
      barWave(pct, P.state === 'playing' && $('#bar-seek')._drag == null ? 1.4 + L.bass * 2.4 : 0, dt);
      $$('.eq').forEach(eq => [...eq.children].forEach((bar, i) => { bar.style.height = b ? (18 + Math.min(82, b[[3, 12, 30, 70][i]] / 255 * 100)) + '%' : '22%'; }));
      $('#bar-cover').style.transform = st.settings.reactive && st.settings.motion === 'full' ? `scale(${1 + L.beat * 0.05})` : '';
    }
    requestAnimationFrame(frame);
  }

  /* ── eventos ── */
  const queueFor = list => {
    if (!list) return null;
    if (list.startsWith('album:')) return D.album(list.slice(6)).tracks.map(t => t.id);
    if (list.startsWith('pl:')) return pl(list.slice(3)).tracks.slice();
    if (list.startsWith('ids:')) return list.slice(4).split(',');
    if (list === 'fav') return st.favorites.slice();
    return null;
  };
  const fromLabel = list => list?.startsWith('album:') ? D.album(list.slice(6)).title : list?.startsWith('pl:') ? pl(list.slice(3)).name : list === 'fav' ? 'Favoritos' : 'Búsqueda';
  const playFrom = (ids, i, label) => { P.play(ids, i); if (window.NP) window.NP.from = label; };

  document.addEventListener('click', e => {
    const a = e.target.closest('[data-act]'); if (!a) return;
    const act = a.dataset.act, id = a.dataset.id, rowEl = a.closest('[data-tid]'), tid = rowEl?.dataset.tid;
    const offline = estado === 'offline';
    if (act === 'play-row') { const lst = rowEl.closest('.tracks')?.dataset.list; const ids = queueFor(lst); if (ids) playFrom(ids, ids.indexOf(tid), fromLabel(lst)); else playFrom([tid], 0, 'Búsqueda'); }
    if (act === 'play-one') playFrom([id], 0, 'Búsqueda');
    if (act === 'play-album' || act === 'shuffle-album') { if (act === 'shuffle-album' && !P.shuffle) P.toggleShuffle(); playFrom(D.album(id).tracks.map(t => t.id), 0, D.album(id).title); }
    if (act === 'play-pl' || act === 'shuffle-pl') { if (act === 'shuffle-pl' && !P.shuffle) P.toggleShuffle(); const p = pl(id); if (p.tracks.length) playFrom(p.tracks.slice(), 0, p.name); }
    if (act === 'play-ids') playFrom(a.dataset.ids.split(','), 0, 'Populares');
    if (act === 'radio-artist') { const ar = D.ARTISTS[id]; startRadio(D.TRACKS[ar.popular?.[0]] || D.album(ar.albums[0]).tracks[0]); }
    if (act === 'resume') { const t = D.TRACKS[id]; if (P.current()?.id === id) { if (P.state !== 'playing') P.toggle(); } else playFrom([id, ...D.album(t.albumId).tracks.map(x => x.id).filter(x => x !== id)], 0, t.album); }
    if (act === 'fav') toggleFav(tid);
    if (act === 'fav-current' && P.current()) toggleFav(P.current().id);
    if (act === 'row-menu') rowMenu(a, tid);
    if (act === 'pl-remove') { const p = pl(rowEl.closest('.tracks').dataset.list.slice(3)); const ix = p.tracks.indexOf(tid); p.tracks.splice(ix, 1); save(); rowEl.style.transition = 'opacity .2s, transform .25s'; rowEl.style.opacity = 0; rowEl.style.transform = 'translateX(16px)'; setTimeout(() => render(true), 200); toast('Quitada de la playlist', { action: 'Deshacer', onAction: () => { p.tracks.splice(ix, 0, tid); save(); render(true); } }); }
    if (act === 'toggle') P.toggle();
    if (act === 'next') P.next();
    if (act === 'prev') P.prev();
    if (act === 'shuffle') P.toggleShuffle();
    if (act === 'repeat') P.cycleRepeat();
    if (act === 'toggle-queue') { $('#app').classList.toggle('q-open'); $('#bar-queue').classList.toggle('on', $('#app').classList.contains('q-open')); renderQueues(); }
    if (act === 'q-play') { P.index = +a.dataset.i; P.load(0); renderQueues(); }
    if (act === 'q-remove') { const r = a.closest('.qrow'); r.style.opacity = 0; r.style.transform = 'translateX(20px)'; setTimeout(() => P.remove(+a.dataset.i), 180); }
    if (act === 'q-clear') { P.clear(); toast('Cola limpia'); }
    if (act === 'q-save') newPlaylist(P.queue.slice());
    if (act === 'filter') { filter = a.dataset.v; $('#results').innerHTML = results(); afterRender(); }
    if (act === 'search-clear') { q = ''; commitSearch(''); $('#q').focus(); }
    if (act === 'sug' || act === 'recent') commitSearch(a.dataset.q);
    if (act === 'recent-del') { st.recents.splice(+a.dataset.i, 1); save(); $('#results').innerHTML = results(); }
    if (act === 'recents-clear') { st.recents = []; save(); $('#results').innerHTML = results(); }
    if (act === 'download') { if (offline) return toast('Sin conexión: no se puede descargar ahora', { err: true }); download(id, a); }
    if (act === 'dl-del') { delete st.downloads[id]; save(); render(true); toast('Descarga borrada'); }
    if (act === 'dl-clear') { st.downloads = {}; save(); render(true); toast('Se borraron todas las descargas'); }
    if (act === 'save-as-pl') { const al = D.album(id); newPlaylist(al.tracks.map(t => t.id)); setTimeout(() => { const i = $('#np-name'); if (i) i.value = al.title; }, 0); }
    if (act === 'new-pl') newPlaylist();
    if (act === 'rename') { editing = true; render(true); const i = $('[data-form="rename"] input'); i.focus(); i.select(); }
    if (act === 'pl-delete') dialog(`<h2>¿Borrar “${esc(pl(id).name)}”?</h2><p class="meta" style="margin-top:6px">Se borrará también en tus otros dispositivos.</p><div class="dialog-actions"><button class="btn btn-ghost" data-close>Cancelar</button><button class="btn btn-secondary" data-del style="color:var(--err)">Borrar playlist</button></div>`).el.querySelector('[data-del]').addEventListener('click', ev => { ev.target.closest('.dialog-wrap').remove(); const p = pl(id); p.inLibrary = false; save(); location.hash = '#/biblioteca'; toast('Playlist borrada', { action: 'Deshacer', onAction: () => { p.inLibrary = true; save(); render(); } }); });
    if (act === 'import') { const src = pl(id); const copy = { ...src, id: 'pl-imp-' + Date.now().toString(36), source: 'own', created: new Date().toISOString().slice(0, 10), tracks: src.tracks.slice(), inLibrary: true }; st.playlists.unshift(copy); save(); a.disabled = true; a.innerHTML = '<span class="spin"></span>Importando…'; setTimeout(() => { toast(`“${esc(copy.name)}” importada como copia editable`, { action: 'Abrir', onAction: () => location.hash = '#/playlist/' + copy.id }); location.hash = '#/playlist/' + copy.id; }, 900); }
    if (act === 'retry') { estado = null; history.replaceState(null, '', location.pathname + location.hash.split('?')[0]); render(); }
    if (act === 'sw') { const k = a.dataset.k; st.settings[k] = !st.settings[k]; a.setAttribute('aria-checked', st.settings[k]); save(); }
    if (act === 'perm') { a.setAttribute('aria-checked', a.getAttribute('aria-checked') !== 'true'); }
    if (act === 'test-conn') { const s = $('#conn-status'); s.className = 'status meta'; s.innerHTML = '<span class="spin"></span>Probando…'; setTimeout(() => { const ok = estado !== 'offline'; s.className = 'status ' + (ok ? 'ok' : 'bad'); s.innerHTML = ic(ok ? 'check' : 'off') + (ok ? 'Conectado · respuesta en 84 ms (simulada)' : 'BACKEND_OFFLINE · sin respuesta'); }, 900); }
    if (act === 'export') { const blob = new Blob([JSON.stringify({ playlists: st.playlists.filter(p => p.inLibrary), favorites: st.favorites, history: st.history }, null, 2)], { type: 'application/json' }); const u = URL.createObjectURL(blob); const l = document.createElement('a'); l.href = u; l.download = 'onda-respaldo.json'; l.click(); URL.revokeObjectURL(u); toast('Respaldo exportado'); }
    if (act === 'cache-clear') toast('Caché borrada · las descargas se conservan');
    if (act === 'onb-test') { testRes = 'run'; render(true); setTimeout(() => { testRes = /^od_/.test($('#f-token').value) ? 'ok' : 'bad'; st.settings.url = $('#f-url').value; st.settings.token = $('#f-token').value; render(true); }, 900); }
    if (act === 'onb-next') { onbStep = Math.min(2, onbStep + 1); render(true); }
    if (act === 'onb-back') { onbStep = Math.max(0, onbStep - 1); render(true); }
  });
  document.addEventListener('click', e => {
    const b = e.target.closest('.seg button'); if (!b || b.closest('#np-seg')) return;
    const sg = b.closest('.seg'), k = sg.dataset.seg, v = b.dataset.v;
    $$('button', sg).forEach(x => x.setAttribute('aria-pressed', x === b)); placeThumb(sg);
    if (k === 'lib-sort') { libSort = v; setTimeout(() => { $('#lib-body').innerHTML = libBody(); afterRender(); }, 150); return; }
    st.settings[k] = v; save(); if (k === 'theme' || k === 'motion') applyTheme();
  });
  document.addEventListener('submit', e => {
    const f = e.target.dataset.form; if (!f) return; e.preventDefault();
    if (f === 'rename') { const p = pl(location.hash.split('/')[2]); const n = new FormData(e.target).get('name').trim(); if (n) p.name = n; editing = false; save(); render(true); toast('Nombre actualizado'); }
    if (f === 'conn') { onbStep = 1; render(true); }
  });
  document.addEventListener('input', e => { if (e.target.dataset.k === 'limit') { st.settings.limit = +e.target.value; $('#limit-val').textContent = e.target.value + ' GB'; save(); } });
  document.addEventListener('change', e => { if (e.target.dataset.act === 'import-json' && e.target.files[0]) e.target.files[0].text().then(t => { try { const d = JSON.parse(t); if (!Array.isArray(d.playlists)) throw 0; toast(`Respaldo válido · ${plural(d.playlists.length, 'playlist', 'playlists')}`); } catch (x) { toast('El archivo no es un respaldo de Onda', { err: true }); } }); });

  /* atajos de PC: Espacio, Ctrl+F, Ctrl+→/←, Ctrl+L */
  document.addEventListener('keydown', e => {
    const typing = /INPUT|TEXTAREA/.test(document.activeElement.tagName);
    if (e.key === 'Escape') closeMenus();
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'f') { e.preventDefault(); if (window.NP?.isOpen()) window.NP.close(); location.hash = '#/buscar'; setTimeout(() => $('#q')?.focus(), 50); }
    if (typing) return;
    if (e.code === 'Space' && !e.target.closest('button,a')) { e.preventDefault(); P.toggle(); }
    if ((e.ctrlKey || e.metaKey) && e.key === 'ArrowRight') { e.preventDefault(); P.next(); }
    if ((e.ctrlKey || e.metaKey) && e.key === 'ArrowLeft') { e.preventDefault(); P.prev(); }
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'l') { e.preventDefault(); if (P.current()) toggleFav(P.current().id); }
  });

  P.on('state', ({ state, code, message }) => {
    renderBar();
    if (state === 'error') toast(message, { err: true, ms: 2600 });
    if (state === 'completed') toast('Terminó la cola', { action: 'Repetir', onAction: () => { P.index = 0; P.load(0); } });
    if (state === 'playing') { const t = P.current(); if (st.history[0]?.id !== t.id) { st.history.unshift({ id: t.id, at: '2026-10-05T' + new Date().toTimeString().slice(0, 5), device: matchMedia('(max-width: 820px)').matches ? 'Celular' : 'PC' }); save(); } }
    $$('.row').forEach(r => { const ix = r.querySelector('.ix'); if (!ix || ix.querySelector('[data-grip]')) return; const cur = r.dataset.tid === P.current()?.id; const n = ix.querySelector('.n'); if (cur && state === 'playing' && n && !n.classList.contains('eq')) n.outerHTML = '<span class="eq n"><i></i><i></i><i></i><i></i></span>'; if ((!cur || state !== 'playing') && n?.classList.contains('eq')) n.outerHTML = `<span class="n">${+r.dataset.idx + 1}</span>`; });
  });
  P.on('track', renderBar);
  P.on('queue', renderQueues);
  P.on('modes', renderBar);

  render(); renderBar(); renderQueues(); requestAnimationFrame(frame);
})();
