import React, { createContext, useContext } from "react";
import Stock from "../../pages/Stock";
// Rutas definidas en el contexto
const RoutesContext = createContext();

export const RoutesProvider = ({ children }) => {
  const routes = [
    { id: 1, path: "/", name: "Home", element: <h2>Bienvenido al Home</h2> },
    {
      id: 2,
      path: "/perfil",
      name: "Perfil",
      element: <h2>Esta es la página de Perfil</h2>,
    },
    {
      id: 3,
      path: "/configuracion",
      name: "Configuración",
      element: <h2>Configuración de usuario</h2>,
    },
    ,
    {
      id: 4,
      path: "/stock",
      name: "Stock",
      element: <Stock />,
    },
  ];

  return (
    <RoutesContext.Provider value={routes}>{children}</RoutesContext.Provider>
  );
};

export const useRoutesContext = () => useContext(RoutesContext);
