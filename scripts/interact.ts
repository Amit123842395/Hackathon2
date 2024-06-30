const hre = require("hardhat");

async function main() {
    // Get the deployer account
    const [deployer] = await hre.ethers.getSigners();
    console.log("Using the deployer account:", deployer.address);

    // Contract address and ABI
    const contractAddress = "0x8f86403A4DE0BB5791fa46B8e795C547942fE4Cf";
    const contractAbi = require("../artifacts/contracts/Competition.sol/Competition.json").abi;
    const token = "0x99bbA657f2BbC93c02D617f8bA121cB8Fc104Acf"
    // Create a contract instance
    const contract = new hre.ethers.Contract(contractAddress, contractAbi, deployer);

    // try {
    //     const tx = await contract.getScore({ gasLimit: 30000000 });
    //     console.log("Transaction successful:", tx);
    // } catch (error) {
    //     console.error("Error:", error);
    // }

    try {
        const balance = await contract.getTokenBalance(token, {gasLimit : 30000000});
        console.log("Balance:", balance);
    } catch (error) {
        console.log("Error:", error);
    }

    try {
        const tx = await contract.end(1, { gasLimit: 30000000 });
        console.log("Transaction successful:", tx);
    } catch (error) {
        console.error("Error:", error);
    }



    try { 
        const gameEnded = await contract.gameEnded();
        console.log("End?:",gameEnded);
    } catch (error){
        console.error("Error:",error);
    }

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });