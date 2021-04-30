pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract fToken is ERC20 {

    address private farmTopiaInterface;

    event mintOnDeposit(address indexed user, uint256 amount);
    event burnOnWithdraw(address indexed user, uint256 fTokensAmount);
    constructor(string _tokenName, string _symbol, address _farmIAddress) public 
    ERC20(_tokenName, _symbol) {
        farmTopiaInterface = _farmIAddress;
    }

    modifier onlyFarmtopiaInterface {
        require(msg.sender == farmTopicInterface);
        _;
    }

    function mintOnDeposit(address _account, uint256 _amount) onlyFarmtopiaInterface public returns(uint256) {
        require(_account != address(0));
        require(_amount > 0);
        _mint(_account,_amount);
        emit mintOnDeposit(_account, _amount);
        return _amount;
    }


    function burnOnWithdraw(address _account, uint256 _amount) onlyFarmtopiaInterface public returns(uint256) {
        require(_account != address(0));
        require(_amount > 0);
        _burn(_account,_amount);
        emit burnOnWithdraw(_account, _amount);
    }
}