# exper2:不用库实现ERC20代币 部署在OKTtestchain chainId=65


## 1.创建hardhat工程



![image-20231110135228042](.\assets\image-20231110135228042.png)

## 2.编写代码



### **1）代币合约代码**

**MyERC20.sol**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract MyERC20 {
    //地址映射余额。
    mapping(address => uint256) private _balances;
    //将所有者地址映射到另一个映射，该映射将批准者地址映射到余额。其实就是额度
    mapping(address => mapping(address => uint256)) private _allowances;
    //总供应量
    uint256 private _totalSupply;
    //存储代币的名称和符号。
    string private _name;
    string private _symbol;

    //事件 调用相关方法时触发
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    //以下是提供几个状态变量的公共get方法
    function name() public view virtual  returns (string memory) {
        return _name;
    }

    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual  returns (uint8) {
        return 6;
    }

    function totalSupply() public view virtual  returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual  returns (uint256) {
        return _balances[account];
    }


    //transfer|转账：将指定数量的代币从调用者转移到指定的地址。
    function transfer(address to, uint256 amount) public virtual  returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    //allowance|返回指定批准者可以从指定所有者那里转移的代币数量。
    function allowance(address owner, address spender) public view virtual  returns (uint256) {
        return _allowances[owner][spender];
    }

    //approve|批准：返回指定批准者可以从指定所有者那里转移的代币数量
    function approve(address spender, uint256 amount) public virtual  returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    //transferFrom|转账
    function transferFrom(address from, address to, uint256 amount) public virtual  returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    //增加/减少increaseAllowance/decreaseAllowance批准者的代币数量。这是approve的替代方法，可以用作解决IERC20-approve中描述的问题的缓解方法。
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    //_transfer内部方法 由涉及转账的方法调用，如：transferFrom，transfer
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;

            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }


    //mint内部方法 创建指定数量的代币并将它们分配给指定的账户，增加总供应量
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    //_burn内部方法 销毁指定账户的指定数量的代币，减少总供应量
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }


    //设置批准者可以从所有者那里转移的代币数量。这个内部函数等同于approve，可以用来设置某些子系统的自动批准额度等。
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    //内部函数_spendAllowance 根据花费的amount更新owner对spender的批准额度。
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }


    //在任何代币转移 之前/之后 调用的钩子函数。这包括铸造和销毁。由代币合约实现
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}


    //返回msg.sender和msg.data信息
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




```

**XRMToken**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./MyERC20.sol";

contract XRMToken is MyERC20 {

    constructor(
        string memory name_, //xiaruoming
        string memory symbol_,//XRM
        uint256 totalSupply_ //10000000，000000也就是：10000000000000 发行量1000万 精度decimal为6
    ) MyERC20(name_, symbol_) {
        _mint(msg.sender, totalSupply_);
    }
}
```



### 2）部署脚本

**deployXRMToken.js**

```solidity
const ethers = require("hardhat").ethers;

async function main() {

  const totalSupply = ethers.utils.parseUnits('10000000', 6)
  // console.log('totalSupply:', totalSupply);
  
  const XRMToken = await ethers.getContractFactory('XRMToken');

  const xrm = await XRMToken.deploy("xiaruoming", "XRM", totalSupply);
  await xrm.deployed();

  console.log(`new World Cup Token deployed to ${xrm.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

```

运行结果：

![image-20231110135332663](.\assets\image-20231110135332663.png)

**合约地址：**`0xbf25a22B8e775Ea4f10a530944Aeed58dD4D04f5`

### 3）合约验证

这里不知道为啥框架验证不了 报错信息如下：

![image-20231110135357113](.\assets\image-20231110135357113.png)

于是改用remix插件验证

![image-20231110135417537](.\assets\image-20231110135417537.png)

然后发现浏览器上并没有成功 明明显示成功了的...

![image-20231110135435618](.\assets\image-20231110135435618.png)





于是浏览器上验证

![image-20231110135500377](.\assets\image-20231110135500377.png)

成功

![image-20231110135521823](.\assets\image-20231110135521823.png)



## 3.区块链浏览器查看

![image-20231110135549727](.\assets\image-20231110135549727.png)

![image-20231110135606453](.\assets\image-20231110135606453.png)





