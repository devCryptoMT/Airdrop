# Run on mainnet

1) Mint the "Airdrop.sol" in the ethereum mainnet
2) Install live-server in your terminal: npm install -g live-server
3) Be sure to have already deployed a ERC20 Token and approve (interacting with the ERC20 smart contract in function approve(spender, amount)) the Airdrop.sol smart contract address (spender) for the whole amount you want to do the airdrop.
4) Run the live-server and open the index.html page (be sure that js/index.js has the correct enviroment server for your specific purpose (testnet, mainnet, ecc), see https://www.moralis.io for further info)
5) Insert all your data inside the form (the owner of the smart contract is already whitelisted, in case you have to get the address whitelist, otherwise you will py 0.03ETH for the service)
6) Press to Login
7) Be sure about the same amount of data inside the textareas
8) Run Airdrop
9) On dev tools you can see the transaction hash and verify ithat it works.

