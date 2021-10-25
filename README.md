# Layer's Single NFT and NFT Collections Contract

## Public Functions

### mint single token
```
(mint-single-token (data {price: uint, for-sale: bool}) (metadata (string-ascii 256)) (royalties (optional (list 5 {address: principal, percentage: uint}))))
```
##### Parameters
- data: tuple: {price: uint, for-sale: bool}
- metadata: string-ascii 256
- royalties: optional: list of tuples (max len 5): {address: principal, percentage: uint}
##### Returns 
- On success: `token-id`
- On error: `error-id`

##### Description
Mints a single NFT. `token-id` defined in contract as `1 + last-token-id`. 
Range of possible `token-id`s for single tokens is `u10000000001` to `u19999999999`

##### Sample clarinet calls
- Token with 2 royalties:
```
(contract-call? 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.main mint-single-token {price: u100, for-sale: true} "ipfs://abcalsjdhf" (some (list {address: 'STFCVYY1RJDNJHST7RRTPACYHVJQDJ7R1DWTQHQA, percentage: u1000} {address: 'STEB8ZW46YZJ40E3P7A287RBJFWPHYNQ2AB5ECT8, percentage: u2000})))
```
- Token with no royalties:
```
(contract-call? 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.main mint-single-token {price: u100, for-sale: true} "ipfs://abcalsjdhf" none)
```

### mint collection
```
(mint-collection (files (optional (list 100 {metadata: (string-ascii 256), data: {price: uint, for-sale: bool}}))) (royalties (optional (list 5 {address: principal, percentage: uint}))))
```
##### Parameters
- files: optional: list of tuples (max len 100): {metadata: (string-ascii 256), data: {price: uint, for-sale: bool}}
- royalties: optional: list of tuples (max len 5): {address: principal, percentage: uint}
##### Returns 
- On success: `collection-id`
- On error: `error-id`

##### Description
Creates a new Collection of NFTs. Automatically generates a `collection-id` defined as `1 + last-collection-id`. <br />
Range of possible `collection-id`s is `u200001` to `u999999`.<br />
Automatically generates `file-id`s for each file passed in defined as `1 + last-file-id`. <br />
Range of possible `file-id`s is `u00001` to `u99999`.<br />
Finally, for each file, a unique `token-id` is generated defined as `collection-id * u100000 + file-id`.<br />
E.g `token-id: u20004800087` refers to the 87th file in the 48th collection.

##### Sample clarinet calls
- Initialize empty collection with no royalties:
```
(contract-call? 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.main mint-collection none none)
```
- Collection with 3 files and 1 royalty:
```
(contract-call? 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.main mint-collection (some (list {data: {price: u100000, for-sale: true}, metadata: "ipfs://first"} {data: {price: u100, for-sale: true}, metadata: "ipfs://second"} {data: {price: u10000, for-sale: false}, metadata: "ipfs://third"})) (some (list {address: 'STFCVYY1RJDNJHST7RRTPACYHVJQDJ7R1DWTQHQA, percentage: u1000})))
```

### mint to collection
```
(mint-to-collection (collection-id uint) (data {price: uint, for-sale: bool}) (metadata (string-ascii 256)) (royalties (optional (list 5 {address: principal, percentage: uint}))))
```
##### Parameters
- collection-id: uint
- data: tuple: {price: uint, for-sale: bool}
- metadata: string-ascii 256
- royalties: optional: list of tuples (max len 5): {address: principal, percentage: uint}
##### Returns 
- On success: `token-id`
- On error: `error-id`

##### Description
Mints NFT and adds it to Collection. Only succeeds if invoked by the creator of Collection. 

##### Sample clarinet calls
- Mint NFT to collection with `collection-id: u200021`, without royalties:
```
(contract-call? 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.main mint-to-collection u200021 {price: u500, for-sale: true} "ipfs://fourth" none)
```
- Mint NFT to collection with `collection-id: u200123`, with two royalties:
```
(contract-call? 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.main mint-to-collection u200123 {price: u500, for-sale: true} "ipfs://fourth" (some (list {address: 'STFCVYY1RJDNJHST7RRTPACYHVJQDJ7R1DWTQHQA, percentage: u1000} {address: 'STEB8ZW46YZJ40E3P7A287RBJFWPHYNQ2AB5ECT8, percentage: u2000})))
```

### purchase
```
(purchase (token-id uint))
```
##### Parameters
- token-id: uint

##### Returns 
- On success: `true`
- On error: `error-id`

##### Description
Allows a user to purchase another user's NFT. Executes only if purchaser is not owner and if NFT is set as for sale. 

##### Sample clarinet call
- Purchase NFT with token ID u10000000123
```
(contract-call? 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.main purchase u10000000123)
```

### complete sale
```
(complete-sale (token-id uint) (new-owner-address principal) (old-owner-address principal) (token-price uint))
```
##### Parameters
- token-id: uint
- new-owner-address: principal
- old-owner-address: principal
- token-price: uint

##### Returns 
- On success: `true`
- On error: `error-id`

##### Description
Admin only functionality that enables USD purchasing and auction flows. Allows admin to manually set sale price, old owner and new owner to distribute royalties, STX transfers and NFT transfer to the right users. Ownership of NFT must first be transferred to admin.

##### Sample clarinet call
- Complete sale for NFT with token-id u10000000001 with sale price of 2 STX
```
(contract-call? 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.main complete-sale u10000000001 'ST3DG3R65C9TTEEW5BC5XTSY0M1JM7NBE7GVWKTVJ 'STEB8ZW46YZJ40E3P7A287RBJFWPHYNQ2AB5ECT8 u2000000)
```

### set token price data
```
(set-token-price-data (token-id uint) (price uint) (for-sale bool))
```
##### Parameters
- token-id: uint
- price: uint
- for-sale: bool

##### Returns 
- On success: `true`
- On error: `error-id`

##### Description
Allows owner of NFT to change price and toggle whether the NFT is available for purchase.

##### Sample clarinet call
- Set price of NFT with token-id u20002100003 to 3 STX and make NFT available for sale.
```
(contract-call? 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.main set-token-price-data u20002100003 u3000000 true)
```

### transfer
```
(transfer (token-id uint) (owner principal) (recipient principal))
```
##### Parameters
- token-id: uint
- owner: principal
- recipient: principal

##### Returns 
- On success: `true`
- On error: `error-id`

##### Description
SIP-009 function. Allows owner of NFT to transfer ownership of NFT to another address. 

##### Sample clarinet call
- Trasnfer ownership of NFT with token id u20002100003 from 'STFCVYY1RJDNJHST7RRTPACYHVJQDJ7R1DWTQHQA to 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE
```
(contract-call? 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.main transfer u20002100003 'STFCVYY1RJDNJHST7RRTPACYHVJQDJ7R1DWTQHQA 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
```

## Read Only Functions

(get-all-token-data (token-id uint))

(get-collection-data (collection-id uint))
  
(get-owner (token-id uint))

(get-last-token-id)

(get-token-uri (token-id uint))




