const { getConnection } = require("../config/db");

exports.ejemplo = async()=>{
    return getConnection();
} 
