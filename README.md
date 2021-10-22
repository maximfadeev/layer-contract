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

