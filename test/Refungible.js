const {time} = require('@openzeppelin/test-helpers');
const Refungible = artifacts.require('Refungible.sol');
const NFT = artifacts.require('NFT.sol');
const DAI = artifacts.require('DAI.sol');

const share_amount = web3.utils.toWei('25000');

contract("Refungible", async addresses => {
    const [admin, buyer1, buyer2, buyer3, buyer4, _] = addresses;

    if("NFT ICO should work", async() => {
        const dai = await DAI.new();
        const nft = await NFT.new('A really shitty NFT');
        await nft.mint(admin, 1);
        await Promise.all([ dai.mint(buyer1, dai_amount),
            dai.mint(buyer2, dai_amount),
            dai.mint(buyer3, dai_amount),
            dai.mint(buyer4, dai_amount),]);

            const refungible = await Refungible.new(
                'A shitty NFT',
                'Refungible',
                nft.address,
                1,
                1,
                web3.utils.toWei('100000'),
                dai.address
            );
            await nft.approve(rft.address, 1);
            await refungible.startSale();

            await dai.approve(rft.address, dai_amount, {from: buyer1});
            await refungible.buyShare(share_amount, {from:buyer1});
            await dai.approve(rft.address, dai_amount, {from: buyer2});
            await refungible.buyShare(share_amount, {from:buyer2});
            await dai.approve(rft.address, dai_amount, {from: buyer3});
            await refungible.buyShare(share_amount, {from:buyer3});
            await dai.approve(rft.address, dai_amount, {from: buyer4});
            await refungible.buyShare(share_amount, {from:buyer4});

            await time.increase(7*864000 +1);
            await refungible.withdrawProfits();

            const balanceShareBuyer1 = await refungible.balanceOf(buyer1);
            const balanceShareBuyer2 = await refungible.balanceOf(buyer2);
            const balanceShareBuyer3 = await refungible.balanceOf(buyer3);
            const balanceShareBuyer4 = await refungible.balanceOf(buyer4);
            assert(balanceShareBuyer1.toString() === share_amount);
            assert(balanceShareBuyer2.toString() === share_amount);
            assert(balanceShareBuyer3.toString() === share_amount);
            assert(balanceShareBuyer4.toString() === share_amount);
            const balanceAdminDai = await dai.balanceOf(NFTadmin);
            assert(balanceAdminDai.toString() === web3.util.toWei('100000'));
    });
});
