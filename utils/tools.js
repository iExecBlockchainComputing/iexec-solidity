module.exports = {

	reverts : async function(fn)
	{
		try
		{
			await fn();
			assert.fail("transaction should have reverted");
		} catch (error) {
			assert(error, "Expected an error but did not get one");
			assert(
				error.message.includes("VM Exception while processing transaction: revert") || error.message.includes("VM Exception while processing transaction: invalid opcode"),
				`Got unexpected error message ${error.message}`
			);
		}
	},
}
