import express from 'express';
import bodyParser from 'body-parser';
import fileUpload from 'express-fileupload';

const app = express();

app.set('view engine', 'ejs');
app.use(bodyParser.urlencoded({ extended: true }));

app.use(fileUpload());



app.get('/', (req, res) => {
    res.render('home');
});

app.post('/upload', (req, res) => {
    console.log("body",req.body);
    console.log("files",req.files);
    res.render('home');
});

const HOST = '127.0.0.1';
const PORT = 3000;

app.listen(PORT, HOST, () => {
    console.log(`服务已启动。。。listening on ${HOST}:${PORT}`);
});
