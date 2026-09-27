alter table public.teams add column if not exists image_url text;
alter table public.equipment add column if not exists image_url text;

create or replace function public.create_client_gallery_link(
  p_project_id uuid,
  p_pin text,
  p_expires_at timestamptz default null,
  p_download_enabled boolean default true,
  p_selection_enabled boolean default true,
  p_comments_enabled boolean default true,
  p_approval_enabled boolean default true
)
returns table(token text, expires_at timestamptz)
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_token text := encode(gen_random_bytes(18), 'hex');
  v_expiry timestamptz := coalesce(p_expires_at, now() + interval '30 days');
begin
  if not public.is_studio_admin() then
    raise exception 'Accès administrateur requis';
  end if;
  if length(trim(p_pin)) < 4 then
    raise exception 'Le code doit contenir au moins 4 caractères';
  end if;
  insert into public.client_links (
    project_id, token_hash, pin_hash, expires_at, download_enabled,
    selection_enabled, comments_enabled, approval_enabled, active
  ) values (
    p_project_id,
    encode(digest(v_token, 'sha256'), 'hex'),
    encode(digest(trim(p_pin), 'sha256'), 'hex'),
    v_expiry, p_download_enabled, p_selection_enabled,
    p_comments_enabled, p_approval_enabled, true
  );
  return query select v_token, v_expiry;
end;
$$;

create or replace function public.get_client_gallery(p_token text, p_pin text)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_link public.client_links%rowtype;
  v_result jsonb;
begin
  select * into v_link
  from public.client_links
  where token_hash = encode(digest(p_token, 'sha256'), 'hex')
    and pin_hash = encode(digest(trim(p_pin), 'sha256'), 'hex')
    and active = true
    and (expires_at is null or expires_at > now())
  limit 1;

  if v_link.id is null then return null; end if;

  select jsonb_build_object(
    'linkId', v_link.id,
    'project', jsonb_build_object(
      'id', p.id, 'title', p.title, 'description', p.description,
      'selectionLimit', p.selection_limit
    ),
    'permissions', jsonb_build_object(
      'download', v_link.download_enabled, 'selection', v_link.selection_enabled,
      'comments', v_link.comments_enabled, 'approval', v_link.approval_enabled
    ),
    'media', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', m.id, 'bucket', m.storage_bucket, 'path', m.storage_path,
        'type', m.media_type, 'mime', m.mime_type, 'caption', pm.caption,
        'downloadable', pm.is_downloadable
      ) order by pm.position)
      from public.project_media pm
      join public.media_assets m on m.id = pm.media_id
      where pm.project_id = p.id
    ), '[]'::jsonb)
  ) into v_result
  from public.projects p where p.id = v_link.project_id;

  insert into public.analytics_events(event_type, project_id, client_link_id, metadata)
  values ('GALLERY_OPEN', v_link.project_id, v_link.id, jsonb_build_object('source','client-gallery'));
  return v_result;
end;
$$;

create or replace function public.record_client_download(p_token text, p_media_id uuid, p_kind text default 'ORIGINAL')
returns boolean
language plpgsql
security definer
set search_path = public, extensions
as $$
declare v_link public.client_links%rowtype;
begin
  select * into v_link from public.client_links
  where token_hash = encode(digest(p_token, 'sha256'), 'hex')
    and active = true and download_enabled = true
    and (expires_at is null or expires_at > now()) limit 1;
  if v_link.id is null then return false; end if;
  if not exists(select 1 from public.project_media where project_id=v_link.project_id and media_id=p_media_id) then return false; end if;
  insert into public.downloads(project_id, media_id, kind) values(v_link.project_id,p_media_id,p_kind);
  insert into public.analytics_events(event_type, project_id, media_id, client_link_id, metadata)
  values('DOWNLOAD',v_link.project_id,p_media_id,v_link.id,jsonb_build_object('kind',p_kind));
  return true;
end;
$$;

grant execute on function public.create_client_gallery_link(uuid,text,timestamptz,boolean,boolean,boolean,boolean) to authenticated;
grant execute on function public.get_client_gallery(text,text) to anon, authenticated;
grant execute on function public.record_client_download(text,uuid,text) to anon, authenticated;
