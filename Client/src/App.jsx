import React from "react";
import { useApiContext } from "./contexts/api/ApiContext";
import Dashboard from "./components/Default/Dashboard";
import { BrowserRouter } from "react-router-dom";
import { RoutesProvider } from "./contexts/Routes/RoutesContext";

function App() {
  const { API_URL } = useApiContext();
  return (
    <>
      <BrowserRouter>
        <div>
          <h3>Api : {API_URL}</h3>
          <RoutesProvider>
            <Dashboard />
          </RoutesProvider>
        </div>
      </BrowserRouter>
    </>
  );
}

export default App;
