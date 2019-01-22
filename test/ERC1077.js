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


	it("balance before", async () => {
		console.log("balance id:", web3.utils.fromWei(await web3.eth.getBalance(IdentityInstance.address), "ether"));
		console.log("balance 0: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[0]),              "ether"));
		console.log("balance 1: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[1]),              "ether"));
	});

	it("tx", async () => {
		await web3.eth.sendTransaction({
			from:  accounts[0],
			to:    IdentityInstance.address,
			value: web3.utils.toWei("1", "ether")
		});
	});

	it("balance after", async () => {
		console.log("balance id:", web3.utils.fromWei(await web3.eth.getBalance(IdentityInstance.address), "ether"));
		console.log("balance 0: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[0]),              "ether"));
		console.log("balance 1: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[1]),              "ether"));
	});

	function signMetaTx(metatx, signer)
	{
		return new Promise(async (resolve, reject) => {
			metatx.value    = metatx.value    || 0;
			metatx.data     = metatx.data     || "0x";
			metatx.nonce    = metatx.nonce    || Number(await IdentityInstance.keyNonce(web3.utils.keccak256([ "address" ], [ signer ])));
			metatx.gas      = metatx.gas      || 0;
			metatx.gasPrice = metatx.gasPrice || 0;
			metatx.gasToken = metatx.gasToken || "0x0000000000000000000000000000000000000000";

			web3.eth.sign(
				web3.utils.keccak256(web3.eth.abi.encodeParameters([
					"address",
					"address",
					"uint256",
					"bytes",
					"uint256",
					"uint256",
					"uint256",
					"address",
				],[
					metatx.from,
					metatx.to,
					metatx.value,
					metatx.data,
					metatx.nonce,
					metatx.gas,
					metatx.gasPrice,
					metatx.gasToken,
				])),
				signer
			).then(signature => {
				metatx.signature = signature;
				resolve(metatx);
			});
		});
	}

	it("meta tx", async () => {

		signer = accounthashs[0];

		tx = await signMetaTx({
			from:     IdentityInstance.address,
			to:       accounts[1],
			value:    web3.utils.toWei("1", "ether"),
		}, signer.addr);

		console.log(tx)

		txMined = await IdentityInstance.executeSigned(
			tx.to,
			tx.value,
			tx.data,
			tx.nonce,
			tx.gas,
			tx.gasPrice,
			tx.gasToken,
			tx.signature,
			{ from : accounts[5] }
		);

		console.log("balance id:", web3.utils.fromWei(await web3.eth.getBalance(IdentityInstance.address), "ether"));
		console.log("balance 0: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[0]),              "ether"));
		console.log("balance 1: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[1]),              "ether"));

	});

});
