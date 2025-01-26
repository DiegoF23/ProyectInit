import React from 'react'
import Header from '../layouts/Header'
import MainStock from '../components/Stock/MainStock'
const Stock = () => {
  return (
    <div>
        <Header />
        <div className="p-4">
            <h1 className="text-2xl font-bold text-gray-800">Stock</h1>
            <MainStock/>
        </div>
    </div>
  )
}

export default Stock