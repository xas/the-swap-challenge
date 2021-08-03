const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Wrapper", function() {
  let token1;
  let token2;
  let tokenZ;
  let wrapper;
  let token1Factory;
  let token2Factory;
  let tokenZFactory;
  let wrapperFactory;
  let owner;

  it("Sequences should be ok", async function() {

    [owner] = await ethers.getSigners();
    const twoThousand = ethers.utils.parseEther('2000');
    const oneHundred = ethers.utils.parseEther('100');
    const fifty = ethers.utils.parseEther('50');

    // 1
    token1Factory = await ethers.getContractFactory("Token1");
    token1 = await token1Factory.deploy();
    // 2
    token2Factory = await ethers.getContractFactory("Token2");
    token2 = await token2Factory.deploy();
    // 3
    tokenZFactory = await ethers.getContractFactory("TokenZ");
    tokenZ = await tokenZFactory.deploy();
    // 4
    wrapperFactory = await ethers.getContractFactory("Wrapper");
    wrapper = await wrapperFactory.deploy(token1.address, token2.address, tokenZ.address);
    // 5
    await tokenZ.grantRole(await tokenZ.DEFAULT_ADMIN_ROLE.call(), wrapper.address);
    // 6
    await tokenZ.grantRole(await tokenZ.MINTER_ROLE.call(), wrapper.address);
    // 7
    await tokenZ.revokeRole(await tokenZ.MINTER_ROLE.call(), owner.address);
    // 8
    await tokenZ.revokeRole(await tokenZ.DEFAULT_ADMIN_ROLE.call(), owner.address);
    // 9
    await token1.mint(owner.address, twoThousand);
    // 10
    await token2.mint(owner.address, twoThousand);
    // 11
    await token2.mint(wrapper.address, fifty);
    // 12
    await token1.approve(wrapper.address, oneHundred);
    // 13
    const balanceCBefore = await tokenZ.balanceOf(owner.address);
    await wrapper.swap(token1.address, oneHundred);
    const balanceCAfter = await tokenZ.balanceOf(owner.address);
    expect(balanceCAfter).to.equal(oneHundred.sub(balanceCBefore));

    // 14
    await tokenZ.approve(wrapper.address, fifty);
    // 15
    console.log("unswap");
    const balanceBBefore = await token2.balanceOf(owner.address);
    await wrapper.unswap(token2.address, fifty);
    const balanceBAfter = await token2.balanceOf(owner.address);
    expect(balanceBAfter).to.equal(balanceBBefore.add(fifty));
  });
});
