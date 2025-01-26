import React, { createContext, useContext, useState } from "react";
import { use } from "react";

const ApiContext = createContext();


const ApiProvider = ({children}) => {
  const API_URL = "http://localhost:5000/api";

  return (
   <ApiContext.Provider value={{API_URL}}>
    {children}
   </ApiContext.Provider>
  )
}

const useApiContext = () => useContext(ApiContext);

export {ApiProvider, useApiContext};