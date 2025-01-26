import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { ApiProvider } from './contexts/api/ApiContext.jsx'
import App from './App.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <ApiProvider>
      <App />
      </ApiProvider>
  </StrictMode>,
)
