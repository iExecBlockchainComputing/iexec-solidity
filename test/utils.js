module.exports = {
	addressToBytes32: (address) => web3.utils.keccak256(address),
}
