const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Airdrop - Initialization", function () {
  it("Check owner address on init", async function () {
    const [owner] = await ethers.getSigners();
    const ownerAddress = await owner.getAddress();
    const Airdrop = await ethers.getContractFactory("Airdrop");
    const airdrop = await Airdrop.deploy();
    await airdrop.deployed();
    expect(await airdrop.getOwner()).to.equal(ownerAddress);
  });
  it("Check if owner is whitelisted on init", async function () {
    const [owner] = await ethers.getSigners();
    const ownerAddress = await owner.getAddress();
    const Airdrop = await ethers.getContractFactory("Airdrop");
    const airdrop = await Airdrop.deploy();
    await airdrop.deployed();
    expect(await airdrop.getIsWhitelisted(ownerAddress)).to.equal(true);
  });
  it("Check if price is 0.03 ETH on init", async function () { // to do 
    const [owner] = await ethers.getSigners();
    const ownerAddress = await owner.getAddress();
    const Airdrop = await ethers.getContractFactory("Airdrop");
    const airdrop = await Airdrop.deploy();
    const price = ethers.utils.parseEther("0.03");
    await airdrop.deployed();
    expect(await airdrop.getPrice()).to.equal(price);
  });
});

describe("Airdrop - Owner Functions", function () {
    it("SwitchWhitelist returns the switched value", async function () { // to do 
        const [owner] = await ethers.getSigners();
        const ownerAddress = await owner.getAddress();
        const Airdrop = await ethers.getContractFactory("Airdrop");
        const airdrop = await Airdrop.deploy();
        const price = ethers.utils.parseEther("0.03");
        await airdrop.deployed();
        expect(await airdrop.getPrice()).to.equal(price);
      });
      it("SwitchWhitelist can't be run from no-owner address", async function () { // to do 
        const [owner] = await ethers.getSigners();
        const ownerAddress = await owner.getAddress();
        const Airdrop = await ethers.getContractFactory("Airdrop");
        const airdrop = await Airdrop.deploy();
        const price = ethers.utils.parseEther("0.03");
        await airdrop.deployed();
        expect(await airdrop.getPrice()).to.equal(price);
      });
      it("ChangePrice returns the price changed when different", async function () { // to do 
        const [owner] = await ethers.getSigners();
        const ownerAddress = await owner.getAddress();
        const Airdrop = await ethers.getContractFactory("Airdrop");
        const airdrop = await Airdrop.deploy();
        const price = ethers.utils.parseEther("0.03");
        await airdrop.deployed();
        expect(await airdrop.getPrice()).to.equal(price);
      });
      it("ChangePrice revert when the price is the same", async function () { // to do 
        const [owner] = await ethers.getSigners();
        const ownerAddress = await owner.getAddress();
        const Airdrop = await ethers.getContractFactory("Airdrop");
        const airdrop = await Airdrop.deploy();
        const price = ethers.utils.parseEther("0.03");
        await airdrop.deployed();
        expect(await airdrop.getPrice()).to.equal(price);
      });
      it("Withdraw owner balance", async function () { // to do 
        const [owner] = await ethers.getSigners();
        const ownerAddress = await owner.getAddress();
        const Airdrop = await ethers.getContractFactory("Airdrop");
        const airdrop = await Airdrop.deploy();
        const price = ethers.utils.parseEther("0.03");
        await airdrop.deployed();
        expect(await airdrop.getPrice()).to.equal(price);
      });
      it("Withdraw can't be done if balance is null", async function () { // to do 
        const [owner] = await ethers.getSigners();
        const ownerAddress = await owner.getAddress();
        const Airdrop = await ethers.getContractFactory("Airdrop");
        const airdrop = await Airdrop.deploy();
        const price = ethers.utils.parseEther("0.03");
        await airdrop.deployed();
        expect(await airdrop.getPrice()).to.equal(price);
      });
      it("Withdraw can't be done if sender is not the owner", async function () { // to do 
        const [owner] = await ethers.getSigners();
        const ownerAddress = await owner.getAddress();
        const Airdrop = await ethers.getContractFactory("Airdrop");
        const airdrop = await Airdrop.deploy();
        const price = ethers.utils.parseEther("0.03");
        await airdrop.deployed();
        expect(await airdrop.getPrice()).to.equal(price);
      });
});

describe("Airdrop - Users Functions", function () {
    it("Increase user balance", async function () { // to do 
        const [owner] = await ethers.getSigners();
        const ownerAddress = await owner.getAddress();
        const Airdrop = await ethers.getContractFactory("Airdrop");
        const airdrop = await Airdrop.deploy();
        const price = ethers.utils.parseEther("0.03");
        await airdrop.deployed();
        expect(await airdrop.getPrice()).to.equal(price);
      });
      it("Run Airdrop", async function () { // to do 
        const [owner] = await ethers.getSigners();
        const ownerAddress = await owner.getAddress();
        const Airdrop = await ethers.getContractFactory("Airdrop");
        const airdrop = await Airdrop.deploy();
        const price = ethers.utils.parseEther("0.03");
        await airdrop.deployed();
        expect(await airdrop.getPrice()).to.equal(price);
      });
});



