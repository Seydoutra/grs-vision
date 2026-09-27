alter table public.clients add column if not exists billing_address text;
alter table public.clients add column if not exists tax_id text;
alter table public.clients add column if not exists notes text;
alter table public.projects add column if not exists budget numeric(14,2);
alter table public.projects add column if not exists deadline date;
alter table public.projects add column if not exists internal_notes text;

update public.clients
set billing_address = case email
  when 'aissatou@demo.local' then 'Kaloum, Conakry'
  when 'mamadou@demo.local' then 'Kipé, Conakry'
  when 'fatou@demo.local' then 'Ratoma, Conakry'
  else billing_address end,
    tax_id = case email
  when 'aissatou@demo.local' then 'NIF-AD-2026'
  when 'mamadou@demo.local' then 'NIF-MC-2026'
  else tax_id end,
    notes = case email
  when 'aissatou@demo.local' then 'Collection annuelle et contenus éditoriaux.'
  when 'mamadou@demo.local' then 'Client corporate — validation direction requise.'
  when 'fatou@demo.local' then 'Mode, produit et portraits de marque.'
  else notes end
where email in ('aissatou@demo.local', 'mamadou@demo.local', 'fatou@demo.local');

update public.projects
set budget = case slug
  when 'nocturne-demo' then 18500000
  when 'atlantique-demo' then 12000000
  when 'matiere-demo' then 7500000
  else budget end,
    deadline = case slug
  when 'nocturne-demo' then date '2026-10-20'
  when 'atlantique-demo' then date '2026-11-05'
  when 'matiere-demo' then date '2026-09-18'
  else deadline end
where slug in ('nocturne-demo', 'atlantique-demo', 'matiere-demo');
