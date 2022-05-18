pragma solidity ^0.8.11;

import "../interfaces/IERC721Metadata.sol";

import "./ERC165.sol";

/*
 *     ,_,
 *    (',')
 *    {/"\}
 *    -"-"-
 */

interface IERC721Receiver {
	/**
	 * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
	 * by `operator` from `from`, this function is called.
	 *
	 * It must return its Solidity selector to confirm the token transfer.
	 * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
	 *
	 * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
	 */
	function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
	external returns (bytes4);
}

contract ERC721_Barebone is IERC721Metadata, ERC165 {


	uint256 constant _totalSupply = 10000;
	uint256 public constant PRICE = 1000000000;

	bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
	bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
	bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

	// Token name
	string private _name;
	// Token symbol
	string private _symbol;

	// ownerOf => 0
	// approvals => 2
	// op approvals => 3

	constructor (string memory name_, string memory symbol_) {
		_name = name_;
		_symbol = symbol_;

		// register the supported interfaces to conform to ERC721 via ERC165
		_registerInterface(_INTERFACE_ID_ERC721);
		_registerInterface(_INTERFACE_ID_ERC721_METADATA);
	}


	////////////////////////////////////////////////////
	//////              Read Access               //////
	////////////////////////////////////////////////////
	function name() public view virtual override returns (string memory) {
		return _name;
	}

	function symbol() public view virtual override returns (string memory) {
		return _symbol;
	}

	function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
		return
			_interfaceId == type(IERC721).interfaceId ||
			_interfaceId == type(IERC721Metadata).interfaceId ||
			super.supportsInterface(_interfaceId);
	}

	function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
		require(ownerOf(_tokenId) != address(0), "ERC721: approved query for nonexistent token");

		string memory baseURI = _baseURI();
		return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, toString(_tokenId))) : "";
	}

	function ownerOf(uint256 _tokenId) public override view returns(address owner) {
		assembly{
			mstore(128, _tokenId)
			mstore(160, 0)
			owner := sload(keccak256(128, 0x40))
		}
	}

	function balanceOf(address _owner) public override view returns(uint256 balance_) {
		address owner;
		for (uint256 i = 0; i < _totalSupply; i++) {
			assembly{
				mstore(128, i)
				mstore(160, 0)
				owner := sload(keccak256(128, 0x40))
			}
			balance_ += owner == _owner ? 1 : 0;
		}
	}

	function totalSupply() public pure returns(uint256) {
		return _totalSupply - 1;
	}

	function isApprovedForAll(address _owner, address _operator) public view virtual override returns (bool ret) {
		assembly {
			mstore(128, _owner)
			mstore(160, _operator)
			mstore(192, 3)
			ret := sload(keccak256(128, 0x60))
		}
	}

	function getApproved(uint256 _tokenId) public view virtual override returns (address approved) {
		require(ownerOf(_tokenId) != address(0), "ERC721: approved query for nonexistent token");

		assembly{
			mstore(128, _tokenId)
			mstore(160, 2)
			approved := sload(keccak256(128, 0x40))
		}
	}


	////////////////////////////////////////////////////
	//////              Write Access              //////
	////////////////////////////////////////////////////
	function setApprovalForAll(address operator, bool approved) public virtual override {
		_setApprovalForAll(msg.sender, operator, approved);
	}

	function approve(address _to, uint256 _tokenId) public virtual override {
		address owner = ownerOf(_tokenId);
		require(_to != owner, "ERC721: approval to current owner");

		require(
			msg.sender == owner || isApprovedForAll(owner, msg.sender),
			"ERC721: approve caller is not owner nor approved for all"
		);
		_approve(_to, _tokenId);
	}

	function transferFrom(address _from, address _to, uint256 _tokenId) external {
		require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
		_transfer(_from, _to, _tokenId);
	}

	function batchTransferFrom(address _from, address _to, uint256[] calldata _tokenIds) external {
		_batchTransfer( _from, _to, _tokenIds);
	}

	function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public virtual override {
		require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
		_safeTransfer(_from, _to, _tokenId, _data);
	}

	function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
		safeTransferFrom(from, to, tokenId, "");
	}

	function mint(address _to, uint256 _tokenId) external {
		_mint(_to, _tokenId);
	}

	function mint_Aci() external payable {
		uint256 nextToken;
		assembly{
			mstore(320, 4)
			nextToken := add(sload(keccak256(320, 0x20)), 1)
		}
		require(nextToken < _totalSupply + 1, "max");
		require(msg.value == PRICE, "wrong price");
		require(msg.sender == tx.origin, "only EOA");
		emit Transfer(address(0), msg.sender, nextToken);
		address receiver = msg.sender;
		assembly {
			mstore(128, nextToken)
			mstore(160, 0)
			sstore(keccak256(128, 0x40), receiver)
			mstore(320, 4)
			sstore(keccak256(320, 0x20), nextToken)
		}
	}

	function mint_540(uint256 _id) external payable {
		require(_id < _totalSupply + 1, "max");
		require(msg.value == PRICE, "wrong price");
		require(msg.sender == tx.origin, "only EOA");
		emit Transfer(address(0), msg.sender, _id);
		address receiver = msg.sender;
		assembly {
			mstore(128, _id)
			mstore(160, 0)
			sstore(keccak256(128, 0x40), receiver)
		}
	}

	function mintBatch(address _to, uint256[] calldata _tokenIds) external {
		_mintBatch(_to, _tokenIds);
	}

	////////////////////////////////////////////////////
	//////               Helpers                  //////
	////////////////////////////////////////////////////
	function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
		address owner = ownerOf(_tokenId);
		return (_spender == owner || isApprovedForAll(owner, _spender) || getApproved(_tokenId) == _spender);
	}

	function _transfer(address _from, address _to, uint256 _tokenId) internal {
		require(ownerOf(_tokenId) == _from, "not owner of");
		require(_to != address(0), "Cannot send to burn");

		_approve(address(0), _tokenId);
		assembly {
			mstore(256, _tokenId)
			mstore(288, 0)
			sstore(keccak256(256, 0x40), _to) // ownerOf
		}
		emit Transfer(_from, _to, _tokenId);
	}

	function _batchTransfer(address _from, address _to, uint256[] calldata _tokenIds) internal {
		require(_to != address(0), "Cannot send to burn");

		uint256 len = _tokenIds.length;
		for (uint256 i = 0; i < len; i++) {
			require(_isApprovedOrOwner(msg.sender, _tokenIds[i]), "ERC721: transfer caller is not owner nor approved");

			_approve(address(0), _tokenIds[i]);
			uint256 id = _tokenIds[i];
			assembly {
				mstore(256, id)
				mstore(288, 0)
				sstore(keccak256(256, 0x40), _to) // ownerOf
			}
			emit Transfer(_from, _to, _tokenIds[i]);
		}
	}

	function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
		_transfer(from, to, tokenId);
		require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
	}

	function _mint(address _to, uint256 _tokenId) internal {
		// require(_to != address(0), "ERC721: mint to the zero address");
		// require(ownerOf(_tokenId) == address(0), "ERC721: token already minted");

		assembly {
			mstore(128, _tokenId)
			mstore(160, 0)
			sstore(keccak256(128, 0x40), _to)
		}

		emit Transfer(address(0), _to, _tokenId);
	}

	function _mintBatch(address _to, uint256[] calldata _tokenIds) internal {
		// require(_to != address(0), "ERC721: mint to the zero address");

		uint256 len = _tokenIds.length;
		for (uint256 i = 0; i < len; i++) {
			// require(ownerOf(_tokenIds[i]) == address(0), "ERC721: token already minted");

			uint256 id = _tokenIds[i];
			assembly {
				mstore(320, id)
				mstore(352, 0)
				sstore(keccak256(320, 0x40), _to)
			}

			emit Transfer(address(0), _to, _tokenIds[i]);
		}
	}

	function isContract(address account) internal view returns (bool) {
		uint256 size;
		// solhint-disable-next-line no-inline-assembly
		assembly { size := extcodesize(account) }
		return size > 0;
	}

	function _checkOnERC721Received(
		address from,
		address to,
		uint256 tokenId,
		bytes memory _data
	) private returns (bool) {
		if (isContract(to)) {
			try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
				return retval == IERC721Receiver.onERC721Received.selector;
			} catch (bytes memory reason) {
				if (reason.length == 0) {
					revert("ERC721: transfer to non ERC721Receiver implementer");
				} else {
					assembly {
						revert(add(32, reason), mload(reason))
					}
				}
			}
		} else {
			return true;
		}
	}

	function _approve(address _to, uint256 _tokenId) private {
		assembly {
			mstore(320, _tokenId)
			mstore(352, 2)
			sstore(keccak256(320, 0x40), _to)
		}
		emit Approval(ownerOf(_tokenId), _to, _tokenId);
	}

	function _setApprovalForAll(
		address _owner,
		address _operator,
		bool _approved
	) internal virtual {
		require(_owner != _operator, "ERC721: approve to caller");
		assembly {
			mstore(128, _owner)
			mstore(160, _operator)
			mstore(192, 3)
			sstore(keccak256(128, 0x60), _approved)
		}
		emit ApprovalForAll(_owner, _operator, _approved);
	}

	function toString(uint256 value) internal pure returns (string memory) {
		// Inspired by OraclizeAPI's implementation - MIT licence
		// https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

		if (value == 0) {
			return "0";
		}
		uint256 temp = value;
		uint256 digits;
		while (temp != 0) {
			digits++;
			temp /= 10;
		}
		bytes memory buffer = new bytes(digits);
		uint256 index = digits - 1;
		temp = value;
		while (temp != 0) {
			buffer[index--] = bytes1(uint8(48 + temp % 10));
			temp /= 10;
		}
		return string(buffer);
	}

	function _baseURI() internal view virtual returns (string memory) {
		return "";
	}
}