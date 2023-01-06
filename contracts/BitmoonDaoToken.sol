// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./Pancake.sol";

// import "@openzeppelin/contracts/utils/math/SafeMathInt.sol";

contract BitmoonDaoToken is ERC20, Ownable {
    using SafeMath for uint256;

    




    //a mapping to determine which contract has access to write data to this contract
    //used in the modifier below
    mapping(address => bool) accessAllowed;
    //function modifier checks to see if an address has permission to update data
    //bool has to be true
    modifier isAllowed() {
        require(accessAllowed[msg.sender] == true);
        _;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    bool inSwap = false;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }


        //set an address to the accessAllowed map and set bool to true
    //uses the isAllowed function modifier to determine if user can change data
    //this function controls which addresses can write data to the contract
    //if you update the UserContract you would add the new address here
    function allowAccess(address[] memory _addresses) public onlyOwner {
        for (uint i =0;i<_addresses.length; i++){
            accessAllowed[_addresses[i]] = true;
        }
    }



    string public constant _name = "Soccer Battle Token";
    string public constant _symbol = "SBT";
    uint8 public constant _decimals = 18;

    uint256 public constant TRANSACTION_TAX_FEE = 5; //5 percent
    address public constant TAX_WALLET = xxxxtoken ; 

    uint256 private LAUNCH_TIME;


    uint256 public constant TOKEN_SUPPLY = 1000000000; // 1 Billion
    uint256 public TOKEN_CLAIMED = 0;


    //IDO
    uint256 private constant IDO_TOKEN_SUPPLY = 83300000; // 8.33 %
    uint256 private IDO_TOKEN_CLAIMED = 0;
    address private IDO_WALLET_ADDRESS;

    //TEAM
    uint256 private constant TEAM_TOKEN_SUPPLY = 30000000; // 8.33 %
    uint256 private TEAM_TOKEN_CLAIMED = 0;

    address private TEAM_WALLET_ADDRESS;

    //GAME
    uint256 public constant GAME_TOKEN_SUPPLY = 400000000; // 40%
    uint256 private GAME_TOKEN_CLAIMED = 0;

    address private GAME_WALLET_ADDRESS;

    //MARKETING
    uint256 public constant MKT_TOKEN_SUPPLY = 128830000; // 12,83%
    uint256 private MKT_TOKEN_CLAIMED = 0;
    address private MKT_WALLET_ADDRESS;

    //Liquidity
    uint256 public constant LIQ_TOKEN_SUPPLY = 240170000; // 24,17%
    uint256 private LIQ_TOKEN_CLAIMED = 0;
    address private LIQ_WALLET_ADDRESS;

    //Staking/Farming
    uint256 public constant STAKE_TOKEN_SUPPLY = 100000000; // 10%
    uint256 private STAKE_TOKEN_CLAIMED = 0;
    address private STAKE_WALLET_ADDRESS;

    //Airdrop
    uint256 public constant AIRDROP_TOKEN_SUPPLY = 16700000; // 1.67%
    uint256 private AIRDROP_TOKEN_CLAIMED = 0;
    address private AIRDROP_WALLET_ADDRESS;




    IPancakeSwapRouter public router;
    address public pair;
    IPancakeSwapPair public pairContract;
    address public pairAddress;


    

    constructor() ERC20(_name, _symbol) {
        //Set Launch time
        LAUNCH_TIME = block.timestamp;

        accessAllowed[msg.sender] = true;

        router = IPancakeSwapRouter(0xdc4904b5f716Ff30d8495e35dC99c109bb5eCf81); // PancakeSwap Router v2

        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        pairAddress = pair;
        pairContract = IPancakeSwapPair(pair);

      

    }

  

    function setup_pancakerouter(address router_address) public onlyOwner {
        //Testnet:  0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        //Live Net: 0x10ED43C718714eb63d5aA57B78B54704E256024E

        router = IPancakeSwapRouter(router_address); // PancakeSwap Router v2

        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        pairAddress = pair;
        pairContract = IPancakeSwapPair(pair);

    }

    function setup_wallets(
        address _ido_wallet_address,
        address _team_wallet_address,
        address _game_wallet_address,
        address _mkt_wallet_address,
        address _liq_wallet_address,
        address _staking_wallet_address,
        address _airdrop_wallet_address

    ) public isAllowed returns (bool) {
        IDO_WALLET_ADDRESS = _ido_wallet_address;
        TEAM_WALLET_ADDRESS = _team_wallet_address;
        GAME_WALLET_ADDRESS = _game_wallet_address;
        MKT_WALLET_ADDRESS = _mkt_wallet_address;
        LIQ_WALLET_ADDRESS = _liq_wallet_address;
        STAKE_WALLET_ADDRESS = _staking_wallet_address;
        AIRDROP_WALLET_ADDRESS = _airdrop_wallet_address;

        return true;

    }

    function get_available_unlocked_token_amount(
        uint256 _total_supply,
        uint256 _minted_qty,
        uint256 tge,
        uint256 cliff_months,
        uint256 vesting_months
    ) internal view returns (uint256) {
        //Available Qty Initial value: 0
        uint256 available_qty = 0;

        uint256 tge_qty = tge.div(100) * _total_supply; // tge = 0%, 10%, 50%

        //Available Qty value: Add TGE
        available_qty += tge_qty;

        if (available_qty == _total_supply) {
            return available_qty;
        }

        // If Available Qty == Total Qty , Return the value

        if (available_qty < _total_supply && vesting_months > 0) {
            //Calculating cliffing
            uint256 months_since_deployment = (block.timestamp - LAUNCH_TIME)
                .div(30 * 24 * 60 * 60); // 1 month = 30 days

            if (months_since_deployment > cliff_months) {
                uint256 months_since_cliffing_time = months_since_deployment -
                    cliff_months;
                //Available Qty value: Add Cliffing value by month
                available_qty += (_total_supply - tge_qty)
                    .div(vesting_months)
                    .mul(months_since_cliffing_time);

                if (months_since_cliffing_time >= vesting_months) {
                    //Available Qty value: All all supply qty if vesting month pass.
                    available_qty = _total_supply;
                }
            }
        }
        //Available Qty value: Subtract the minted quantity
        available_qty -= _minted_qty;

        return available_qty;
    }

    function ido_withdraw() public returns (uint256) {
        require(msg.sender == IDO_WALLET_ADDRESS, "Not authorized!");

        //100% unlocked
        uint256 available_qty = get_available_unlocked_token_amount(
            IDO_TOKEN_SUPPLY,
            IDO_TOKEN_CLAIMED,
            100,
            0,
            0
        );

        require(available_qty > 0, "Token is not available!");

        IDO_TOKEN_CLAIMED += available_qty;
        TOKEN_CLAIMED += available_qty;

        _mint(msg.sender, available_qty * (10**_decimals));

        return available_qty;
    }

    //0% TGE, Cliff 24 months Vesting per month for 24 months
    function team_withdraw() public returns (uint256) {
        require(msg.sender == TEAM_WALLET_ADDRESS, "Not authorized!");

        uint256 available_qty = get_available_unlocked_token_amount(
            TEAM_TOKEN_SUPPLY,
            TEAM_TOKEN_CLAIMED,
            0,
            24,
            24
        );

        require(available_qty > 0, "Token is not available!");

        TEAM_TOKEN_CLAIMED += available_qty;
        TOKEN_CLAIMED += available_qty;

        _mint(msg.sender, available_qty * (10**_decimals));

        return available_qty;
    }

    // 100% unlocked to add into the game prize pool
    function game_withdraw() public returns (uint256) {
        require(msg.sender == GAME_WALLET_ADDRESS, "Not authorized!");

        //100% unlocked
        uint256 available_qty = get_available_unlocked_token_amount(
            GAME_TOKEN_SUPPLY,
            GAME_TOKEN_CLAIMED,
            100,
            0,
            0
        );

        require(available_qty > 0, "Token is not available!");

        GAME_TOKEN_CLAIMED += available_qty;
        TOKEN_CLAIMED += available_qty;

        _mint(msg.sender, available_qty * (10**_decimals));

        return available_qty;
    }

    function mkt_withdraw() public returns (uint256) {
        require(msg.sender == MKT_WALLET_ADDRESS, "Not authorized!");

        //100% unlocked
        uint256 available_qty = get_available_unlocked_token_amount(
            MKT_TOKEN_SUPPLY,
            MKT_TOKEN_CLAIMED,
            100,
            0,
            0
        );

        require(available_qty > 0, "Token is not available!");

        MKT_TOKEN_CLAIMED += available_qty;
        TOKEN_CLAIMED += available_qty;

        _mint(msg.sender, available_qty * (10**_decimals));

        return available_qty;
    }

    function liq_withdraw() public returns (uint256) {
        require(msg.sender == LIQ_WALLET_ADDRESS, "Not authorized!");

        //100% unlocked
        uint256 available_qty = get_available_unlocked_token_amount(
            LIQ_TOKEN_SUPPLY,
            LIQ_TOKEN_CLAIMED,
            100,
            0,
            0
        );

        require(available_qty > 0, "Token is not available!");

        LIQ_TOKEN_CLAIMED += available_qty;
        TOKEN_CLAIMED += available_qty;

        _mint(msg.sender, available_qty * (10**_decimals));

        return available_qty;
    }

    //0% TGE, cliff 1 month, Add to pool reward

    function staking_withdraw() public returns (uint256) {
        require(msg.sender == STAKE_WALLET_ADDRESS, "Not authorized!");

        //100% unlocked
        uint256 available_qty = get_available_unlocked_token_amount(
            STAKE_TOKEN_SUPPLY,
            STAKE_TOKEN_CLAIMED,
            0,
            1,
            0
        );

        require(available_qty > 0, "Token is not available!");

        STAKE_TOKEN_CLAIMED += available_qty;
        TOKEN_CLAIMED += available_qty;

        _mint(msg.sender, available_qty * (10**_decimals));

        return available_qty;
    }

    function airdrop_withdraw() public returns (uint256) {
        require(msg.sender == AIRDROP_WALLET_ADDRESS, "Not authorized!");

        //100% unlocked
        uint256 available_qty = get_available_unlocked_token_amount(
            AIRDROP_TOKEN_SUPPLY,
            AIRDROP_TOKEN_CLAIMED,
            0,
            1,
            0
        );
        require(available_qty > 0, "Token is not available!");
        AIRDROP_TOKEN_CLAIMED += available_qty;
        TOKEN_CLAIMED += available_qty;

        _mint(msg.sender, available_qty * (10**_decimals));
        return available_qty;
    }





    function totalSupply() public pure override returns (uint256) {
        return TOKEN_SUPPLY;
    }


    function transfer(address to, uint256 value) public virtual override returns (bool){
        //Call local function
        return _transferFrom(msg.sender, to, value);
        
    }


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override returns (bool){

        //Call parent functions to spend allowance
        address spender = _msgSender();
        _spendAllowance(from, spender, value);

        // Call local transferFrom
        return _transferFrom(from, to, value);

    }


   
    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        return  (pair == to  ); //|| 
    }


    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        

        uint256 taxFee = 0;

        if (shouldTakeFee(sender,recipient)){
            taxFee = amount.mul(TRANSACTION_TAX_FEE).div(100);

        }
        uint256 netAmount = amount - taxFee;

        if(taxFee>0){
            // Call local transferFrom
            _transfer(sender, TAX_WALLET, taxFee);
            
        }

        // Call local transferFrom
        _transfer(sender, recipient, netAmount);

        return true;

    }
    
}
