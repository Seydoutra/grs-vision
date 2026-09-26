import { createRoot } from 'react-dom/client'
import { HashRouter } from 'react-router-dom'
import App from './App'
import './styles.css'
import './admin-overrides.css'

createRoot(document.getElementById('root')!).render(<HashRouter><App /></HashRouter>)
