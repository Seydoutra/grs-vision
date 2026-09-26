# Connecter Supabase

1. Créer un projet Supabase.
2. Exécuter, dans l’ordre, `supabase/migrations/001_initial_schema.sql` puis `supabase/migrations/002_studio_management.sql` dans le SQL Editor.
3. Créer les buckets : `branding`, `portfolio-images`, `public-projects`, `private-deliverables`, `training`, `documents`.
4. Garder `private-deliverables` privé. Générer ses URLs signées côté serveur, avec une expiration courte.
5. Créer Kara dans Supabase Auth, puis ajouter son `id` dans `profiles` avec le rôle `SUPER_ADMIN`.
6. Renseigner `VITE_SUPABASE_URL` et `VITE_SUPABASE_ANON_KEY` côté navigateur. Garder `SUPABASE_SERVICE_ROLE_KEY` uniquement côté serveur.

Les tokens client doivent être générés avec `crypto.randomBytes`, puis stockés sous forme de hash. Les PIN doivent être hashés avec Argon2 ou bcrypt. Ne jamais stocker les valeurs en clair.
