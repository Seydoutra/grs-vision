alter table public.clients add column if not exists company text;

create table if not exists public.teams (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  specialty text,
  email text,
  phone text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.shoots (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references public.projects(id) on delete set null,
  title text not null,
  starts_at timestamptz not null,
  ends_at timestamptz,
  location text,
  status text not null default 'PLANNED' check (status in ('PLANNED','CONFIRMED','IN_PROGRESS','DONE','CANCELLED')),
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.shoot_team (
  shoot_id uuid references public.shoots(id) on delete cascade,
  team_id uuid references public.teams(id) on delete cascade,
  primary key (shoot_id, team_id)
);

create table if not exists public.equipment (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text,
  serial_number text,
  quantity integer not null default 1 check (quantity >= 0),
  status text not null default 'AVAILABLE' check (status in ('AVAILABLE','BOOKED','MAINTENANCE','OUT')),
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.communications (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  channel text not null check (channel in ('EMAIL','SMS')),
  subject text,
  message text not null,
  status text not null default 'DRAFT' check (status in ('DRAFT','SCHEDULED','SENT')),
  scheduled_at timestamptz,
  recipient_count integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.teams enable row level security;
alter table public.shoots enable row level security;
alter table public.shoot_team enable row level security;
alter table public.equipment enable row level security;
alter table public.communications enable row level security;

drop policy if exists "studio admins manage teams" on public.teams;
create policy "studio admins manage teams" on public.teams for all using (public.is_studio_admin()) with check (public.is_studio_admin());
drop policy if exists "studio admins manage shoots" on public.shoots;
create policy "studio admins manage shoots" on public.shoots for all using (public.is_studio_admin()) with check (public.is_studio_admin());
drop policy if exists "studio admins manage shoot team" on public.shoot_team;
create policy "studio admins manage shoot team" on public.shoot_team for all using (public.is_studio_admin()) with check (public.is_studio_admin());
drop policy if exists "studio admins manage equipment" on public.equipment;
create policy "studio admins manage equipment" on public.equipment for all using (public.is_studio_admin()) with check (public.is_studio_admin());
drop policy if exists "studio admins manage communications" on public.communications;
create policy "studio admins manage communications" on public.communications for all using (public.is_studio_admin()) with check (public.is_studio_admin());

drop policy if exists "public reads published project media" on public.project_media;
create policy "public reads published project media" on public.project_media for select using (
  exists (select 1 from public.projects p where p.id = project_id and p.published = true)
);
drop policy if exists "public reads portfolio assets" on public.media_assets;
create policy "public reads portfolio assets" on public.media_assets for select using (
  exists (
    select 1 from public.project_media pm join public.projects p on p.id = pm.project_id
    where pm.media_id = media_assets.id and p.published = true
  )
);

insert into public.clients (name, company, email, phone)
select * from (values
  ('Aïssatou Diallo','Atelier AD','aissatou@demo.local','+224 610 00 00 01'),
  ('Mamadou Camara','MC Holding','mamadou@demo.local','+224 610 00 00 02'),
  ('Fatou Bah','Maison FB','fatou@demo.local','+224 610 00 00 03'),
  ('Ibrahima Barry','Kamsar Industries','ibrahima@demo.local','+224 610 00 00 04'),
  ('Néné Sylla','Nimba Culture','nene@demo.local','+224 610 00 00 05')
) as demo(name,company,email,phone)
where not exists (select 1 from public.clients c where c.email = demo.email);

insert into public.projects (client_id, title, slug, project_type, description, location, project_year, visibility, status, published, portfolio, featured)
select c.id, d.title, d.slug, d.type, d.description, 'Conakry, Guinée', 2026, 'PUBLIC', 'READY', true, true, d.featured
from (values
  ('aissatou@demo.local','Nocturne','nocturne-demo','PHOTO','ÉDITORIAL','Une étude de lumière et de mouvement dans la ville après la pluie.',true),
  ('mamadou@demo.local','Atlantique','atlantique-demo','FILM','FILM','Un récit corporate tourné entre le port et la côte guinéenne.',true),
  ('fatou@demo.local','Maison FB','maison-fb-demo','PHOTO','MODE','Une collection construite autour de la matière et du geste.',false),
  ('ibrahima@demo.local','Précision','precision-demo','FILM','CORPORATE','Portraits métiers et film de marque au rythme industriel.',false),
  ('nene@demo.local','Transmission','transmission-demo','PHOTO','CULTURE','Portraits documentaires consacrés aux gestes qui se transmettent.',false)
) as d(email,title,slug,type,category,description,featured)
join public.clients c on c.email = d.email
where not exists (select 1 from public.projects p where p.slug = d.slug);

insert into public.teams (name,specialty,email,phone)
select * from (values
 ('Kara Camara','Direction photo','kara@grsvision.com','+224 620 00 00 01'),
 ('Mariam Condé','Production','mariam@demo.local','+224 620 00 00 02'),
 ('Alpha Sow','Cadreur / monteur','alpha@demo.local','+224 620 00 00 03')
) as d(name,specialty,email,phone)
where not exists (select 1 from public.teams t where t.email = d.email);

insert into public.equipment (name,category,serial_number,quantity,status)
select * from (values
 ('Sony Alpha 7S III','Caméra','GRS-CAM-001',2,'AVAILABLE'),
 ('DJI Ronin RS 3 Pro','Stabilisation','GRS-GIM-001',1,'BOOKED'),
 ('Aputure 600D Pro','Éclairage','GRS-LGT-001',2,'AVAILABLE'),
 ('Zoom F6','Audio','GRS-AUD-001',1,'MAINTENANCE')
) as d(name,category,serial_number,quantity,status)
where not exists (select 1 from public.equipment e where e.serial_number = d.serial_number);
