/* ════════════════════════════════════════════════════════
   NurHealth PWA — Service Worker v3.0
   SOCIETE ANY-SERVICE SARL — Zinder, Niger
   Stratégie : Cache First (offline) + Network Update
════════════════════════════════════════════════════════ */

const CACHE_NAME    = 'nurhealth-v3';
const CACHE_STATIC  = 'nurhealth-static-v3';
const CACHE_DYNAMIC = 'nurhealth-dynamic-v3';

/* ── Fichiers à mettre en cache immédiatement (App Shell) ── */
const STATIC_ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  /* Fonts Google (mis en cache au premier chargement) */
  'https://fonts.googleapis.com/css2?family=Amiri:wght@400;700&family=Cinzel:wght@400;600;700&family=Nunito:wght@400;600;700;800&display=swap',
];

/* ── URLs à NE JAMAIS mettre en cache ── */
const NO_CACHE_PATTERNS = [
  /firebase/,
  /firestore/,
  /gstatic\.com\/firebasejs/,
  /kaspersky/,
];

/* ── Taille max du cache dynamique ── */
const DYNAMIC_CACHE_LIMIT = 60;


/* ════════════════════════════════════════════
   INSTALL — Mise en cache de l'App Shell
════════════════════════════════════════════ */
self.addEventListener('install', event => {
  console.log('[SW NurHealth] Installation v3...');
  event.waitUntil(
    caches.open(CACHE_STATIC)
      .then(cache => {
        console.log('[SW NurHealth] Mise en cache des fichiers statiques');
        return cache.addAll(STATIC_ASSETS);
      })
      .then(() => self.skipWaiting()) // Activation immédiate
      .catch(err => console.warn('[SW NurHealth] Erreur cache install:', err))
  );
});


/* ════════════════════════════════════════════
   ACTIVATE — Nettoyage des anciens caches
════════════════════════════════════════════ */
self.addEventListener('activate', event => {
  console.log('[SW NurHealth] Activation v3');
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(
        keys
          .filter(k => k !== CACHE_STATIC && k !== CACHE_DYNAMIC)
          .map(k => {
            console.log('[SW NurHealth] Suppression ancien cache:', k);
            return caches.delete(k);
          })
      ))
      .then(() => self.clients.claim()) // Contrôle immédiat de toutes les pages
  );
});


/* ════════════════════════════════════════════
   FETCH — Stratégie de récupération
════════════════════════════════════════════ */
self.addEventListener('fetch', event => {
  const url = event.request.url;

  // Ignorer les requêtes non-GET
  if (event.request.method !== 'GET') return;

  // Ignorer Firebase, Kaspersky et autres services tiers critiques
  if (NO_CACHE_PATTERNS.some(pattern => pattern.test(url))) return;

  // Ignorer les extensions Chrome
  if (url.startsWith('chrome-extension://')) return;

  event.respondWith(handleFetch(event.request));
});


async function handleFetch(request) {
  const url = request.url;

  // ── 1. App Shell (fichiers locaux) → Cache First ──
  if (isStaticAsset(url)) {
    return cacheFirst(request, CACHE_STATIC);
  }

  // ── 2. Fonts Google → Cache First (stale-while-revalidate) ──
  if (url.includes('fonts.googleapis.com') || url.includes('fonts.gstatic.com')) {
    return staleWhileRevalidate(request, CACHE_STATIC);
  }

  // ── 3. API Aladhan (date hijri, horaires) → Network First avec fallback ──
  if (url.includes('aladhan.com') || url.includes('api.')) {
    return networkFirst(request, CACHE_DYNAMIC);
  }

  // ── 4. Tout le reste → Stale While Revalidate ──
  return staleWhileRevalidate(request, CACHE_DYNAMIC);
}


/* ════════════════════════════════════════════
   STRATÉGIES DE CACHE
════════════════════════════════════════════ */

/** Cache First : Retourne le cache, sinon réseau */
async function cacheFirst(request, cacheName) {
  const cached = await caches.match(request);
  if (cached) return cached;

  try {
    const response = await fetch(request);
    if (response && response.status === 200) {
      const cache = await caches.open(cacheName);
      cache.put(request, response.clone());
    }
    return response;
  } catch (err) {
    return offlineFallback(request);
  }
}

/** Network First : Réseau d'abord, cache si échec */
async function networkFirst(request, cacheName) {
  try {
    const response = await fetch(request, { signal: AbortSignal.timeout(6000) });
    if (response && response.status === 200) {
      const cache = await caches.open(cacheName);
      cache.put(request, response.clone());
      await trimCache(cacheName);
    }
    return response;
  } catch (err) {
    const cached = await caches.match(request);
    if (cached) return cached;
    return offlineFallback(request);
  }
}

/** Stale While Revalidate : Cache immédiat + mise à jour en arrière-plan */
async function staleWhileRevalidate(request, cacheName) {
  const cached = await caches.match(request);

  const fetchPromise = fetch(request)
    .then(async response => {
      if (response && response.status === 200) {
        const cache = await caches.open(cacheName);
        cache.put(request, response.clone());
        await trimCache(cacheName);
      }
      return response;
    })
    .catch(() => null);

  return cached || fetchPromise || offlineFallback(request);
}


/* ════════════════════════════════════════════
   UTILITAIRES
════════════════════════════════════════════ */

function isStaticAsset(url) {
  return STATIC_ASSETS.some(asset => {
    if (asset.startsWith('http')) return url === asset;
    return url.endsWith(asset.replace('./', ''));
  });
}

/** Page de fallback hors-ligne */
function offlineFallback(request) {
  if (request.headers.get('Accept')?.includes('text/html')) {
    return caches.match('./index.html');
  }
  return new Response('', { status: 503, statusText: 'Service Unavailable' });
}

/** Limite la taille du cache dynamique */
async function trimCache(cacheName) {
  const cache = await caches.open(cacheName);
  const keys  = await cache.keys();
  if (keys.length > DYNAMIC_CACHE_LIMIT) {
    await cache.delete(keys[0]);
    await trimCache(cacheName);
  }
}


/* ════════════════════════════════════════════
   NOTIFICATIONS PUSH — Rappel des prières
════════════════════════════════════════════ */
self.addEventListener('push', event => {
  const data = event.data?.json() || {};
  const title   = data.title   || '🕌 NurHealth — Heure de Prière';
  const body    = data.body    || 'Il est temps de prier. Hayya ala as-Salah!';
  const options = {
    body,
    icon : './icon-192.png',
    badge: './icon-192.png',
    tag  : 'prayer-notification',
    renotify: true,
    vibrate: [200, 100, 200],
    data: { url: data.url || './' },
    actions: [
      { action: 'open', title: '🕋 Ouvrir NurHealth' },
      { action: 'dismiss', title: 'Fermer' }
    ]
  };
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', event => {
  event.notification.close();
  if (event.action === 'dismiss') return;
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then(clientList => {
        for (const client of clientList) {
          if (client.url.includes('nurhealth') && 'focus' in client) {
            return client.focus();
          }
        }
        if (clients.openWindow) {
          return clients.openWindow(event.notification.data?.url || './');
        }
      })
  );
});


/* ════════════════════════════════════════════
   SYNC EN ARRIÈRE-PLAN
   (pour les dons enregistrés hors-ligne)
════════════════════════════════════════════ */
self.addEventListener('sync', event => {
  if (event.tag === 'sync-donations') {
    event.waitUntil(syncPendingDonations());
  }
});

async function syncPendingDonations() {
  console.log('[SW NurHealth] Synchronisation des dons en attente...');
  // Les données sont gérées par Firebase — sync automatique à la reconnexion
}


console.log('[SW NurHealth] Service Worker chargé — Zinder, Niger 🇳🇪');
