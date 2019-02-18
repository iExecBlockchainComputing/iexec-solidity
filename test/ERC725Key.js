var Identity = artifacts.require("./Identity.sol");

const { shouldFail } = require('openzeppelin-test-helpers');

function extractEvents(txMined, address, name)
{
	return txMined.logs.filter((ev) => { return ev.address == address && ev.event == name });
}

contract('Identity: ERC725Key', async (accounts) => {

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

	it("Base", async () => {
		for (id in accounthashs)
		{
			assert.equal(await IdentityInstance.addrToKey(accounthashs[id].addr), accounthashs[id].key);
		}
	});

	it("Accessors", async () => {
		assert.equal(await IdentityInstance.numKeys(), 1);

		entry = await IdentityInstance.getKey(accounthashs[0].key);
		assert.deepEqual(entry.purposes.map(e => Number(e)), [ 1 ]              );
		assert.equal    (entry.keyType,                      1                  );
		assert.equal    (entry.key,                          accounthashs[0].key);

		entry = await IdentityInstance.getKey(accounthashs[1].key);
		assert.deepEqual(entry.purposes.map(e => Number(e)), []              );
		assert.equal    (entry.keyType,                      0               );
		assert.equal    (entry.key,                          0               );

		assert.isTrue (await IdentityInstance.keyHasPurpose(accounthashs[0].key, 1));
		assert.isFalse(await IdentityInstance.keyHasPurpose(accounthashs[0].key, 2));
		assert.isFalse(await IdentityInstance.keyHasPurpose(accounthashs[0].key, 3));
		assert.isFalse(await IdentityInstance.keyHasPurpose(accounthashs[0].key, 4));

		assert.deepEqual(await IdentityInstance.getKeysByPurpose(1), [ accounthashs[0].key ]);
		assert.deepEqual(await IdentityInstance.getKeysByPurpose(2), []                     );
		assert.deepEqual(await IdentityInstance.getKeysByPurpose(3), []                     );
		assert.deepEqual(await IdentityInstance.getKeysByPurpose(4), []                     );
	});

	it("Management #1", async () => {
		txsMined = await Promise.all([
			IdentityInstance.addKey(accounthashs[0].key, 2, 1, { from: accounthashs[0].addr }),
			IdentityInstance.addKey(accounthashs[0].key, 3, 1, { from: accounthashs[0].addr }),
			IdentityInstance.addKey(accounthashs[0].key, 4, 1, { from: accounthashs[0].addr }),
		]);

		events = extractEvents(txsMined[0], IdentityInstance.address, "KeyAdded");
		assert.equal(events[0].args.key,     accounthashs[0].key);
		assert.equal(events[0].args.purpose, 2                  );
		assert.equal(events[0].args.keyType, 1                  );

		events = extractEvents(txsMined[1], IdentityInstance.address, "KeyAdded");
		assert.equal(events[0].args.key,     accounthashs[0].key);
		assert.equal(events[0].args.purpose, 3                  );
		assert.equal(events[0].args.keyType, 1                  );

		events = extractEvents(txsMined[2], IdentityInstance.address, "KeyAdded");
		assert.equal(events[0].args.key,     accounthashs[0].key);
		assert.equal(events[0].args.purpose, 4                  );
		assert.equal(events[0].args.keyType, 1                  );
	});

	it("Accessors", async () => {
		assert.equal(await IdentityInstance.numKeys(), 4);

		entry = await IdentityInstance.getKey(accounthashs[0].key);
		assert.deepEqual(entry.purposes.map(e => Number(e)), [ 1, 2, 3, 4 ]     );
		assert.equal    (entry.keyType,                      1                  );
		assert.equal    (entry.key,                          accounthashs[0].key);

		entry = await IdentityInstance.getKey(accounthashs[1].key);
		assert.deepEqual(entry.purposes.map(e => Number(e)), []);
		assert.equal    (entry.keyType,                      0 );
		assert.equal    (entry.key,                          0 );

		assert.isTrue(await IdentityInstance.keyHasPurpose(accounthashs[0].key, 1));
		assert.isTrue(await IdentityInstance.keyHasPurpose(accounthashs[0].key, 2));
		assert.isTrue(await IdentityInstance.keyHasPurpose(accounthashs[0].key, 3));
		assert.isTrue(await IdentityInstance.keyHasPurpose(accounthashs[0].key, 4));

		assert.deepEqual(await IdentityInstance.getKeysByPurpose(1), [ accounthashs[0].key ]);
		assert.deepEqual(await IdentityInstance.getKeysByPurpose(2), [ accounthashs[0].key ]);
		assert.deepEqual(await IdentityInstance.getKeysByPurpose(3), [ accounthashs[0].key ]);
		assert.deepEqual(await IdentityInstance.getKeysByPurpose(4), [ accounthashs[0].key ]);
	});

	it("Management #2", async () => {
		await shouldFail.reverting(IdentityInstance.addKey(accounthashs[1].key, 1, 1, { from: accounthashs[1].addr }));
		await shouldFail.reverting(IdentityInstance.addKey(accounthashs[1].key, 2, 1, { from: accounthashs[1].addr }));
		await shouldFail.reverting(IdentityInstance.addKey(accounthashs[1].key, 3, 1, { from: accounthashs[1].addr }));
		await shouldFail.reverting(IdentityInstance.addKey(accounthashs[1].key, 4, 1, { from: accounthashs[1].addr }));
	});

});
