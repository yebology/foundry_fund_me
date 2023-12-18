// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test
{
    FundMe fundMe;
    address USER = makeAddr('User');
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external
    {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // cheatcode buat ngasi user baru fake balance supaya bisa digunain di fake transaction
    }

    function testMinimumDollarIsFive() public
    {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public 
    {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testFundFailsWithoutEnoughETH() public
    {
        vm.expectRevert(); // setelah line ini, codenya harus revert (harus error)
        fundMe.fund(); // ini error, soalnya ga nge fund apa"
    }

    function testFundUpdatesFundedDataStructure() public 
    {
        vm.prank(USER); // transaction dibawah ini semuanya akan dilakukan oleh USER

        fundMe.fund{
            value: SEND_VALUE
        }();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public
    {
        vm.prank(USER);

        fundMe.fund{
            value: SEND_VALUE
        }();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded()
    {
        vm.prank(USER);
        
        fundMe.fund{
            value: SEND_VALUE
        }();

        _;
    }

    function testOnlyOwnerCanWithdraw() public funded
    {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded
    {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunders() public funded 
    {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++)
        {
            // artinya itu kyk deal, cm bisa dilakuin di banyak dummy address
            // kalo dibawah ini brrti dia buat dummy address 9 dengan isi balance yang sama semua
            // dari 1 - 9, gabisa dari 0 soalnya biasanya error atau ga ke revert
            hoax(address(i), SEND_VALUE); 
            fundMe.fund{
                value: SEND_VALUE
            }();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    // Jenis test : 
    // 1. Unit : testing bagian spesifik dari suatu code
    // 2. Integration : testing bagaimana code kita bekerja dengan bagian code lainnya
    // 3. Forked : testing code kita dalam simulasi environment nyata
    // 4. Staging : testing our code in real environment that is not prod


}