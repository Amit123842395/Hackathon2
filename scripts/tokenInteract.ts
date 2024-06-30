import { ethers } from "ethers";
import * as hre from "hardhat";

async function main() {
    // Get the deployer account
    const [deployer] = await hre.ethers.getSigners();
    console.log("Using the deployer account:", deployer.address);

    // Contract address and ABI
    const tokenAddress = "0x99bbA657f2BbC93c02D617f8bA121cB8Fc104Acf";
    const to = "0x8f86403A4DE0BB5791fa46B8e795C547942fE4Cf";
    const contractAbi = require("../artifacts/contracts/Token.sol/Token.json").abi;

    // Create a contract instance
    const contract = new hre.ethers.Contract(tokenAddress, contractAbi, deployer);


    try {
        const tx = await contract.mint(to, { gasLimit: 30000000 });
        console.log("Transaction successful:", tx);
    } catch (error) {
        console.error("Error:", error);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });