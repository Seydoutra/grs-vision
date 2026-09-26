# Déployer GRS VISION sur GitHub Pages

Le projet contient déjà le workflow `.github/workflows/deploy-pages.yml`. Chaque envoi sur la branche `main` construit puis publie automatiquement le site.

## Première publication

1. Créer un dépôt GitHub vide.
2. Décompresser l’archive GRS VISION et placer **tout son contenu** à la racine du dépôt, y compris le dossier caché `.github`.
3. Envoyer les fichiers sur la branche `main`.
4. Dans le dépôt, ouvrir **Settings → Pages**.
5. Sous **Build and deployment**, choisir **GitHub Actions** comme source.
6. Ouvrir l’onglet **Actions** et attendre la fin du workflow « Deploy GRS VISION to GitHub Pages ».

Le site sera disponible à l’adresse `https://VOTRE-COMPTE.github.io/NOM-DU-DEPOT/`.

## Variables Supabase facultatives

Dans **Settings → Secrets and variables → Actions → Variables**, créer si nécessaire :

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

Ces deux valeurs sont destinées au navigateur et peuvent être utilisées pendant le build. Ne jamais ajouter `SUPABASE_SERVICE_ROLE_KEY`, `BUNNY_API_KEY`, `MUX_TOKEN_SECRET` ou tout autre secret serveur dans une variable commençant par `VITE_`.

## À savoir

- Le routage utilise des URLs après `#` (par exemple `/#/portfolio`) afin que toutes les pages s’ouvrent directement et après actualisation sur GitHub Pages.
- Les chemins des images sont relatifs : le site fonctionne dans un dépôt GitHub Pages, même si son nom change.
- GitHub Pages héberge uniquement des fichiers statiques. Le mode démo fonctionne immédiatement. Pour rendre les données du tableau de bord persistantes et protéger les opérations sensibles, connecter Supabase et placer les traitements privilégiés dans des Edge Functions ou un autre backend sécurisé.
