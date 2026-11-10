const express = require('express');
const mysql = require('mysql');

const bodyParser = require('body-parser');

const PORT = process.env.PORT || 3030;

const app = express();

app.use(bodyParser.json());

//MySql
const connection = mysql.createConnection({
    host: 'localhost',
    user:'ecobross',
    password:'rootpass',
    database:'ecobross',
});


//Route
app.get('/',(req,res) => {
    res.send('Welcome to my API!');
})

//all products

app.get('/productes',(req,res)=>{
    const sql = 'SELECT * FROM productes';

    connection.query(sql, (error,results) => {
        if (error) throw error;
        if (results.length > 0) {
            res.json(results);
        }else{
            res.send('Sense resultat');
        }
    });
});

app.get('/historial',(req,res)=>{
    const sql = 'SELECT * FROM historial';

    connection.query(sql, (error,results) => {
        if (error) throw error;
        if (results.length > 0) {
            res.json(results);
        }else{
            res.send('Sense resultat');
        }
    });
});


app.get('/productes/:codi',(req,res)=>{
    const { codi } = req.params;
    const sql = `SELECT * FROM productes WHERE codi = ${codi}`;
    connection.query(sql, (error,result) => {
        if (error) throw error;
        if (result.length > 0) {
            res.json(result);
        }else{ 
            res.send('Sense resultat');
        }
    });
});

app.get('/historial/:id',(req,res)=>{
    const { id } = req.params;
    const sql = `SELECT * FROM historial WHERE id = ${id}`;
    connection.query(sql, (error,result) => {
        if (error) throw error;
        if (result.length > 0) {
            res.json(result);
        }else{ 
            res.send('Sense resultat');
        }
    });
});

app.post('/add', (req, res) => {
    const sql = 'INSERT INTO historial SET ?';

    const historialObj = {
        id: req.body.id,
        titol: req.body.titol
        
    };

    connection.query(sql, historialObj, error => {
        if (error) throw error;
        res.send('historial creat!');
    });
});

app.post('/afegir', (req, res) => {
    const sql = 'INSERT INTO productes SET ?';

    const productesObj = {
        codi: req.body.codi,
        titol: req.body.titol,
        primer: req.body.primer,
        text1: req.body.text1,
        segon: req.body.segon,
        text2: req.body.text2
        
        
    };

    connection.query(sql, productesObj, error => {
        if (error) throw error;
        res.send('producte creat!');
    });
});

/*
app.put('/update/:id',(req,res)=>{
    const { id } = req.params;
    const { name, city } = req.body;
    const sql = `UPDATE customers SET name = '${name}', city='${city}' 
    WHERE id =${id}`;

    connection.query(sql, error => {
        if (error) throw error;
        res.send('Customer updated!');
    });
});
*/
/*
app.delete('/delete/:codi', (req,res)=>{
    const { codi } = req.params;
    const sql = `DELETE FROM historial WHERE codi= ${codi}`;
    
    connection.query(sql, error => {
        if (error) throw error;
        res.send('Delete product');
    });
});*/

app.delete('/delete',(req,res)=>{
    const sql = 'DELETE FROM historial';

    connection.query(sql, (error,results) => {
        if (error) throw error;
        if (results.length > 0) {
            res.json(results);
        }else{
            res.send('Sense resultat');
        }
    });
});



//Check connect
connection.connect(error =>{
    if (error) throw error;
    console.log('Database server running!');
});

app.listen(PORT, ()=>console.log(`Server running on port ${PORT}`))

