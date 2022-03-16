
//MORALIS TESTNET RINKEBY
const serverUrl = "https://qqnf86y257ut.usemoralis.com:2053/server";
const appId = "h735OH4yaUDawjqzTfCe46mL05SSjk0InhyEWqYH";

//MORALIS MAINNET ETHEREUM
//const serverUrl = "https://qyb97uqq7j9u.usemoralis.com:2053/server";
//const appId = "vbzpGY8uBJdIM6IZZ1V0cLiuikbsIh9zzWDLXpgH";

Moralis.start({ serverUrl, appId });

async function login() {
    let user = Moralis.User.current();
    if (!user) {
        user = await Moralis.Web3.authenticate();
    }
    console.log("logged in user:", user);
}

async function logOut() {
    await Moralis.User.logOut();
    console.log("logged out");
}

// bind button click handlers
document.getElementById("btn-login").onclick = login;
document.getElementById("btn-logout").onclick = logOut;
document.getElementById("btn-airdrop").onclick = runAirdrop;

async function runAirdrop() {
    Moralis.authenticate({signingMessage:"hello"})
    console.log("Running airdrop...");
    const ABI = [
                    {
                    "inputs": [],
                    "stateMutability": "nonpayable",
                    "type": "constructor"
                    },
                    {
                    "anonymous": false,
                    "inputs": [
                        {
                        "indexed": false,
                        "internalType": "address",
                        "name": "token",
                        "type": "address"
                        },
                        {
                        "indexed": false,
                        "internalType": "address[]",
                        "name": "addresses",
                        "type": "address[]"
                        },
                        {
                        "indexed": false,
                        "internalType": "uint256[]",
                        "name": "values",
                        "type": "uint256[]"
                        }
                    ],
                    "name": "AirdropEvent",
                    "type": "event"
                    },
                    {
                    "anonymous": false,
                    "inputs": [
                        {
                        "indexed": false,
                        "internalType": "address",
                        "name": "user",
                        "type": "address"
                        },
                        {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "oldBalance",
                        "type": "uint256"
                        },
                        {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "newBalance",
                        "type": "uint256"
                        }
                    ],
                    "name": "BalanceChange",
                    "type": "event"
                    },
                    {
                    "anonymous": false,
                    "inputs": [
                        {
                        "indexed": false,
                        "internalType": "address",
                        "name": "owner",
                        "type": "address"
                        },
                        {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                        }
                    ],
                    "name": "OwnerWithdraw",
                    "type": "event"
                    },
                    {
                    "anonymous": false,
                    "inputs": [
                        {
                        "indexed": false,
                        "internalType": "address",
                        "name": "owner",
                        "type": "address"
                        },
                        {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "oldPrice",
                        "type": "uint256"
                        },
                        {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "newPrice",
                        "type": "uint256"
                        }
                    ],
                    "name": "PriceChange",
                    "type": "event"
                    },
                    {
                    "anonymous": false,
                    "inputs": [
                        {
                        "indexed": false,
                        "internalType": "address",
                        "name": "owner",
                        "type": "address"
                        },
                        {
                        "indexed": false,
                        "internalType": "address",
                        "name": "whitelistedAddress",
                        "type": "address"
                        },
                        {
                        "indexed": false,
                        "internalType": "bool",
                        "name": "isEnabled",
                        "type": "bool"
                        }
                    ],
                    "name": "WhitelistSwitch",
                    "type": "event"
                    },
                    {
                    "inputs": [
                        {
                        "internalType": "uint256",
                        "name": "_newPrice",
                        "type": "uint256"
                        }
                    ],
                    "name": "changePrice",
                    "outputs": [
                        {
                        "internalType": "bool",
                        "name": "",
                        "type": "bool"
                        }
                    ],
                    "stateMutability": "nonpayable",
                    "type": "function"
                    },
                    {
                    "inputs": [
                        {
                        "internalType": "address",
                        "name": "_user",
                        "type": "address"
                        }
                    ],
                    "name": "getBalance",
                    "outputs": [
                        {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                        }
                    ],
                    "stateMutability": "view",
                    "type": "function"
                    },
                    {
                    "inputs": [
                        {
                        "internalType": "address",
                        "name": "_userAddress",
                        "type": "address"
                        }
                    ],
                    "name": "getFinalPrice",
                    "outputs": [
                        {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                        }
                    ],
                    "stateMutability": "view",
                    "type": "function"
                    },
                    {
                    "inputs": [
                        {
                        "internalType": "address",
                        "name": "_user",
                        "type": "address"
                        }
                    ],
                    "name": "getIsWhitelisted",
                    "outputs": [
                        {
                        "internalType": "bool",
                        "name": "",
                        "type": "bool"
                        }
                    ],
                    "stateMutability": "view",
                    "type": "function"
                    },
                    {
                    "inputs": [],
                    "name": "getOwner",
                    "outputs": [
                        {
                        "internalType": "address",
                        "name": "",
                        "type": "address"
                        }
                    ],
                    "stateMutability": "view",
                    "type": "function"
                    },
                    {
                    "inputs": [],
                    "name": "getPrice",
                    "outputs": [
                        {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                        }
                    ],
                    "stateMutability": "view",
                    "type": "function"
                    },
                    {
                    "inputs": [],
                    "name": "increaseBalance",
                    "outputs": [
                        {
                        "internalType": "bool",
                        "name": "",
                        "type": "bool"
                        }
                    ],
                    "stateMutability": "payable",
                    "type": "function"
                    },
                    {
                    "inputs": [
                        {
                        "internalType": "address",
                        "name": "_token",
                        "type": "address"
                        },
                        {
                        "internalType": "address[]",
                        "name": "_addresses",
                        "type": "address[]"
                        },
                        {
                        "internalType": "uint256[]",
                        "name": "_values",
                        "type": "uint256[]"
                        }
                    ],
                    "name": "runAirdrop",
                    "outputs": [
                        {
                        "internalType": "bool",
                        "name": "",
                        "type": "bool"
                        }
                    ],
                    "stateMutability": "payable",
                    "type": "function"
                    },
                    {
                    "inputs": [
                        {
                        "internalType": "address",
                        "name": "_whitelistedAddress",
                        "type": "address"
                        }
                    ],
                    "name": "switchWhitelist",
                    "outputs": [
                        {
                        "internalType": "bool",
                        "name": "",
                        "type": "bool"
                        }
                    ],
                    "stateMutability": "nonpayable",
                    "type": "function"
                    },
                    {
                    "inputs": [],
                    "name": "withdrawOwnerBalance",
                    "outputs": [
                        {
                        "internalType": "bool",
                        "name": "",
                        "type": "bool"
                        }
                    ],
                    "stateMutability": "payable",
                    "type": "function"
                    }
                ];
    const token = document.getElementById("tokenAddress").value;
    const airdropAddress = document.getElementById("airdropAddress").value;
    const addresses = document.getElementById("addresses").value.split(",");
    const values = document.getElementById("values").value.split(",");
    console.log(token);
    console.log(addresses);
    console.log(values);
        let options = {
            contractAddress: airdropAddress,
            functionName: "runAirdrop",
            abi: ABI,
            params:{
                _token: token,
                _addresses: addresses,
                _values: values
                },
            msgValue: 0
            }

    const transaction = await Moralis.executeFunction(options);        
    console.log(transaction);
    console.log("End airdrop")
}