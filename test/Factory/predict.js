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
