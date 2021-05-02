pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract fToken is ERC20 {

    address private farmTopiaInterface;

    event mintOnDepositEvent(address indexed user, uint256 amount);
    event burnOnWithdrawEvent(address indexed user, uint256 fTokensAmount);
    constructor(string memory _tokenName, string memory _symbol, address _farmIAddress) public 
    ERC20(_tokenName, _symbol) {
        farmTopiaInterface = _farmIAddress;
    }

    modifier onlyFarmtopiaInterface {
        require(msg.sender == farmTopiaInterface);
        _;
    }

    function mintOnDeposit(address _account, uint256 _amount) onlyFarmtopiaInterface public returns(uint256) {
        require(_account != address(0));
        require(_amount > 0);
        _mint(_account,_amount);
        emit mintOnDepositEvent(_account, _amount);
        return _amount;
    }


    function burnOnWithdraw(address _account, uint256 _amount) onlyFarmtopiaInterface public returns(uint256) {
        require(_account != address(0));
        require(_amount > 0);
        _burn(_account,_amount);
        emit burnOnWithdrawEvent(_account, _amount);
    }
}