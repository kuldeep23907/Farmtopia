pragma solidity ^0.6.0;
import "./fToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


interface BridgeIERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function withdraw(address account, uint256 amount) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FarmtopiaInterface is Ownable,ReentrancyGuard {

    using SafeMath for uint256;
    address constant DAI_ADDRESS = 0x59d141841328f89bF38672419655175F53740010;
    address fDAI_ADDRESS;
    uint256 public totalDeposit;
    uint256 public uninvestedAmount;
    address private keeper;

    modifier onlyKeeper {
        require(msg.sender == keeper);
        _;
    }

    function setfDAI(address _fDai) external  onlyOwner {
        fDAI_ADDRESS = _fDai;
    }

    function setKeeper(address _keeper) external onlyOwner {
        keeper = _keeper;
    }

    function deposit(uint256 _amount) public nonReentrant {
        require(fDAI_ADDRESS != address(0), "fToken not set");
        fToken ftoken = fToken(fDAI_ADDRESS);
        ERC20 token = ERC20(DAI_ADDRESS);
        token.transferFrom(msg.sender, address(this), _amount);
        ftoken.mintOnDeposit(msg.sender, _amount);
        totalDeposit = totalDeposit.add(_amount);
        uninvestedAmount = (token.balanceOf(address(this)).mul(2)).div(100);
    }

    function withdraw(uint256 _fTokens) public nonReentrant {
        require(fDAI_ADDRESS != address(0), "fToken not set");
        require(_fTokens > 0);
        require(_fTokens <= uninvestedAmount);
        fToken ftoken = fToken(fDAI_ADDRESS);
        ERC20 token = ERC20(DAI_ADDRESS);
        ftoken.burnOnWithdraw(msg.sender, _fTokens);
        token.transfer(msg.sender,_fTokens);
        totalDeposit = totalDeposit.sub(_fTokens);
        uninvestedAmount = ((token.balanceOf(address(this)).mul(2)).div(100));
    }


    function rebalanceL1(uint256 _amt, address _target) onlyKeeper external {
        require(_amt > 0);
        require(_target != address(0));
        require(keeper != address(0));
        BridgeIERC20 token = BridgeIERC20(DAI_ADDRESS);
        require(token.balanceOf(address(this)) >= _amt, "Not enough balance");
        require(((token.balanceOf(address(this)).mul(98)).div(100)) >= _amt, "Chopping uninvested amount");
        token.withdraw(_target, _amt);
    }

    // function withdrawSlow when amount > uninvestedAmount
}