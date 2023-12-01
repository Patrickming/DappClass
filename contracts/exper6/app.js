import express from 'express';
import bodyParser from 'body-parser';
import fileUpload from 'express-fileupload';
import { uploadJsonToIPFS, uploadFileToIPFS } from './ifps-uploader.js';

const app = express();

app.set('view engine', 'ejs');
app.use(bodyParser.urlencoded({ extended: true }));

app.use(fileUpload());



app.get('/', (req, res) => {
    res.render('home');
});

app.post('/upload', (req, res) => {
    console.log("body", req.body);
    const title = req.body.title;
    const description = req.body.description;
    // console.log("files", req.files);
    const file = req.files.file;
    const fileName = file.name;;
    const filePath = "files/" + fileName;
    file.mv(filePath, async err => {
        if (err) {
            console.log(err);
            return res.status(500).send(err);
        }
        const fileRestul = await uploadFileToIPFS(filePath);
        const fileCID = fileRestul.cid.toString();
        console.log("fileCID", fileCID);

        const metadata = {
            title: title,
            description: description,
            image: 'http://127.0.0.1:' + fileCID
        }

        const metadataResult = await uploadJsonToIPFS(metadata);
        const metadataCID = metadataResult.cid.toString();
        console.log("metadataCID", metadataCID);


        await mint()
        res.json({
            success: true,
            message: '上传成功',
            metadata: metadata,
        })
    })

    //上传图片到ipfs 获取CID


    //生成meta数据 包含CID、imageName、imageDesciption etc.


    //上传META数据到IPFS，获取CID


    //生成NFT，包含MTEA数据的CID


    //返回数据到前端
    res.json({
        success: true,
        message: '上传成功'
    })
});

const HOST = '127.0.0.1';
const PORT = 3000;

app.listen(PORT, HOST, () => {
    console.log(`服务已启动....listening on ${HOST}:${PORT}`);
});
