var GenericFactory = artifacts.require("GenericFactory");
var TestContract   = artifacts.require("TestContract");

const { expectRevert } = require('@openzeppelin/test-helpers');

function extractEvents(txMined, address, name)
{
	return txMined.logs.filter((ev) => { return ev.address == address && ev.event == name; });
}

contract('GenericFactory', async (accounts) => {

	before("configure", async () => {
		GenericFactoryInstance = await GenericFactory.new();
	});

	describe("createContract", async () => {

		code = new web3.eth.Contract(TestContract.abi).deploy({
			data: TestContract.bytecode,
			arguments: []
		}).encodeABI();

		it("select random salt", async () => {
			salt = web3.utils.randomHex(32);
		});

		it("predict address", async () => {
			predictedAddress = web3.utils.toChecksumAddress(web3.utils.soliditySha3(
				{ t: 'bytes1',  v: '0xff'                         },
				{ t: 'address', v: GenericFactoryInstance.address },
				{ t: 'bytes32', v: salt                           },
				{ t: 'bytes32', v: web3.utils.keccak256(code)     },
			).slice(26));
			assert.equal(await GenericFactoryInstance.predictAddress(code, salt), predictedAddress);
		});

		it("success (first)", async () => {
			txMined = await GenericFactoryInstance.createContract(code, salt);
			events = extractEvents(txMined, GenericFactoryInstance.address, "NewContract");
			assert.equal(events[0].args.addr, predictedAddress);
		});

		it("failure (duplicate)", async () => {
			await expectRevert.unspecified(GenericFactoryInstance.createContract(code, salt));
		});

		it("post check", async () => {
			TestInstance = await TestContract.at(predictedAddress);
			assert.equal(await TestInstance.id(),     "TestContract");
			assert.equal(await TestInstance.caller(), "0x0000000000000000000000000000000000000000");
			assert.equal(await TestInstance.value(),  null);
		});

	});

	describe("createContractAndCallback", async () => {

		code = new web3.eth.Contract(TestContract.abi).deploy({
			data: TestContract.bytecode,
			arguments: []
		}).encodeABI();

		it("select random salt and value", async () => {
			salt     = web3.utils.randomHex(32);
			value    = web3.utils.randomHex(64);
			callback = web3.eth.abi.encodeFunctionCall({ name: 'set', type: 'function', inputs: [{ type: 'bytes', name: '_value' }] }, [ value ]);
		});

		it("predict address", async () => {
			predictedAddress = web3.utils.toChecksumAddress(web3.utils.soliditySha3(
				{ t: 'bytes1',  v: '0xff'                         },
				{ t: 'address', v: GenericFactoryInstance.address },
				{ t: 'bytes32', v: salt                           },
				{ t: 'bytes32', v: web3.utils.keccak256(code)     },
			).slice(26));
			assert.equal(await GenericFactoryInstance.predictAddress(code, salt), predictedAddress);
		});

		it("success (first)", async () => {
			txMined = await GenericFactoryInstance.createContractAndCallback(code, salt, callback);
			events = extractEvents(txMined, GenericFactoryInstance.address, "NewContract");
			assert.equal(events[0].args.addr, predictedAddress);
		});

		it("failure (duplicate - with callback)", async () => {
			await expectRevert.unspecified(GenericFactoryInstance.createContractAndCallback(code, salt, callback));
		});

		it("failure (duplicate - without callback)", async () => {
			await expectRevert.unspecified(GenericFactoryInstance.createContract(code, salt));
		});

		it("post check", async () => {
			TestInstance = await TestContract.at(predictedAddress);
			assert.equal(await TestInstance.id(),     "TestContract");
			assert.equal(await TestInstance.caller(), GenericFactoryInstance.address);
			assert.equal(await TestInstance.value(),  value);
		});

	});



});
