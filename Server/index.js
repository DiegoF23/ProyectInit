require("dotenv").config();
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const app = express();


const ejemplo = require("./controllers/controller");


const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(bodyParser.json());


app.listen(port, () => {
    console.log(`Server is running on port ${port}`)
    ejemplo.ejemplo()
});