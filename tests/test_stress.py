import brownie

def test_mint(nft, stress_nft, accounts):
	for i in range(100):
		nft.mint(accounts[0], i + 1)
		stress_nft.mint(accounts[0], i + 1)

	for i in range(20):
		nft.mintBatch(accounts[1], [101 + j for j in range(i * 5, (i + 1) * 5)])

def test_transfer(nft, stress_nft, accounts):
	for i in range(100):
		nft.transferFrom(accounts[0], accounts[1], i + 1, {'from':accounts[0]})
		stress_nft.transferFrom(accounts[0], accounts[1], i + 1, {'from':accounts[0]})

	for i in range(2):
		nft.batchTransferFrom(accounts[1], accounts[0], [j for j in range(50 * i + 1, 50 * (i + 1) + 1)], {'from':accounts[1]})

def test_safe_transfer(nft, stress_nft, accounts):
	for i in range(100):
		nft.safeTransferFrom(accounts[0], accounts[1], i + 1, {'from':accounts[0]})
		stress_nft.safeTransferFrom(accounts[1], accounts[0], i + 1, {'from':accounts[1]})
