function prepareSalt(salt, call="")
{
	return web3.utils.soliditySha3(
		{ t: 'bytes32', v: salt   },
		{ t: 'bytes',   v: call   },
	);
}
function create2(address, code, salt)
{
	return web3.utils.toChecksumAddress(web3.utils.soliditySha3(
		{ t: 'bytes1',  v: '0xff'                     },
		{ t: 'address', v: address                    },
		{ t: 'bytes32', v: salt                       },
		{ t: 'bytes32', v: web3.utils.keccak256(code) },
	).slice(26));
}
function predict(address, code, salt, call="")
{
	return create2(address, code, prepareSalt(salt, call));
}

module.exports = {
	predict,
}
