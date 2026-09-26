create type document_status as enum ('DRAFT','SENT','ACCEPTED','REJECTED','PAID','OVERDUE','CANCELLED');

create table service_catalog (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  unit text,
  default_price numeric(14,2),
  active boolean not null default true,
  position int not null default 0,
  created_at timestamptz not null default now()
);

create table quotes (
  id uuid primary key default gen_random_uuid(),
  number text not null unique,
  client_id uuid not null references clients on delete restrict,
  project_id uuid references projects on delete set null,
  status document_status not null default 'DRAFT',
  issue_date date not null default current_date,
  valid_until date,
  subtotal numeric(14,2) not null default 0,
  tax_total numeric(14,2) not null default 0,
  total numeric(14,2) not null default 0,
  currency text not null default 'GNF',
  notes text,
  accepted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table quote_items (
  id uuid primary key default gen_random_uuid(),
  quote_id uuid not null references quotes on delete cascade,
  service_id uuid references service_catalog on delete set null,
  description text not null,
  quantity numeric(12,2) not null default 1,
  unit_price numeric(14,2) not null,
  position int not null default 0
);

create table invoices (
  id uuid primary key default gen_random_uuid(),
  number text not null unique,
  client_id uuid not null references clients on delete restrict,
  project_id uuid references projects on delete set null,
  quote_id uuid references quotes on delete set null,
  status document_status not null default 'DRAFT',
  issue_date date not null default current_date,
  due_date date,
  subtotal numeric(14,2) not null default 0,
  tax_total numeric(14,2) not null default 0,
  total numeric(14,2) not null default 0,
  amount_paid numeric(14,2) not null default 0,
  currency text not null default 'GNF',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table invoice_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references invoices on delete cascade,
  service_id uuid references service_catalog on delete set null,
  description text not null,
  quantity numeric(12,2) not null default 1,
  unit_price numeric(14,2) not null,
  position int not null default 0
);

create table payments (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references invoices on delete restrict,
  amount numeric(14,2) not null check (amount > 0),
  currency text not null default 'GNF',
  method text,
  reference text,
  paid_at timestamptz not null default now(),
  notes text
);

create table analytics_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,
  project_id uuid references projects on delete set null,
  media_id uuid references media_assets on delete set null,
  client_link_id uuid references client_links on delete set null,
  anonymous_session_hash text,
  metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);

alter table service_catalog enable row level security;
alter table quotes enable row level security;
alter table quote_items enable row level security;
alter table invoices enable row level security;
alter table invoice_items enable row level security;
alter table payments enable row level security;
alter table analytics_events enable row level security;

create policy "admins manage services" on service_catalog for all using (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN')) with check (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN'));
create policy "admins manage quotes" on quotes for all using (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN')) with check (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN'));
create policy "admins manage quote items" on quote_items for all using (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN')) with check (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN'));
create policy "admins manage invoices" on invoices for all using (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN')) with check (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN'));
create policy "admins manage invoice items" on invoice_items for all using (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN')) with check (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN'));
create policy "admins manage payments" on payments for all using (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN')) with check (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN'));
create policy "admins read analytics" on analytics_events for select using (exists(select 1 from profiles where profiles.id=auth.uid() and profiles.role='SUPER_ADMIN'));
