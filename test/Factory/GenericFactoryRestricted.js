var GenericFactoryRestricted = artifacts.require("GenericFactoryRestricted");
var TestContract             = artifacts.require("TestContract");

const { expectRevert } = require('@openzeppelin/test-helpers');

function extractEvents(txMined, address, name)
{
	return txMined.logs.filter((ev) => { return ev.address == address && ev.event == name; });
}

contract('GenericFactoryRestricted', async (accounts) => {

	before("configure", async () => {
		GenericFactoryRestrictedInstance = await GenericFactoryRestricted.new(accounts[0]);
	});

	describe("restriction applies", async () => {

		code = new web3.eth.Contract(TestContract.abi).deploy({
			data: TestContract.bytecode,
			arguments: []
		}).encodeABI();

		it("select random salt", async () => {
			salt = web3.utils.randomHex(32);
		});

		it("predict address", async () => {
			predictedAddress = web3.utils.toChecksumAddress(web3.utils.soliditySha3(
				{ t: 'bytes1',  v: '0xff'                                   },
				{ t: 'address', v: GenericFactoryRestrictedInstance.address },
				{ t: 'bytes32', v: salt                                     },
				{ t: 'bytes32', v: web3.utils.keccak256(code)               },
			).slice(26));
			assert.equal(await GenericFactoryRestrictedInstance.predictAddress(code, salt), predictedAddress);
		});

		it("failure (not whitelist)", async () => {
			await expectRevert.unspecified(GenericFactoryRestrictedInstance.createContract(code, salt));
		});

		it("adding to whitelist", async () => {
			await GenericFactoryRestrictedInstance.addWhitelisted(accounts[0]);
		});

		it("success (whitelisted)", async () => {
			txMined = await GenericFactoryRestrictedInstance.createContract(code, salt);
			events = extractEvents(txMined, GenericFactoryRestrictedInstance.address, "NewContract");
			assert.equal(events[0].args.addr, predictedAddress);
		});

		it("post check", async () => {
			TestInstance = await TestContract.at(predictedAddress);
			assert.equal(await TestInstance.id(),     "TestContract");
			assert.equal(await TestInstance.caller(), "0x0000000000000000000000000000000000000000");
			assert.equal(await TestInstance.value(),  null);
		});

	});

});
