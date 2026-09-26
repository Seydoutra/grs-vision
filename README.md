# GRS VISION

Plateforme premium React + TypeScript + Vite conçue pour le studio créatif GRS VISION.

## Lancer localement

```bash
npm install
cp .env.example .env
npm run dev
```

Le mode démonstration est utilisable sans Supabase. Les projets et médias fictifs portent la mention `DEMO`.

## Parcours disponibles

- Site public, portfolio photo/film, projets, services, formation, à propos et formulaires.
- Espace client : `/client/demo` — PIN `2026`.
- Administration : `/admin` — `kara@demo.local` / `Kara@2026!` (démo uniquement).
- Studio Manager : clients, prestations, devis, factures, paiements, médiathèque, partage et statistiques.
- Thème sombre principal et thème clair éditorial.

## Production

Configurer Supabase selon `GUIDE_SUPABASE.md`, puis ajouter les variables publiques dans les variables GitHub Actions. Les migrations incluent la gestion commerciale du studio. Les secrets serveur ne doivent jamais commencer par `VITE_`.

## Déploiement GitHub Pages

Le workflow `.github/workflows/deploy-pages.yml` construit et publie automatiquement le site à chaque envoi sur la branche `main`. Le routage et les ressources sont compatibles avec les URLs de projet GitHub Pages. Voir `GUIDE_DEPLOIEMENT.md`.
