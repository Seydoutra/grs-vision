import { createRoot } from 'react-dom/client'
import { HashRouter } from 'react-router-dom'
import App from './App'
import './styles.css'
import './admin-overrides.css'
import './refinement.css'
import './admin-os.css'

// Supabase places recovery/invitation tokens in the URL fragment. Remember the
// intent before HashRouter replaces that fragment with the application route.
if (/type=(recovery|invite)/.test(window.location.hash)) {
  sessionStorage.setItem('grs-password-setup', '1')
}

createRoot(document.getElementById('root')!).render(<HashRouter><App /></HashRouter>)
