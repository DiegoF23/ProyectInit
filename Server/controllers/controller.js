const { getConnection } = require("../config/DB/db");

exports.ejemplo = async()=>{
    return getConnection();
} 
