var GenericFactoryRestricted = artifacts.require("GenericFactoryRestricted");
var GenericFactoryController = artifacts.require("GenericFactoryController");
var TestContract             = artifacts.require("TestContract");

const { expectRevert } = require('@openzeppelin/test-helpers');
const { predict } = require('./predict.js');

const LIMIT = 3;

function extractEvents(txMined, address, name)
{
	return txMined.logs.filter((ev) => { return ev.address == address && ev.event == name; });
}

contract('GenericFactoryRestricted', async (accounts) => {

	before("configure", async () => {
		GenericFactoryRestrictedInstance = await GenericFactoryRestricted.new(accounts[0]);
		GenericFactoryControllerInstance = await GenericFactoryController.new(GenericFactoryRestrictedInstance.address);
		GenericFactoryRestrictedInstance.addWhitelisted(GenericFactoryControllerInstance.address);
	});

	it("setup check", async () => {
		assert.equal(await GenericFactoryControllerInstance.factory(), GenericFactoryRestrictedInstance.address);
	});

		code = new web3.eth.Contract(TestContract.abi).deploy({
		data: TestContract.bytecode,
		arguments: []
	}).encodeABI();

	describe("unauthorized account", async () => {
		it("failure", async () => {
			assert.equal(await GenericFactoryControllerInstance.dailyLimit(accounts[1]), 0);
			await expectRevert(GenericFactoryControllerInstance.createContract(code, web3.utils.randomHex(32), { from: accounts[1] }), "daily-limit-exceeded");
		});
	});

	describe("testing limit", async () => {

		it("increase limit", async () => {
			await GenericFactoryControllerInstance.setDailyLimit(accounts[1], LIMIT);
		});

		Array(2 * LIMIT).fill().map((_, i) => {
			it(`deployment #${i} (day + 0)`, async () => {
				const promise = GenericFactoryControllerInstance.createContract(code, web3.utils.randomHex(32), { from: accounts[1] });
				if (i < LIMIT)
				{
					await promise;
				}
				else
				{
					await expectRevert(promise, "daily-limit-exceeded");
				}
				assert.equal(await GenericFactoryControllerInstance.lastUseCount(accounts[1]), Math.min(i+1, LIMIT));
				assert.equal(await GenericFactoryControllerInstance.lastUse(accounts[1]),      Math.floor(Date.now() / 86400000) + 0);
			});
		});

		it("waiting one day", async () => {
			await web3.currentProvider.send({ jsonrpc: "2.0", method: "evm_increaseTime", params: [ 86400 ], id: 0 }, () => {});
		});

		Array(2 * LIMIT).fill().map((_, i) => {
			it(`deployment #${i} (day + 1)`, async () => {
				const promise = GenericFactoryControllerInstance.createContract(code, web3.utils.randomHex(32), { from: accounts[1] });
				if (i < LIMIT)
				{
					await promise;
				}
				else
				{
					await expectRevert(promise, "daily-limit-exceeded");
				}
				assert.equal(await GenericFactoryControllerInstance.lastUseCount(accounts[1]), Math.min(i+1, LIMIT));
				assert.equal(await GenericFactoryControllerInstance.lastUse(accounts[1]),      Math.floor(Date.now() / 86400000) + 1);
			});
		});
	});
});
