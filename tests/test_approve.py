import brownie
import pytest

@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass


def test_approve(nft, accounts, zero_addr):
    nft.mint(accounts[2], 1337)

    assert nft.getApproved(1337) == zero_addr
    nft.approve(accounts[1], 1337, {'from': accounts[2]})
    assert nft.getApproved(1337) == accounts[1]


def test_change_approve(nft, accounts):
    nft.mint(accounts[2], 1337)

    nft.approve(accounts[1], 1337, {'from': accounts[2]})
    nft.approve(accounts[0], 1337, {'from': accounts[2]})
    assert nft.getApproved(1337) == accounts[0]


def test_revoke_approve(nft, accounts, zero_addr):
    nft.mint(accounts[2], 1337)

    nft.approve(accounts[1], 1337, {'from': accounts[2]})
    nft.approve(zero_addr, 1337, {'from': accounts[2]})
    assert nft.getApproved(1337) == zero_addr


def test_no_return_value(nft, accounts):
    nft.mint(accounts[2], 1337)

    tx = nft.approve(accounts[1], 1337, {'from': accounts[2]})
    assert tx.return_value is None


def test_approval_event_fire(nft, accounts):
    nft.mint(accounts[2], 1337)
    tx = nft.approve(accounts[1], 1337, {'from': accounts[2]})
    assert len(tx.events) == 1
    assert tx.events["Approval"].values() == [accounts[2], accounts[1], 1337]


def test_illegal_approval(nft, accounts):
    nft.mint(accounts[0], 1337)
    with brownie.reverts("ERC721: approve caller is not owner nor approved for all"):
        nft.approve(accounts[1], 1337, {'from': accounts[1]})


def test_get_approved_nonexistent(nft, accounts):
    with brownie.reverts("ERC721: approved query for nonexistent token"):
        nft.getApproved(1337)

def test_approve_all(nft, accounts):
    assert nft.isApprovedForAll(accounts[0], accounts[1]) is False
    nft.setApprovalForAll(accounts[1], True, {'from': accounts[0]})
    assert nft.isApprovedForAll(accounts[0], accounts[1]) is True


def test_approve_all_multiple(nft, accounts):
    operators = accounts[4:8]
    for op in operators:
        assert nft.isApprovedForAll(accounts[1], op) is False

    for op in operators:
        nft.setApprovalForAll(op, True, {'from': accounts[1]})

    for op in operators:
        assert nft.isApprovedForAll(accounts[1], op) is True


def test_revoke_operator(nft, accounts):
    nft.setApprovalForAll(accounts[1], True, {'from': accounts[0]})
    assert nft.isApprovedForAll(accounts[0], accounts[1]) is True

    nft.setApprovalForAll(accounts[1], False, {'from': accounts[0]})
    assert nft.isApprovedForAll(accounts[0], accounts[1]) is False


def test_no_return_value(nft, accounts):
    tx = nft.setApprovalForAll(accounts[1], True, {'from': accounts[0]})
    assert tx.return_value is None


def test_approval_all_event_fire(nft, accounts):
    tx = nft.setApprovalForAll(accounts[1], True, {'from': accounts[0]})
    assert len(tx.events) == 1
    assert tx.events["ApprovalForAll"].values() == [accounts[0], accounts[1], True]


def test_operator_approval(nft, accounts):
    nft.mint(accounts[0], 1337)
    nft.setApprovalForAll(accounts[1], True, {'from': accounts[0]})
    nft.approve(accounts[2], 1337, {'from': accounts[1]})