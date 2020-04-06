var ERC1538Proxy  = artifacts.require("./ERC1538ProxyV2");
var ERC1538Update = artifacts.require("./ERC1538UpdateV2Delegate");
var ERC1538Query  = artifacts.require("./ERC1538QueryDelegate");
var TestContract  = artifacts.require("./TestContract");

const { expectRevert } = require('@openzeppelin/test-helpers');

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
		.filter(entry => !entry.name.startsWith('coverage_0x')) // remove solidity coverage injected code
		.map(entry => entry.name + '(' + entry.inputs.map(getSerializedObject).join(',') + ')')
}

function extractEvents(txMined, address, name)
{
	return txMined.logs.filter((ev) => { return ev.address == address && ev.event == name; });
}

contract('ERC1538', async (accounts) => {

	before("configure", async () => {
		ERC1538UpdateInstance = await ERC1538Update.new();
		ERC1538QueryInstance  = await ERC1538Query.new();

		ProxyInterface        = await ERC1538Proxy.new(ERC1538UpdateInstance.address);
		UpdateInterface       = await ERC1538Update.at(ProxyInterface.address);
		QueryInterface        = await ERC1538Query.at(ProxyInterface.address);

		TestContractInstance  = await TestContract.new();

		for (delegate of [ ERC1538QueryInstance ])
		{
			await UpdateInterface.updateContract(
				delegate.address,
				getFunctionSignatures(delegate.abi),
				`Linking ${delegate.contractName}`
			);
		}

		SIGNATURES = {
			'updateContract(address,string[],string)': ERC1538UpdateInstance.address,
			'owner()':                                 ERC1538QueryInstance.address,
			'renounceOwnership()':                     ERC1538QueryInstance.address,
			'transferOwnership(address)':              ERC1538QueryInstance.address,
			'totalFunctions()':                        ERC1538QueryInstance.address,
			'functionByIndex(uint256)':                ERC1538QueryInstance.address,
			'functionById(bytes4)':                    ERC1538QueryInstance.address,
			'functionExists(string)':                  ERC1538QueryInstance.address,
			'delegateAddress(string)':                 ERC1538QueryInstance.address,
			'functionSignatures()':                    ERC1538QueryInstance.address,
			'delegateFunctionSignatures(address)':     ERC1538QueryInstance.address,
			'delegateAddresses()':                     ERC1538QueryInstance.address,
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

	it("ERC1538 - receive", async () => {
		tx = await UpdateInterface.updateContract(TestContractInstance.address, [ "receive" ], "adding receive delegate");

		evs = extractEvents(tx, UpdateInterface.address, "FunctionUpdate");
		assert.equal(evs.length, 1);
		assert.equal(evs[0].args.functionId,        "0x0000000000000000000000000000000000000000000000000000000000000000");
		assert.equal(evs[0].args.oldDelegate,       "0x0000000000000000000000000000000000000000");
		assert.equal(evs[0].args.newDelegate,       TestContractInstance.address);
		assert.equal(evs[0].args.functionSignature, "receive");

		evs = extractEvents(tx, UpdateInterface.address, "CommitMessage");
		assert.equal(evs.length, 1);
		assert.equal(evs[0].args.message, "adding receive delegate");

		tx = await web3.eth.sendTransaction({ from: accounts[0], to: UpdateInterface.address, value: 0, data: "0x", gasLimit: 500000 });
		assert.equal(tx.logs[0].topics[0], web3.utils.keccak256("Receive(uint256,bytes)"));
	});

	it("ERC1538 - fallback", async () => {
		tx = await UpdateInterface.updateContract(TestContractInstance.address, [ "fallback" ], "adding fallback delegate");

		evs = extractEvents(tx, UpdateInterface.address, "FunctionUpdate");
		assert.equal(evs.length, 1);
		assert.equal(evs[0].args.functionId,        "0xffffffff00000000000000000000000000000000000000000000000000000000");
		assert.equal(evs[0].args.oldDelegate,       "0x0000000000000000000000000000000000000000");
		assert.equal(evs[0].args.newDelegate,       TestContractInstance.address);
		assert.equal(evs[0].args.functionSignature, "fallback");

		evs = extractEvents(tx, UpdateInterface.address, "CommitMessage");
		assert.equal(evs.length, 1);
		assert.equal(evs[0].args.message, "adding fallback delegate");

		tx = await web3.eth.sendTransaction({ from: accounts[0], to: UpdateInterface.address, value: 0, data: "0xc0ffee", gasLimit: 500000 });
		assert.equal(tx.logs[0].topics[0], web3.utils.keccak256("Fallback(uint256,bytes)"));
	});

	it("ERC1538 - no update", async () => {
		tx = await UpdateInterface.updateContract(TestContractInstance.address, [ "fallback" ], "no changes");

		evs = extractEvents(tx, UpdateInterface.address, "FunctionUpdate");
		assert.equal(evs.length, 0);

		evs = extractEvents(tx, UpdateInterface.address, "CommitMessage");
		assert.equal(evs.length, 1);
		assert.equal(evs[0].args.message, "no changes");
	});

	it("ERC1538 - remove fallback", async () => {
		tx = await UpdateInterface.updateContract("0x0000000000000000000000000000000000000000", [ "fallback" ], "removing");

		evs = extractEvents(tx, UpdateInterface.address, "FunctionUpdate");
		assert.equal(evs.length, 1);
		assert.equal(evs[0].args.oldDelegate,       TestContractInstance.address);
		assert.equal(evs[0].args.newDelegate,       "0x0000000000000000000000000000000000000000");
		assert.equal(evs[0].args.functionSignature, "fallback");

		evs = extractEvents(tx, UpdateInterface.address, "CommitMessage");
		assert.equal(evs.length, 1);
		assert.equal(evs[0].args.message, "removing");
	});
});
