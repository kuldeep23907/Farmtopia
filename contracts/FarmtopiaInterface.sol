pragma solidity ^0.6.0;
import "./fToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract FarmtopiaInterface is Ownable,ReentrancyGuard {

    using SafeMath for uint256;
    address constant DAI_ADDRESS = 0x59d141841328f89bF38672419655175F53740010;
    address fDAI_ADDRESS;
    uint256 public totalDeposit;
    uint256 public uninvestedAmount;

    function setfDAI(address _fDai) external  onlyOwner {
        fDAI_ADDRESS = _fDai;
    }

    function deposit(uint256 _amount) public nonReentrant {
        require(fDAI_ADDRESS != address(0), "fToken not set");
        fToken ftoken = fToken(fDAI_ADDRESS);
        ERC20 token = ERC20(DAI_ADDRESS);
        token.transferFrom(msg.sender, address(this), _amount);
        ftoken.mintOnDeposit(msg.sender, _amount);
        totalDeposit = token.balanceOf(address(this));
        uninvestedAmount = (totalDeposit.mul(2)).div(100);
    }

    function withdraw(uint256 _fTokens) public nonReentrant {
        require(fDAI_ADDRESS != address(0), "fToken not set");
        require(_fTokens > 0);
        require(_fTokens <= uninvestedAmount);
        fToken ftoken = fToken(fDAI_ADDRESS);
        ERC20 token = ERC20(DAI_ADDRESS);
        ftoken.burnOnWithdraw(msg.sender, _fTokens);
        token.transfer(msg.sender,_fTokens);
        totalDeposit = token.balanceOf(address(this));
        uninvestedAmount = (totalDeposit.mul(2)).div(100);
    }

    // function withdrawSlow when amount > uninvestedAmount
}