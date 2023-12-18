// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { PriceConverter } from "./PriceConverter.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe
{
    using PriceConverter for uint256;

    //constant gabakal berubah variabele dan dideklarasi lgsg sebaris, 
    // gas yang dikeluarkan jd lebih efisien
    uint256 public constant MINIMUM_USD = 5e18; // dalam wei artian ini 5 ETH

    address[] private s_funders;

    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable i_owner; // immutable mirip sama constant tapi deklarasi variabelnya ditempat lain ga sebaris

    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed)
    {
        i_owner = msg.sender; // owner adalah deployer
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function getVersion() public view returns(uint256)
    {
        return s_priceFeed.version();
    }

    function fund() public payable 
    {
        // msg.value itu value yang dikirim dalam wei
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "didn't send enough ETH!");
        s_funders.push(msg.sender); //ngepush alamat pengirim

        s_addressToAmountFunded[msg.sender] = s_addressToAmountFunded[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner
    {
        // ini yang bener, sebisa mungkin jangan sering pake storage, soalnya makan gas banyak
        uint256 lengthOfFunders = s_funders.length; 
        for (uint256 index = 0; index < lengthOfFunders; index++)
        {
            address funder = s_funders[index];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0); // buat reset array, dengan panjang awal 0
        // payable(msg.sender).transfer(address(this).balance); // artinya balance di satu kontrak ini akan DITRANSFER ke msg.sender
        // // payable(msg.sender) => tujuan pengiriman uang 
        // // kalau failed transaction otomatis ke-revert (uang balik)

        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Error send");
        // kalau pake send harus diginiin, kalo ga uangmu gabakal ke revert

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
        // kalau call ini mirip send, cuma lebih baik daripada send sama transfer soalnya gada maximal gas e
        // kalau send sama transfer maksimale 2300 gas
        // return 2 variabel, pertama boolean kedua bytes memory
    }

    modifier onlyOwner()
    {
        require(msg.sender == i_owner, "Only owner can withdraw this contract"); // jalanin ini dulu
        _; // setelahnya baru jalanin logika apapun di function yang memanggil
    }

    receive() external payable
    {
        fund(); // kalo ga masukin data di CALL DATA otomatis manggil fund
    }

    fallback() external payable 
    {
        fund(); // kalo ga sengaja input ngawur di CALL DATA manggil fund juga
    }

    function getAddressToAmountFunded(address _fundingAddress) external view returns (uint256)
    {
        return s_addressToAmountFunded[_fundingAddress];
    }

    function getFunder(uint256 _index) external view returns (address)
    {
        return s_funders[_index];
    }

    function getOwner() external view returns (address)
    {
        return i_owner;
    }
}