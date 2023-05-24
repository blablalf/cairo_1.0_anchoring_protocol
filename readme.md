# Cairo anchoring

This protocol involves two types of contracts: the Factory contract and the Anchoring contract.

## Factory Contract  

The Factory contract is responsible for deploying an Anchoring contract for each client/product.  

### Features:
- Administration: The Factory contract contains an admin. Only this admin can use the deployment function of the Anchoring contract.
- Deployment: When the admin calls the deployment function, they mention the address to be whitelisted for invoking this Anchoring contract.
- Admin Transfer: The admin of the Factory contract can designate another address as the admin, thereby forfeiting their admin access.

## Anchoring Contract:  

The Anchoring contract is responsible for anchoring hashes.

### Features:
- Whitelisting: Only the whitelisted address can anchor a hash.  
- Fixed Address: This address does not change for the contract. If the client wishes to change the address, a new Anchoring contract must be deployed.  
- Hash uniqueness: A hash can only be anchored once.
- Hash Anchoring: When a hash is anchored, the current block's timestamp is saved.  
Retrieval: One can retrieve an array of the anchored hashes, as well as an array of each of these hashes' timestamps, without any cost. Additionally, one can retrieve the timestamp from the hash without any cost.

## Future Enhancements (v2):
In the next version, I plan to implement a new data type that will save on storage by eliminating the need for a mapping. This will represent the maximum optimization for this project. I didn't implement this in the current version because implementing a new data type requires coding all the read, write functions etc. and this is currently undocumented. Thus, it would take me more time. If you are not in a rush, I can work on this after completing part 3, or we would need to reschedule these parts.

When it comes to reading information from the contract, this will mean we will directly have an array containing a sort of tuple/struct with a hash and a timestamp. We can still have the function that gives a timestamp for a hash free of charge (we could even add the reverse, a hash for a timestamp).

For more details and updates, please visit the [repository](https://github.com/blablalf/cairo_1.0_anchoring_protocol).

## How to compile and deploy the contract
- In order to be able to compile you contract, set up your env.
- Once your env is ready, let's compile your cairo contracts to sierra:
    ```
    starknet-compile factory.cairo factory.json
    starknet-compile anchoring.cairo anchoring.json
    ```
- If everything goes well, you should be able to declare you contract classes (actually theu are already declared into the goerli testnet so you don't have to and shouldn't be able to do it, just use the contract class specified into the output to deploy them):
    ```
    starknet declare --contract factory.json --account name_of_the_account_previously_created_into_your_env_setup
    starknet declare --contract anchoring.json --account name_of_the_account_previously_created_into_your_env_setup
    ```
    (If didn't set up an env var for this, you may need to define the network you want with `--network the_network`).  
    The return for the `factory` should be like this:
    ```
    Sending the transaction with max_fee: 0.000035 ETH (35060876251879 WEI).
    Declare transaction was sent.
    Contract class hash: 0x54f828411babff897416e1e67ab0d4b460e1a375ec97280042598d7c16682da
    Transaction hash: 0x424f64f152fa11725e1d5b7b03bd4a61528ff6bd677ed9538323da31bbb9a43
    ```
    You can find the transaction [here](https://testnet.starkscan.co/tx/0x36baeb1394db40b8768a41e99ca89eb1f39d9538f50693c78d7874e46233a6f).  
  
    And the return for the `Anchor` contract should be like this:
    ```
    Sending the transaction with max_fee: 0.000054 ETH (54448902757588 WEI).
    Declare transaction was sent.
    Contract class hash: 0x2d099db76414515e745d68a83a1a8324b7a408fb454f3ac590cc889ba97dc62
    Transaction hash: 0x122c7d9d3cae6fc325c8a462ca7b79718df4ace29f0d268df47075227359edc
    ```
    You can find the transaction [here](https://testnet.starkscan.co/tx/0x122c7d9d3cae6fc325c8a462ca7b79718df4ace29f0d268df47075227359edc).  

- Now, deploy your own instance of your factory (with the previous class hash):
    ```
    starknet deploy --class_hash 0x54f828411babff897416e1e67ab0d4b460e1a375ec97280042598d7c16682da --input 0x058c19CCF47AFd7acC6db057FE4c6676168b130281C315007075fCD732503B7D 0x2d099db76414515e745d68a83a1a8324b7a408fb454f3ac590cc889ba97dc62 --account name_of_the_account_previously_created_into_your_env_setup
    ```
    The return should look like this:
    ```
    Sending the transaction with max_fee: 0.000159 ETH (158573030353235 WEI).
    Invoke transaction for contract deployment was sent.
    Contract address: 0x02949d387aeb62a765f9ae174018583523dff16e78f992ad0e3ab3246ded87ed
    Transaction hash: 0x819882fb69cdbf0a28d0753bc034be0978b7dc4e27fd3b8eee79d6a134b84
    ```
    You can find the transaction [here](https://testnet.starkscan.co/tx/0x819882fb69cdbf0a28d0753bc034be0978b7dc4e27fd3b8eee79d6a134b84) and you can interact with the contract [here](https://testnet.starkscan.co/contract/0x02949d387aeb62a765f9ae174018583523dff16e78f992ad0e3ab3246ded87ed).  
    Since the factory will deploy instances of the `Anchor` contract, we don't have to deploy it manually, but you can do it with the class hash if you want.  
    
## How to interact with the contract
- First of all, go the [contract page into the explorer, into the tab **Read/Write**](https://testnet.starkscan.co/contract/0x02949d387aeb62a765f9ae174018583523dff16e78f992ad0e3ab3246ded87ed#read-write-contract), then you should be able to consult the current anchored value by calling `my_anchored()` function.
- For the next interactions, you will need to get a wallet that will make you able to interact with functions on the explorer like [ArgentX](https://www.argent.xyz/argent-x/). 
- You will need to create a wallet and fund it with something like `0.001eth` to be fine.
- You can now prepare your message, it can be a number or a string, if you want to do a string you can use a tool like [this](https://string-functions.com/string-hex.aspx) in order to generate an hex version of your string.
-  Call the function `set_value(value)` with value something like `0x<your_hex_converted_value>`.
- Congratulation!