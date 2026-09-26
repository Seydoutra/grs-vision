# Vidéo

Le composant vidéo est préparé pour une abstraction de fournisseur. Pour la production, choisir Bunny Stream, Mux ou Cloudflare Stream, puis implémenter côté serveur : `uploadVideo`, `deleteVideo`, `getPlaybackUrl`, `getPoster`, `getDuration`, `getStatus` et `getThumbnail`.

Utiliser un poster léger, le chargement paresseux et le streaming adaptatif HLS. Les secrets du fournisseur restent dans les fonctions Netlify.
