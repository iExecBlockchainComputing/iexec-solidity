/******************************************************************************
 * Copyright 2020 IEXEC BLOCKCHAIN TECH                                       *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

var GenericFactory = artifacts.require("GenericFactory");
var TestContract   = artifacts.require("TestContract");

const { expectRevert } = require('@openzeppelin/test-helpers');
const { predict } = require('./predict.js');

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
			predictedAddress = predict(GenericFactoryInstance.address, code, salt);
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

	describe("createContractAndCall", async () => {

		code = new web3.eth.Contract(TestContract.abi).deploy({
			data: TestContract.bytecode,
			arguments: []
		}).encodeABI();

		it("select random salt and value", async () => {
			salt  = web3.utils.randomHex(32);
			value = web3.utils.randomHex(64);
			call  = web3.eth.abi.encodeFunctionCall({ name: 'set', type: 'function', inputs: [{ type: 'bytes', name: '_value' }] }, [ value ]);
		});

		it("predict address", async () => {
			predictedAddress = predict(GenericFactoryInstance.address, code, salt, call);
			assert.equal(await GenericFactoryInstance.predictAddressWithCall(code, salt, call), predictedAddress);
		});

		it("success (first)", async () => {
			txMined = await GenericFactoryInstance.createContractAndCall(code, salt, call);
			events = extractEvents(txMined, GenericFactoryInstance.address, "NewContract");
			assert.equal(events[0].args.addr, predictedAddress);
		});

		it("failure (duplicate)", async () => {
			await expectRevert.unspecified(GenericFactoryInstance.createContractAndCall(code, salt, call));
		});

		it("post check", async () => {
			TestInstance = await TestContract.at(predictedAddress);
			assert.equal(await TestInstance.id(),     "TestContract");
			assert.equal(await TestInstance.caller(), GenericFactoryInstance.address);
			assert.equal(await TestInstance.value(),  value);
		});

	});
});
