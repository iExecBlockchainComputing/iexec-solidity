var ERC1538Proxy  = artifacts.require("./ERC1538Proxy");
var ERC1538Update = artifacts.require("./ERC1538UpdateDelegate");
var ERC1538Query  = artifacts.require("./ERC1538QueryDelegate");
var TestContract  = artifacts.require("./TestContract");

const { expectRevert } = require('openzeppelin-test-helpers');

function getSerializedObject(entry)
{
	if (entry.type == 'tuple')
	{
		return '(' + entry.components.map(getSerializedObject).join(',') + ')'
	}
	else
	{
		return entry.type;
	}
}

function getFunctionSignatures(abi)
{
	return abi
		.filter(entry => entry.type == 'function')
		.map(entry => entry.name + '(' + entry.inputs.map(getSerializedObject).join(',') + ');')
		.join('')
}

function extractEvents(txMined, address, name)
{
	return txMined.logs.filter((ev) => { return ev.address == address && ev.event == name; });
}

contract('ERC1538', async (accounts) => {

	before("configure", async () => {
		ERC1538UpdateInstance = await ERC1538Update.new();
		ERC1538QueryInstance  = await ERC1538Query.new();

		ProxyInterface  = await ERC1538Proxy.new(ERC1538UpdateInstance.address);
		UpdateInterface = await ERC1538Update.at(ProxyInterface.address);
		QueryInterface  = await ERC1538Query.at(ProxyInterface.address);

		for (delegate of [ ERC1538QueryInstance ])
		{
			await UpdateInterface.updateContract(
				delegate.address,
				getFunctionSignatures(delegate.abi),
				`Linking ${delegate.contractName}`
			);
		}

		SIGNATURES = {
			'updateContract(address,string,string)': ERC1538UpdateInstance.address,
			'renounceOwnership()':                   ERC1538QueryInstance.address,
			'owner()':                               ERC1538QueryInstance.address,
			'isOwner()':                             ERC1538QueryInstance.address,
			'transferOwnership(address)':            ERC1538QueryInstance.address,
			'totalFunctions()':                      ERC1538QueryInstance.address,
			'functionByIndex(uint256)':              ERC1538QueryInstance.address,
			'functionById(bytes4)':                  ERC1538QueryInstance.address,
			'functionExists(string)':                ERC1538QueryInstance.address,
			'delegateAddress(string)':               ERC1538QueryInstance.address,
			'functionSignatures()':                  ERC1538QueryInstance.address,
			'delegateFunctionSignatures(address)':   ERC1538QueryInstance.address,
			'delegateAddresses()':                   ERC1538QueryInstance.address,
		}

	});

	it("Ownership", async () => {
		assert.equal(await ERC1538UpdateInstance.owner(), "0x0000000000000000000000000000000000000000");
		assert.equal(await ERC1538QueryInstance.owner(),  "0x0000000000000000000000000000000000000000");
		assert.equal(await ProxyInterface.owner(),        accounts[0]);
		assert.equal(await UpdateInterface.owner(),       accounts[0]);
		assert.equal(await QueryInterface.owner(),        accounts[0]);
	});

	it("ERC1538Query - totalFunctions", async () => {
		assert.equal(await QueryInterface.totalFunctions(), Object.keys(SIGNATURES).length);
	});

	it("ERC1538Query - functionByIndex", async () => {
		for (const i in Object.keys(SIGNATURES))
		{
			const [ signature, delegate ] = Object.entries(SIGNATURES)[i];
			const id                      = web3.utils.soliditySha3({t: 'string', v: signature}).substr(0, 10)

			const result                  = await QueryInterface.functionByIndex(i);
			assert.equal(result.signature, signature);
			assert.equal(result.id,        id);
			assert.equal(result.delegate,  delegate);
		}
	});

	it("ERC1538Query - functionById", async () => {
		for (const i in Object.keys(SIGNATURES))
		{
			const [ signature, delegate ] = Object.entries(SIGNATURES)[i];
			const id                      = web3.utils.soliditySha3({t: 'string', v: signature}).substr(0, 10)

			const result                  = await QueryInterface.functionById(id);
			assert.equal(result.signature, signature);
			assert.equal(result.id,        id);
			assert.equal(result.delegate,  delegate);
		}
	});

	it("ERC1538Query - functionExists", async () => {
		for (const signature of Object.keys(SIGNATURES))
		{
			assert.isTrue(await QueryInterface.functionExists(signature));
		}
	});

	it("ERC1538Query - functionSignatures", async () => {
		assert.equal(
			await QueryInterface.functionSignatures(),
			[
				...Object.keys(SIGNATURES),
				''
			].join(';')
		);
	});

	it("ERC1538Query - delegateFunctionSignatures", async () => {
		for (delegate of await QueryInterface.delegateAddresses())
		{
			assert.equal(
				await QueryInterface.delegateFunctionSignatures(delegate),
				[
					...Object.entries(SIGNATURES).filter(([s, d]) => d == delegate).map(([s,d]) => s),
					''
				].join(';')
			);
		}
	});

	it("ERC1538Query - delegateAddress", async () => {
		for (const [ signature, delegate ] of Object.entries(SIGNATURES))
		{
			assert.equal(
				await QueryInterface.delegateAddress(signature),
				delegate
			);
		}
	});

	it("ERC1538Query - delegateAddresses", async () => {
		assert.deepEqual(
			(await QueryInterface.delegateAddresses()),
			Object.values(SIGNATURES).filter((v, i, a) => a.indexOf(v) === i)
		);
	});

	it("ERC1538 - fallback", async () => {
		TestContractInstance  = await TestContract.new();
		await UpdateInterface.updateContract(TestContractInstance.address, "fallback;", "adding fallback delegate");
		await expectRevert(web3.eth.sendTransaction({ from: accounts[0], to: TestContractInstance.address, value: 0, gasLimit: 500000 }), "fallback should revert");
	});

});
