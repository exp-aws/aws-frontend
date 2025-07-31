import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'

function App() {
  const [count, setCount] = useState(0)
  const [message, setMessage] = useState('')

  const backendApiUrl = import.meta.env.VITE_API_URL

  console.log('VITE_API_URL:', backendApiUrl)
  console.log('Environment variables:', import.meta.env)


  const callApi = () => {
    fetch(`${backendApiUrl}/`)
      .then(response => response.json())
      .then(json => setMessage(json.message))
      .catch(error => console.error('Error:', error));
  }

  return (
    <>
      <div>
        <a href="https://vite.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vite + React</h1>
      <div className="card">
        <p>Backend API: {backendApiUrl || 'undefined'}</p>
        {!backendApiUrl && (
          <p style={{ color: 'red' }}>⚠️ VITE_API_URL is not set!</p>
        )}
        <button onClick={callApi}>
          Call Api
        </button>
        <p>{message}</p>
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>
          Edit <code>src/App.tsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
        Update version 2 and let verify that ecs will pick new image
      </p>
    </>
  )
}

export default App
