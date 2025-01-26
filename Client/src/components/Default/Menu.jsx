// src/components/Menu.jsx
import React from "react";
import { Link } from "react-router-dom";
import { useRoutesContext } from "../../contexts/Routes/RoutesContext";

const Menu = () => {
  const routes = useRoutesContext();

  return (
    <nav className="p-4 border-b">
      <ul className="flex space-x-4">
        {routes.map((route) => (
          <li key={route.id}>
            <Link
              to={route.path}
              className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
            >
              {route.name}
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
};

export default Menu;

