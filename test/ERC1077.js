var Identity     = artifacts.require("./Identity.sol");
var TestContract = artifacts.require("./TestContract.sol");

const { shouldFail } = require('openzeppelin-test-helpers');
const   tools        = require("../utils/tools.js")

function prepareData(target, method, args)
{
	return web3.eth.abi.encodeFunctionCall(target.abi.filter(e => e.type == "function" && e.name == method)[0], args);
}

function signMetaTX(identity, metatx, signer)
{
	return new Promise(async (resolve, reject) => {
		if (metatx.from     == undefined) metatx.from     = identity.address;
		if (metatx.value    == undefined) metatx.value    = 0;
		if (metatx.data     == undefined) metatx.data     = [];
		if (metatx.nonce    == undefined) metatx.nonce    = Number(await identity.keyNonce(web3.utils.keccak256(signer)));
		if (metatx.gas      == undefined) metatx.gas      = 0;
		if (metatx.gasPrice == undefined) metatx.gasPrice = 0;
		if (metatx.gasToken == undefined) metatx.gasToken = "0x0000000000000000000000000000000000000000";

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
		)
		.then(signature => { metatx.signature = signature; resolve(metatx); })
		.catch(reject);
	});
}

function sendMetaTX(identity, metatx, signer, relay)
{
	return new Promise(async (resolve, reject) => {
		signMetaTX(identity, metatx, signer).then((signedmetatx) => {
			identity.executeSigned(
				signedmetatx.to,
				signedmetatx.value,
				signedmetatx.data,
				signedmetatx.nonce,
				signedmetatx.gas,
				signedmetatx.gasPrice,
				signedmetatx.gasToken,
				signedmetatx.signature,
				{ from : relay }
			)
			.then(resolve)
			.catch(reject);
		})
	});
}

function extractEvents(txMined, address, name)
{
	return txMined.logs.filter((ev) => { return ev.address == address && ev.event == name; });
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
		IdentityInstance = await Identity.new(accounthashs[0].key);
	});

	it("Adding action capability", async () => {
		await IdentityInstance.addKey(accounthashs[0].key, 2, 1, { from: accounthashs[0].addr });
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

	it("meta tx #1", async () => {
		assert.equal(await IdentityInstance.keyNonce(accounthashs[0].key), 0);
		assert.equal(await web3.eth.getBalance(IdentityInstance.address), web3.utils.toWei("1", "ether"));

		txMined = await sendMetaTX(
			IdentityInstance,
			{
				to:     accounts[1],
				value:  web3.utils.toWei(".1", "ether"),
			},
			accounts[0],
			accounts[5],
		);

		events = extractEvents(txMined, IdentityInstance.address, "ExecutionRequested");
		// assert.equal(events[0].args.executionId);
		assert.equal(events[0].args.to,    accounts[1]);
		assert.equal(events[0].args.value, web3.utils.toWei(".1", "ether"));
		assert.equal(events[0].args.data,  null);

		events = extractEvents(txMined, IdentityInstance.address, "Executed");
		// assert.equal(events[0].args.executionId);
		assert.equal(events[0].args.to,    accounts[1]);
		assert.equal(events[0].args.value, web3.utils.toWei(".1", "ether"));
		assert.equal(events[0].args.data,  null);

		assert.equal(await IdentityInstance.keyNonce(accounthashs[0].key), 1);
		assert.equal(await web3.eth.getBalance(IdentityInstance.address), web3.utils.toWei(".9", "ether"));
	});

	it("meta tx #2 - wrong nonce", async () => {
		assert.equal(await IdentityInstance.keyNonce(accounthashs[0].key), 1);
		assert.equal(await web3.eth.getBalance(IdentityInstance.address), web3.utils.toWei(".9", "ether"));


		await shouldFail.reverting(sendMetaTX(
			IdentityInstance,
			{
				to:     accounts[1],
				value:  web3.utils.toWei(".1", "ether"),
				nonce:    0, // wrong, should be 1
			},
			accounts[0],
			accounts[5],
		));

		assert.equal(await IdentityInstance.keyNonce(accounthashs[0].key), 1);
		assert.equal(await web3.eth.getBalance(IdentityInstance.address), web3.utils.toWei(".9", "ether"));
	});

	it("meta tx #3 - unauthorized", async () => {
		assert.equal(await IdentityInstance.keyNonce(accounthashs[1].key), 0);
		assert.equal(await web3.eth.getBalance(IdentityInstance.address), web3.utils.toWei(".9", "ether"));

		await shouldFail.reverting(sendMetaTX(
			IdentityInstance,
			{
				to:     accounts[1],
				value:  web3.utils.toWei(".1", "ether"),
			},
			accounts[1],
			accounts[5],
		));

		assert.equal(await IdentityInstance.keyNonce(accounthashs[1].key), 0);
		assert.equal(await web3.eth.getBalance(IdentityInstance.address), web3.utils.toWei(".9", "ether"));
	});

	it("meta tx #4", async () => {
		assert.equal(await IdentityInstance.keyNonce(accounthashs[0].key), 1);
		assert.equal(await web3.eth.getBalance(IdentityInstance.address), web3.utils.toWei(".9", "ether"));

		txMined = await sendMetaTX(
			IdentityInstance,
			{
				to:     accounts[1],
				value:  web3.utils.toWei(".1", "ether"),
			},
			accounts[0],
			accounts[5],
		);

		events = extractEvents(txMined, IdentityInstance.address, "ExecutionRequested");
		// assert.equal(events[0].args.executionId);
		assert.equal(events[0].args.to,    accounts[1]);
		assert.equal(events[0].args.value, web3.utils.toWei(".1", "ether"));
		assert.equal(events[0].args.data,  null);

		events = extractEvents(txMined, IdentityInstance.address, "Executed");
		// assert.equal(events[0].args.executionId);
		assert.equal(events[0].args.to,    accounts[1]);
		assert.equal(events[0].args.value, web3.utils.toWei(".1", "ether"));
		assert.equal(events[0].args.data,  null);

		assert.equal(await IdentityInstance.keyNonce(accounthashs[0].key), 2);
		assert.equal(await web3.eth.getBalance(IdentityInstance.address), web3.utils.toWei(".8", "ether"));
	});

	it("balance after", async () => {
		console.log("balance id:", web3.utils.fromWei(await web3.eth.getBalance(IdentityInstance.address), "ether"));
		console.log("balance 0: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[0]),              "ether"));
		console.log("balance 1: ", web3.utils.fromWei(await web3.eth.getBalance(accounts[1]),              "ether"));
	});

	it("function call", async () => {

		let target    = await TestContract.new();
		let randbytes = web3.utils.randomHex(128);

		assert.equal(await target.value(),  null);
		assert.equal(await target.caller(), "0x0000000000000000000000000000000000000000");

		txMined = await sendMetaTX(
			IdentityInstance,
			{
				to:   target.address,
				data: prepareData(target, "set", [ randbytes ]),
			},
			accounts[0],
			accounts[5],
		);

		assert.equal(await target.value(),  randbytes);
		assert.equal(await target.caller(), IdentityInstance.address);
	});

});
