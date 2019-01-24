var Identity     = artifacts.require("./Identity.sol");
var TestContract = artifacts.require("./TestContract.sol");

const { shouldFail } = require('openzeppelin-test-helpers');
const   metaTX       = require("../utils/metaTX.js")

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

		txMined = await metaTX.sendMetaTX(
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


		await shouldFail.reverting(metaTX.sendMetaTX(
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

		await shouldFail.reverting(metaTX.sendMetaTX(
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

		txMined = await metaTX.sendMetaTX(
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

		txMined = await metaTX.sendMetaTX(
			IdentityInstance,
			{
				to:   target.address,
				data: metaTX.prepareData(target, "set", [ randbytes ]),
			},
			accounts[0],
			accounts[5],
		);

		assert.equal(await target.value(),  randbytes);
		assert.equal(await target.caller(), IdentityInstance.address);
	});

});
