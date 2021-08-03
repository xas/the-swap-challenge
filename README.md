# The Source

This code was made as a challenge for a position as a solidity developer.

## The Task

The challenge was to create a token swapping smart contract. You have two tokens. You can swap each of it for another one. Rates was one-to-one. Basically the behaviour was :

* I got Token1, I will swap for TokenZ
* I got Token2, I will swap for TokenZ
* I got TokenZ, I can swap for either Token1 or Token2

There was some requirements for the task :

* A wrapper contract with two methods name was provided : `function swap(address token_, uint amount)` and `function unswap(address token_, uint amount)`
* Token1 should be minted outside the wrapper contract
* Token2 should be minted outside the wrapper contract
* TokenZ should be minted inside the wrapper contract
* External code (like OpenZeppelin) was allowed
* Describe the call sequence for everything to do

## The Process

### Step 1 - The Tokens

OK, this should not be difficult. Create 3 tokens, just inheriting an OpenZeppelin code. What could go wrong ?
Just three `contract Token is ERC20PresetMinterPauser`. I choose `ERC20PresetMinterPauser` class because I need to be able to mint the tokens

### Step 2 - The Wrapper

So, in this wrapper I should implement the two functions `swap()` and `unswap()`

What `swap()` do ?

* Verify that the provided token address is either _Token1_ or _Token2_
* Transfer the requested amount of Token 1 (or Token2) from the sender to the contract
* Mint the same amount of TokenZ to the sender address
* emit the swap event

And what `unswap()` do ?

* Verify that the provided token address is either _Token1_ or _Token2_
* Burn the amount of TokenZ from the sender address
* Transfer the amount of Token 1 (or Token 2) from the contract to the sender
* emit the unswap event

**Remarks**  
Questions were raised.

First, _should I add the approve call_ before the `transferFrom` call ?
I think that it is not necessary. The _approve_ should be made outside the (un)swap call. (un)swap functions must be independent of the available allowance

Second, _should I verify the allowance_ before the `transferFrom` call ?
Same as first. The _transferFrom_ already check for allowance and its `require` will fail if token amount is missing

Third, _should I verify the balance_ before the `transfer` in the unswap call ?
I think I have to, and so I missed this one. I have too much trust about other code, and it is a really big mistake in the crypto-game.

Finally, I missed a `require(amount > 0, "Amount is zero);` request at both functions. I leave the controls to the subcall, avoiding to write the same check.
It is bad habit, I know...

## The Call Sequence

Here are all the sequences you will find in the test sections to execute a fully functional workflow of the challenge.
The amounts used in this sequence are `toWei(100, 'eth')` and `toWei(50, 'eth)`

1. Deploy Token1()
2. Deploy Token2()
3. Deploy TokenZ()
4. Deploy Wrapper(Token1.address, Token2.address, TokenZ.address)
5. Call TokenZ.grantRole(TokenZ.MINTER_ROLE, Wrapper.address)
6. Call TokenZ.grantRole(TokenZ.DEFAULT_ADMIN_ROLE, Wrapper.address)
7. Call TokenZ.revokeRole(TokenZ.MINTER_ROLE, "your wallet address")
8. Call TokenZ.revokeRole(TokenZ.DEFAULT_ADMIN_ROLE, "your wallet address")
9. Call Token1.mint("your wallet address", "100000000000000000000") // 100 eth
10. Call Token2.mint("your wallet address", "100000000000000000000") // 100 eth
11. Call Token2.mint(Wrapper.address, "50000000000000000000") // 50 eth
12. Call Token1.approve(Wrapper.address, "100000000000000000000") // 100 eth
13. Call Wrapper.swap(Token1.address, "100000000000000000000") // 100 eth
14. Call TokenZ.approve(Wrapper.address, "50000000000000000000") // 50 eth
15. Call Wrapper.unswap(Token2.address, "100000000000000000000") // 100 eth

PS : be careful to **GRANT ROLE** before to **REVOKE ROLE**
