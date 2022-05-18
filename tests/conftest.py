import pytest
import csv
from brownie import compile_source

@pytest.fixture(scope="module")
def minter_(accounts):
    return accounts[0]

@pytest.fixture(scope="module")
def nft_1(ERC721_Slim, minter_):
    return ERC721_Slim.deploy("","",{'from':minter_})

@pytest.fixture(scope="module")
def nft(ERC721_Barebone, minter_):
    return ERC721_Barebone.deploy("","",{'from':minter_})

@pytest.fixture(scope="module")
def stress_nft(OZ_721, minter_):
    return OZ_721.deploy({'from':minter_})


@pytest.fixture(scope="module")
def erc721(ERC721, minter_):
    return ERC721.deploy("","",{'from':minter_})

@pytest.fixture(scope="module")
def receiver_invalid(Invalid, accounts):
	return Invalid.deploy({'from': accounts[0]})

@pytest.fixture(scope="module")
def receiver_invalid_return(InvalidReturn, accounts):
    return InvalidReturn.deploy({'from': accounts[0]})

@pytest.fixture(scope="module")
def receiver_valid(Valid, accounts):
    return Valid.deploy({'from': accounts[0]})

@pytest.fixture(scope="module")
def zero_addr():
    return "0x0000000000000000000000000000000000000000"