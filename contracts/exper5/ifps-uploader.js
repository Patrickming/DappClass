import { create } from 'kubo-rpc-client'
import fs from 'fs'

const ipfs_url = 'http://127.0.0.1:5001'
const ipfs = creat(new URL(ipfs_url))

async function uploadFileToIPFS(filepath) {
    const file = fs.readFileSync('filepath')
    const result = await ipfs.add({ path: filepath, content: file })
    // console.log(result)
    return result
}


async function uploadJsonToIPFS(json) {
    const result = await ipfs.add(JSON.stringify(json))
    // console.log(result)
    return result
}

// uploadFileToIPFS('./app.js')
// uploadJsonToIPFS({
//     "name": "app.js",
// })


export default {
    uploadFileToIPFS,
    uploadJsonToIPFS,
}