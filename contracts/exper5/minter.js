import {ethers, JsonRpcProvider} from 'ethers'
import fs from 'fs'

async function main(address , uri) {
    const provider = new JsonRpcProvider(''
    )
    const signer = await provider.getSigner()
    const abi = JSON.parse(fs.readFileSync("./abis/MyNFT.json, 'utf8'")) 
