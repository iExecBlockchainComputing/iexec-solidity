var Identity = artifacts.require("./Identity.sol");

const tools = require("../utils/tools.js")

function extractEvents(txMined, address, name)
{
	return txMined.logs.filter((ev) => { return ev.address == address && ev.event == name });
}

contract('Identity: ERC1077', async (accounts) => {

	// assert.isAtLeast(accounts.length, 10, "should have at least 10 accounts");

	var accounthashs = {}
	for (id in accounts)
	{
		accounthashs[id] = {
			addr: accounts[id],
			key:  web3.utils.keccak256(accounts[id]),
		};
	}

	var IdentityInstance = null;

	/***************************************************************************
	 *                        Environment configuration                        *
	 ***************************************************************************/
	before("configure", async () => {
		console.log("# web3 version:", web3.version);
		IdentityInstance = await Identity.new(accounthashs[0].key)
	});

	it("Adding action capability", async () => {
		await IdentityInstance.addKey(accounthashs[0].key, 2, 1, { from: accounthashs[0].addr })
	});

	it("---", async () => {

		console.log("balance id:", web3.utils.fromWei(await web3.eth.getBalance(IdentityInstance.address), "ether"));
		console.log("balance 0: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[0]),              "ether"));
		console.log("balance 1: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[1]),              "ether"));

		await web3.eth.sendTransaction({
			from:  accounts[0],
			to:    IdentityInstance.address,
			value: web3.utils.toWei("1", "ether")
		});

		console.log("balance id:", web3.utils.fromWei(await web3.eth.getBalance(IdentityInstance.address), "ether"));
		console.log("balance 0: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[0]),              "ether"));
		console.log("balance 1: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[1]),              "ether"));

		tx = {
			from:     IdentityInstance.address,
			to:       accounts[1],
			// gasPrice: "20000000000",
			// gas:      "21000",
			value:    web3.utils.toWei("1", "ether"),
			data:     "0x",
			nonce:    Number(await IdentityInstance.lastNonce()),
		};

		tx.signature = await web3.eth.sign(
			web3.utils.keccak256(web3.eth.abi.encodeParameters([
				"address",
				"address",
				"uint256",
				"bytes",
				"uint256",
			],[
				tx.from,
				tx.to,
				tx.value,
				tx.data,
				tx.nonce,
			])),
			accounts[0]
		);

		txMined = await IdentityInstance.executeSigned(
			tx.to,
			tx.value,
			tx.data,
			tx.nonce,
			tx.signature,
			{ from : accounts[5] }
		);

		console.log("balance id:", web3.utils.fromWei(await web3.eth.getBalance(IdentityInstance.address), "ether"));
		console.log("balance 0: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[0]),              "ether"));
		console.log("balance 1: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[1]),              "ether"));

	});

});
