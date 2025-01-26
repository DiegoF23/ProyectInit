// src/components/Dashboard.jsx
import React from "react";
import { Routes, Route } from "react-router-dom";
import Menu from "./Menu";
import { useRoutesContext } from "../../contexts/Routes/RoutesContext";

const Dashboard = () => {
  const routes = useRoutesContext();

  return (
    <div className="h-screen">
      {/* Menú */}
      <Menu />

      {/* Configuración de rutas */}
      <main className="p-4">
        <Routes>
          {routes.map((route) => (
            <Route key={route.id} path={route.path} element={route.element} />
          ))}
        </Routes>
      </main>
    </div>
  );
};

export default Dashboard;

