const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Market", function () {
  let usdt, market, myNft, account1, account2;

  beforeEach(async () => {
    [account1, account2] = await ethers.getSigners();
    // const MAX_ALLOWANCE = BigNumber.from(2).pow(256).sub(1);
    const USDT = await ethers.getContractFactory("cUSDT");
    usdt = await USDT.deploy();
    const MyNFT = await ethers.getContractFactory("MyNFT");
    myNft = await MyNFT.deploy(account1.address);
    const Market = await ethers.getContractFactory("Market");
    market = await Market.deploy(usdt.address, myNft.address);
    // console.log(account1)

    await myNft.safeMint(account1.address, 0, "https://sameple.com/0");
    await myNft.safeMint(account1.address, 1, "https://sameple.com/1");
    await myNft.approve(market.address, 0);
    await myNft.approve(market.address, 1);
    await usdt.connect(account1).transfer(account2.address, "10000000000000000000000");
    await usdt.connect(account2).approve(market.address, "1000000000000000000");
  });

  it('its erc20 address should be usdt', async function () {
    expect(await market.erc20()).to.equal(usdt.address);
  });

  it('its erc721 address should be myNft', async function () {
    expect(await market.erc721()).to.equal(myNft.address);
  });

  it('account1 should have 2 nfts', async function () {
    expect((await myNft.balanceOf(account1.address)).toString()).to.equal("2");
  });

  it('account2 should have 10000 USDT', async function () {
    expect((await usdt.balanceOf(account2.address)).toString()).to.equal('10000000000000000000000');
  });

  it('account2 should have 0 nfts', async function () {
    expect((await myNft.balanceOf(account2.address)).toNumber()).to.equal(0);
  });

  it('account1 can list two nfts to market', async function () {

    it('account1 can list two nfts to market', async function () {
      // 将两个NFT上架到市场
      await myNft.connect(account1).safeTransferFrom(account1.address, market.address, 0, "0x0000000000000000000000000000000000000000000000000DE0B6B3A7640000");
      await myNft.connect(account1).safeTransferFrom(account1.address, market.address, 1, "0x0000000000000000000000000000000000000000000000000DE0B6B3A7640000");

      // 检查订单是否正确创建
      expect(await market.getOrderLength()).to.equal(2);

    });

  });
  it('account1 can unlist one nft from market', async function () {
    it('account1 can unlist one nft from market', async function () {
      //上架一个nft
      await myNft.connect(account1).safeTransferFrom(account1.address, market.address, 0, "0x0000000000000000000000000000000000000000000000000DE0B6B3A7640000");
      // 要下架的tokenId
      const tokenId = 0;
      // 将一个NFT从市场下架
      await market.connect(account1).cancelOrder(tokenId);
      // 检查订单是否正确删除
      expect(await market.isList(tokenId)).to.equal(false);
    });
  });
  it('account1 can change price of nft from market', async function () {
    it('account1 can change price of nft from market', async function () {
      //上架一个nft
      await myNft.connect(account1).safeTransferFrom(account1.address, market.address, 0, "0x0000000000000000000000000000000000000000000000000DE0B6B3A7640000");
      // 更改NFT在市场上的价格 1 -> 0.5
      await market.changePrice(0, 500000000000000000);
      // 检查价格是否正确更新
      expect(await market.orderOfId(0).price).to.equal(500000000000000000);
    });
  });
  it('account2 can buy nft from market', async function () {
    it('account2 can buy nft from market', async function () {
      //上架一个nft 价格为1000000000000000000
      await myNft.connect(account1).safeTransferFrom(account1.address, market.address, 0, "0x0000000000000000000000000000000000000000000000000DE0B6B3A7640000");
      // 从市场购买NFT
      await market.connect(account2).buy(0, { value: await market.orderOfId(0).price });
      // 检查交易是否成功，NFT是否正确转移
      expect(await myNft.ownerOf(0)).to.equal(account2.address);
    });
  });
})