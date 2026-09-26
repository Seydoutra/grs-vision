import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL?.trim()
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY?.trim()

export const supabaseConfigured = Boolean(url && anonKey)

export const supabase = supabaseConfigured
  ? createClient(url!, anonKey!, {
      auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true },
    })
  : null

export async function trackEvent(eventType: string, metadata: Record<string, unknown> = {}) {
  if (!supabase) return
  await supabase.from('analytics_events').insert({
    event_type: eventType,
    anonymous_session_hash: getAnonymousSession(),
    metadata,
  })
}

function getAnonymousSession() {
  const key = 'grs-anonymous-session'
  let value = localStorage.getItem(key)
  if (!value) {
    value = crypto.randomUUID()
    localStorage.setItem(key, value)
  }
  return value
}
