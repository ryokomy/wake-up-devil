const Web3 = require('web3')
const web3 = new Web3();
web3.setProvider(new Web3.providers.HttpProvider("https://rinkeby.infura.io/"));
const privateKey = require('../../truffle-config').privatekey
const ownerAccount = web3.eth.accounts.privateKeyToAccount('0x' + privateKey)
web3.eth.accounts.wallet.add(ownerAccount); // web3.eth.accounts.wallet[0] == ownerAccount

let tenDaysWakeUpDevil_abi = require('../../build/contracts/TenDaysWakeUpDevil.json').abi
let tenDaysWakeUpDevil_address = require('../../build/contracts/TenDaysWakeUpDevil.json').networks['4'].address
const TenDaysWakeUpDevil = new web3.eth.Contract(tenDaysWakeUpDevil_abi, tenDaysWakeUpDevil_address)
for(let contract of [TenDaysWakeUpDevil]){
    contract.options.from = web3.eth.accounts.wallet[0].address; // default from address
    contract.options.gasPrice = '1000000000'; // default gas price in wei (1 Gwei)
    contract.options.gas = 3000000; // provide as fallback always 3M gas
}

const main = async () => {
    let result = await TenDaysWakeUpDevil.methods.userAddressToWakeUpUnit(ownerAccount.address).call()
    console.log(result)
}

main()