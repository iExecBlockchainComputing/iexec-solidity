module.exports =
{
	plugins: [ "solidity-coverage" ],
	networks:
	{
		development:
		{
			host:       "localhost",
			port:       8545,
			network_id: "*",         // Match any network id,
			gasPrice:   22000000000, //22Gwei
		},
		coverage:
		{
			host:       "localhost",
			port:       8555,          // <-- If you change this, also set the port option in .solcover.js.
			network_id: "*",
			gas:        0xFFFFFFFFFFF, // <-- Use this high gas value
			gasPrice:   0x01           // <-- Use this low gas price
		}
	},
	compilers: {
		solc: {
			version: "0.6.4",
			settings: {
				optimizer: {
					enabled: true,
					runs: 200
				}
			}
		}
	},
	mocha:
	{
		enableTimeouts: false
	}
};
