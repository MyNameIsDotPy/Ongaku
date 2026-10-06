/* Datos de ejemplo del prototipo.
   Portadas y listas de pistas reales (iTunes Search API, descargadas localmente).
   Foto de Bomba Estéreo: CAMOGRAPHY, CC BY 2.0, vía Wikimedia Commons.
   La letra es de muestra (texto original del prototipo), no la letra real. */
(function () {
  const ALBUMS = [{"id":"deja","title":"Deja","artist":"Bomba Estéreo","year":2021,"genre":"Pop en español","cover":"assets/covers/deja.jpg","palette":[[113,137,51],[102,127,55],[234,239,243]],"tracks":[{"id":"deja-1","title":"Agua","dur":201},{"id":"deja-2","title":"Deja","dur":231},{"id":"deja-3","title":"Como Lo Pedí","dur":245},{"id":"deja-4","title":"Soledad","dur":217},{"id":"deja-5","title":"Se Acabó","dur":221},{"id":"deja-6","title":"Conexión Total","dur":215},{"id":"deja-7","title":"Tamborero","dur":254},{"id":"deja-8","title":"Lento","dur":155},{"id":"deja-9","title":"Tierra","dur":211},{"id":"deja-10","title":"Amor Amor","dur":184},{"id":"deja-11","title":"Profundo","dur":224},{"id":"deja-12","title":"Ahora","dur":274},{"id":"deja-13","title":"Mamo Manuel Nieves (Sierra Nevada de Santa Marta)","dur":158}]},{"id":"ayo","title":"Ayo","artist":"Bomba Estéreo","year":2017,"genre":"Pop en español","cover":"assets/covers/ayo.jpg","palette":[[253,131,129],[249,130,128],[213,154,155]],"tracks":[{"id":"ayo-1","title":"Siembra","dur":258},{"id":"ayo-2","title":"Ayo","dur":173},{"id":"ayo-3","title":"Química (Dance With Me) [feat. Balkan Beat Box]","dur":162},{"id":"ayo-4","title":"Duele","dur":224},{"id":"ayo-5","title":"Amar Así","dur":237},{"id":"ayo-6","title":"Money Money Money...","dur":168},{"id":"ayo-7","title":"Internacionales","dur":188},{"id":"ayo-8","title":"Flower Power","dur":199},{"id":"ayo-9","title":"Taganga","dur":165},{"id":"ayo-10","title":"Vuelve","dur":311}]},{"id":"amanecer","title":"Amanecer","artist":"Bomba Estéreo","year":2015,"genre":"Pop en español","cover":"assets/covers/amanecer.jpg","palette":[[208,71,59],[207,81,83],[83,75,84]],"tracks":[{"id":"amanecer-1","title":"Amanecer","dur":249},{"id":"amanecer-2","title":"Caderas","dur":176},{"id":"amanecer-3","title":"Somos Dos","dur":240},{"id":"amanecer-4","title":"Soy Yo","dur":160},{"id":"amanecer-5","title":"Fiesta","dur":219},{"id":"amanecer-6","title":"Voy","dur":196},{"id":"amanecer-7","title":"Algo Está Cambiando","dur":270},{"id":"amanecer-8","title":"Mar (Lo Que Siento)","dur":230},{"id":"amanecer-9","title":"To My Love","dur":240},{"id":"amanecer-10","title":"Sólo Tú","dur":255},{"id":"amanecer-11","title":"Raíz","dur":219}]},{"id":"pipa","title":"La Pipa de la Paz","artist":"Aterciopelados","year":1996,"genre":"Alternativa y rock en español","cover":"assets/covers/pipa.jpg","palette":[[200,137,88],[89,164,152],[144,157,142]],"tracks":[{"id":"pipa-1","title":"Cosita Seria","dur":208},{"id":"pipa-2","title":"No Necesito","dur":224},{"id":"pipa-3","title":"Quemarropa","dur":206},{"id":"pipa-4","title":"Nada Quer Ver","dur":200},{"id":"pipa-5","title":"La Culpable","dur":201},{"id":"pipa-6","title":"Expreso Amazonia","dur":227},{"id":"pipa-7","title":"Miss Panela","dur":228},{"id":"pipa-8","title":"Música","dur":210},{"id":"pipa-9","title":"Buena Estrella","dur":206},{"id":"pipa-10","title":"Baracunatana","dur":152},{"id":"pipa-11","title":"Platonico","dur":215},{"id":"pipa-12","title":"La Voz de la Patria","dur":229},{"id":"pipa-13","title":"Chica Difícil","dur":144},{"id":"pipa-14","title":"Te Juro Que No","dur":209},{"id":"pipa-15","title":"La Pipa de la Paz","dur":280}]},{"id":"vives","title":"La Tierra del Olvido","artist":"Carlos Vives","year":1995,"genre":"Música tropical","cover":"assets/covers/vives.jpg","palette":[[213,109,49],[133,78,55],[115,100,99]],"tracks":[{"id":"vives-1","title":"Pa' Mayte","dur":189},{"id":"vives-2","title":"Fidelina","dur":262},{"id":"vives-3","title":"La Tierra del Olvido","dur":266},{"id":"vives-4","title":"Zoila","dur":264},{"id":"vives-5","title":"Rosa","dur":253},{"id":"vives-6","title":"Agua","dur":233},{"id":"vives-7","title":"La Cachucha Bacana","dur":261},{"id":"vives-8","title":"Diosa Coronada","dur":254},{"id":"vives-9","title":"La Puya Puya","dur":300},{"id":"vives-10","title":"Ella","dur":227},{"id":"vives-11","title":"Jam en Jukumey","dur":93}]},{"id":"shakira","title":"Pies Descalzos","artist":"Shakira","year":1995,"genre":"Latin","cover":"assets/covers/shakira.jpg","palette":[[211,164,136],[172,135,114],[64,42,39]],"tracks":[{"id":"shakira-1","title":"Estoy Aquí","dur":232},{"id":"shakira-2","title":"Antología","dur":254},{"id":"shakira-3","title":"Un Poco de Amor","dur":241},{"id":"shakira-4","title":"Quiero","dur":250},{"id":"shakira-5","title":"Te Necesito","dur":240},{"id":"shakira-6","title":"Vuelve","dur":234},{"id":"shakira-7","title":"Te Espero Sentada","dur":205},{"id":"shakira-8","title":"Pies Descalzos, Sueños Blancos","dur":206},{"id":"shakira-9","title":"Pienso en Ti","dur":146},{"id":"shakira-10","title":"Dónde Estás Corazón","dur":232},{"id":"shakira-11","title":"Se Quiere, Se Mata","dur":218}]},{"id":"juanes","title":"Mi Sangre","artist":"Juanes","year":2004,"genre":"Latin","cover":"assets/covers/juanes.jpg","palette":[[175,104,63],[102,50,24],[141,141,141]],"tracks":[{"id":"juanes-1","title":"Ámame","dur":260},{"id":"juanes-2","title":"Para Tu Amor","dur":249},{"id":"juanes-3","title":"Sueños","dur":190},{"id":"juanes-4","title":"La Camisa Negra","dur":217},{"id":"juanes-5","title":"Nada Valgo Sin Tu Amor","dur":196},{"id":"juanes-6","title":"No Siento Penas","dur":233},{"id":"juanes-7","title":"Dámelo","dur":247},{"id":"juanes-8","title":"Lo Que Me Gusta a Mí","dur":211},{"id":"juanes-9","title":"Rosarío Tijeras","dur":207},{"id":"juanes-10","title":"¿Qué Pasa?","dur":228},{"id":"juanes-11","title":"Volverte a Ver","dur":218},{"id":"juanes-12","title":"Tu Guardián","dur":266}]},{"id":"mperine","title":"Caja de Música","artist":"Monsieur Periné","year":2015,"genre":"Latin Jazz","cover":"assets/covers/mperine.jpg","palette":[[184,176,168],[93,85,84],[223,224,224]],"tracks":[{"id":"mperine-1","title":"Nuestra Canción (feat. Vicente García)","dur":260},{"id":"mperine-2","title":"No Hace Falta","dur":222},{"id":"mperine-3","title":"Tu M'as Promis","dur":328},{"id":"mperine-4","title":"Interludio: Carillons À Musique","dur":51},{"id":"mperine-5","title":"Turquesa Menina","dur":180},{"id":"mperine-6","title":"Déjame Vivir","dur":214},{"id":"mperine-7","title":"Año Bisiesto","dur":235},{"id":"mperine-8","title":"Viejos Amores","dur":170},{"id":"mperine-9","title":"Incendio","dur":220},{"id":"mperine-10","title":"Marinero Wawani","dur":251},{"id":"mperine-11","title":"Lloré","dur":232},{"id":"mperine-12","title":"Mi Libertad","dur":337},{"id":"mperine-13","title":"Outro: Caja de Música","dur":105}]},{"id":"ocean","title":"OCEAN","artist":"KAROL G","year":2019,"genre":"Urbano latino","cover":"assets/covers/ocean.jpg","palette":[[115,147,170],[115,150,154],[164,161,153]],"tracks":[{"id":"ocean-1","title":"Ocean","dur":154},{"id":"ocean-2","title":"Punto G","dur":181},{"id":"ocean-3","title":"Love With A Quality (feat. Damian \"Jr. Gong\" Marley)","dur":222},{"id":"ocean-4","title":"Baby","dur":238},{"id":"ocean-5","title":"Sin Corazón","dur":169},{"id":"ocean-6","title":"Dices Que Te Vas (feat. Anuel AA)","dur":204},{"id":"ocean-7","title":"Pineapple","dur":178},{"id":"ocean-8","title":"La Vida Continuó (feat. Simone & Simaria)","dur":165},{"id":"ocean-9","title":"Bebesita","dur":183},{"id":"ocean-10","title":"Culpables","dur":227},{"id":"ocean-11","title":"Mi Cama","dur":151},{"id":"ocean-12","title":"La Ocasión Perfecta (feat. Yandel)","dur":222},{"id":"ocean-13","title":"Créeme","dur":212},{"id":"ocean-14","title":"Go Karo","dur":148},{"id":"ocean-15","title":"Mi Cama (feat. Nicky Jam) [Remix]","dur":196},{"id":"ocean-16","title":"Yo Aprendí (feat. Danay Suárez)","dur":186}]},{"id":"ram","title":"Random Access Memories","artist":"Daft Punk","year":2013,"genre":"Pop","cover":"assets/covers/ram.jpg","palette":[[78,87,100],[43,42,44],[11,14,14]],"tracks":[{"id":"ram-1","title":"Give Life Back to Music","dur":274},{"id":"ram-2","title":"The Game of Love","dur":322},{"id":"ram-3","title":"Giorgio by Moroder","dur":545},{"id":"ram-4","title":"Within","dur":229},{"id":"ram-5","title":"Instant Crush","dur":338},{"id":"ram-6","title":"Lose Yourself to Dance","dur":354},{"id":"ram-7","title":"Touch","dur":499},{"id":"ram-8","title":"Get Lucky","dur":370},{"id":"ram-9","title":"Beyond","dur":290},{"id":"ram-10","title":"Motherboard","dur":342},{"id":"ram-11","title":"Fragments of Time","dur":280},{"id":"ram-12","title":"Doin' it Right","dur":251},{"id":"ram-13","title":"Contact","dur":381}]},{"id":"rainbows","title":"In Rainbows","artist":"Radiohead","year":2007,"genre":"Alternativa","cover":"assets/covers/rainbows.jpg","palette":[[193,112,64],[124,91,48],[29,26,31]],"tracks":[{"id":"rainbows-1","title":"15 Step","dur":237},{"id":"rainbows-2","title":"Bodysnatchers","dur":242},{"id":"rainbows-3","title":"Nude","dur":255},{"id":"rainbows-4","title":"Weird Fishes / Arpeggi","dur":318},{"id":"rainbows-5","title":"All I Need","dur":229},{"id":"rainbows-6","title":"Faust Arp","dur":130},{"id":"rainbows-7","title":"Reckoner","dur":290},{"id":"rainbows-8","title":"House of Cards","dur":328},{"id":"rainbows-9","title":"Jigsaw Falling Into Place","dur":249},{"id":"rainbows-10","title":"Videotape","dur":280}]},{"id":"slowrush","title":"The Slow Rush","artist":"Tame Impala","year":2020,"genre":"Alternative","cover":"assets/covers/slowrush.jpg","palette":[[185,31,8],[175,40,16],[47,21,15]],"tracks":[{"id":"slowrush-1","title":"One More Year","dur":322},{"id":"slowrush-2","title":"Instant Destiny","dur":194},{"id":"slowrush-3","title":"Borderline","dur":238},{"id":"slowrush-4","title":"Posthumous Forgiveness","dur":366},{"id":"slowrush-5","title":"Breathe Deeper","dur":373},{"id":"slowrush-6","title":"Tomorrow's Dust","dur":327},{"id":"slowrush-7","title":"On Track","dur":302},{"id":"slowrush-8","title":"Lost in Yesterday","dur":250},{"id":"slowrush-9","title":"Is It True","dur":238},{"id":"slowrush-10","title":"It Might Be Time","dur":273},{"id":"slowrush-11","title":"Glimmer","dur":129},{"id":"slowrush-12","title":"One More Hour","dur":433}]}];

  const slug = s => s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  const TRACKS = {};
  ALBUMS.forEach(a => {
    a.artistId = slug(a.artist);
    a.total = a.tracks.reduce((s, t) => s + t.dur, 0);
    a.tracks.forEach((t, i) => Object.assign(t, { n: i + 1, albumId: a.id, album: a.title, artist: a.artist, artistId: a.artistId, cover: a.cover, palette: a.palette }));
    a.tracks.forEach(t => TRACKS[t.id] = t);
  });
  // Una pista marcada como no disponible para demostrar RNF-12 (saltar y avisar)
  TRACKS['deja-13'].unavailable = true;

  const ARTISTS = {};
  ALBUMS.forEach(a => {
    const ar = ARTISTS[a.artistId] || (ARTISTS[a.artistId] = { id: a.artistId, name: a.artist, albums: [] });
    ar.albums.push(a.id);
  });
  ARTISTS['bomba-estereo'].photo = { src: 'assets/artists/bomba-estereo.jpg', w: 680, h: 453, credit: 'Foto: CAMOGRAPHY · CC BY 2.0 · Wikimedia Commons' };
  ARTISTS['bomba-estereo'].popular = ['ayo-3', 'amanecer-5', 'amanecer-2', 'deja-2', 'amanecer-4', 'ayo-1'];

  const PLAYLISTS = [
    { id: 'pl-transmi', name: 'Para TransMilenio', source: 'own', created: '2026-08-02', tracks: ['ayo-3', 'amanecer-2', 'deja-1', 'ocean-2', 'juanes-4', 'vives-1', 'pipa-2', 'amanecer-5', 'mperine-1', 'shakira-1', 'deja-7'] },
    { id: 'pl-code', name: 'Programando', source: 'own', created: '2026-07-14', tracks: ['ram-1', 'ram-5', 'ram-8', 'slowrush-1', 'slowrush-8', 'rainbows-1', 'rainbows-4', 'rainbows-7', 'ram-13', 'slowrush-3'] },
    { id: 'pl-90s', name: 'Colombia 90', source: 'own', created: '2026-06-21', tracks: ['vives-1', 'vives-2', 'vives-3', 'shakira-1', 'shakira-4', 'pipa-1', 'pipa-11', 'pipa-7', 'shakira-9'] },
    { id: 'pl-yt-cumbia', name: 'Cumbia electrónica', source: 'youtube', sourceId: 'PLx0ejemplo4kQm', owner: 'Canal de ejemplo', created: '2026-09-30', tracks: ['ayo-1', 'ayo-9', 'deja-7', 'amanecer-1', 'amanecer-6', 'mperine-5', 'mperine-9', 'vives-9'] },
  ];

  const FAVORITES = ['ayo-3', 'ram-8', 'rainbows-4', 'pipa-11', 'vives-2', 'deja-2', 'slowrush-8'];
  const DOWNLOADS = { 'pl-transmi': { size: 74.2 }, 'pl-90s': { size: 61.8 } };
  const HISTORY = [
    { id: 'ram-5', at: '2026-10-05T21:42', device: 'PC' },
    { id: 'ram-1', at: '2026-10-05T21:36', device: 'PC' },
    { id: 'rainbows-4', at: '2026-10-05T20:58', device: 'PC' },
    { id: 'ayo-3', at: '2026-10-05T07:12', device: 'Celular' },
    { id: 'amanecer-2', at: '2026-10-05T07:09', device: 'Celular' },
    { id: 'deja-1', at: '2026-10-05T07:05', device: 'Celular' },
    { id: 'vives-1', at: '2026-10-04T18:20', device: 'Celular' },
    { id: 'pipa-11', at: '2026-10-04T18:16', device: 'Celular' },
    { id: 'slowrush-8', at: '2026-10-03T22:40', device: 'PC' },
  ];
  const RECENT_SEARCHES = ['bomba estéreo', 'random access memories', 'aterciopelados', 'monsieur periné'];

  /* ── estructura de canción compartida por el motor de audio y la letra ── */
  const LYRICS = {
    v1: ['Las luces de la calle se mueven al compás', 'el bus dobla la esquina y yo no miro atrás', 'llevo el mundo en los audífonos, la ciudad en la piel', 'cada parada es un verso que aprendo a leer'],
    ch: ['Y suena, suena, no se corta', 'aunque la noche sea larga y la pantalla esté apagada', 'suena, suena, no se apaga', 'la canción me sigue a casa'],
    v2: ['Guardé tus canciones para cuando no haya señal', 'una lista para el viaje, otra para respirar', 'el bajo late despacio debajo del pavimento', 'y el coro llega justo cuando lo necesito'],
    br: ['Respira', 'deja que el ritmo te lleve', 'respira', 'todo vuelve'],
  };
  const PLAN = [['intro', 4], ['v1', 8], ['ch', 8], ['inter', 4], ['v2', 8], ['ch', 8], ['br', 8], ['ch', 8]];

  function hash(s) { let h = 2166136261; for (const c of s) { h ^= c.charCodeAt(0); h = Math.imul(h, 16777619); } return h >>> 0; }

  function songInfo(track) {
    const h = hash(track.id);
    const bpm = 88 + (h % 36);
    const bar = 240 / bpm;
    const sections = []; const lines = [];
    let b = 0;
    const totalBars = Math.floor(track.dur / bar);
    for (const [name, len] of PLAN) {
      if (b + len > totalBars - 2) break;
      sections.push({ name, from: b, to: b + len });
      if (LYRICS[name]) LYRICS[name].forEach((txt, i) => {
        const span = len / LYRICS[name].length;
        const t0 = (b + i * span) * bar, t1 = (b + (i + 1) * span) * bar - bar * 0.25;
        lines.push({ t: t0, end: t1, text: txt, section: name });
      });
      b += len;
    }
    sections.push({ name: 'outro', from: b, to: totalBars + 1 });
    return { bpm, bar, root: 45 + (h >> 4) % 10, minor: (h >> 8) % 3 !== 0, sections, lines, seed: h };
  }

  window.DATA = { ALBUMS, TRACKS, ARTISTS, PLAYLISTS, FAVORITES, DOWNLOADS, HISTORY, RECENT_SEARCHES, songInfo, slug,
    album: id => ALBUMS.find(a => a.id === id), playlist: id => PLAYLISTS.find(p => p.id === id) };
})();
