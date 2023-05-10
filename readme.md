# Cairo anchoring

## How to compile and deploy the contract
- In order to be able to compile you contract, set up your env.
- Once your env is ready, let's compile your cairo contract to sierra:
    ```
    starknet-compile anchoring_contract.cairo anchoring_contract.json
    ```
- If everything goes well, you should be able to declare you contract class:
    ```
    starknet declare --contract anchoring_contract.json --account name_of_the_account_previously_created_into_your_env_setup
    ```
    (If didn't set up an env var for this, you may need to define the network you want with `--network the_network`).  
    And the return should be:
    ```
    Sending the transaction with max_fee: 0.000001 ETH (1378300000000 WEI).
    Declare transaction was sent.
    Contract class hash: 0x61d8bda4bc0230c01996db8590bc39825dbcfd35de93719fa28f4901c4fcacb
    Transaction hash: 0x851025e8e1e6c88ecc663ad2dd150fca9ec5ab37270630d002999e96abf01c
    ```
    You can find the transaction [here](https://testnet.starkscan.co/tx/0x851025e8e1e6c88ecc663ad2dd150fca9ec5ab37270630d002999e96abf01c).  

- Now, deploy your own instance of your contract (with the class hash of your own contract):
    ```
    starknet deploy --class_hash 0x61d8bda4bc0230c01996db8590bc39825dbcfd35de93719fa28f4901c4fcacb --account name_of_the_account_previously_created_into_your_env_setup
    ```
    The return should look like this:
    ```
    Sending the transaction with max_fee: 0.000003 ETH (3426500000001 WEI).
    Invoke transaction for contract deployment was sent.
    Contract address: 0x01e28b415dc375049c2c4bfdabad58e63e19d45aecbfaa4fad78991d55b6eaf7
    Transaction hash: 0x177bc2cbfd21cadecb2cf1bf5af3b00ff7ea82327cb91c65f6acd952e1d00be
    ```
    You can find the transaction [here](https://testnet.starkscan.co/tx/0x177bc2cbfd21cadecb2cf1bf5af3b00ff7ea82327cb91c65f6acd952e1d00be) and you can interact with the contract [here](https://testnet.starkscan.co/contract/0x01e28b415dc375049c2c4bfdabad58e63e19d45aecbfaa4fad78991d55b6eaf7). 
    

## How to interact with the contract
- First of all, go the [contract page into the explorer, into the tab **Read/Write**](https://testnet.starkscan.co/contract/0x01e28b415dc375049c2c4bfdabad58e63e19d45aecbfaa4fad78991d55b6eaf7#read-write-contract), then you should be able to consult the current anchored value by calling `my_anchored()` function.
- For the next interactions, you will need to get a wallet that will make you able to interact with functions on the explorer like [ArgentX](https://www.argent.xyz/argent-x/). 
- You will need to create a wallet and fund it with something like `0.001eth` to be fine.
- You can now prepare your message, it can be a number or a string, if you want to do a string you can use a tool like [this](https://string-functions.com/string-hex.aspx) in order to generate an hex version of your string.
-  Call the function `set_value(value)` with value something like `0x<your_hex_converted_value>`.
- Congratulation!