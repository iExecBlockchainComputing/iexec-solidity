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

	// it("Adding action capability", async () => {
	// });

});
