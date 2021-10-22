# Layer's NFT and Collections Contract

## Public Functions

### mint single token
```
(mint-single-token (data {price: uint, for-sale: bool}) (metadata (string-ascii 256)) (royalties (optional (list 5 {address: principal, percentage: uint})))
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
Possible range of `token-id`s for single tokens is `u10000000001` to `u19999999999`

##### Sample clarinet calls
- Token with 2 royalties:
```
(contract-call? 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.main mint-single-token {price: u100, for-sale: true} "ipfs://abcalsjdhf" (some (list {address: 'STFCVYY1RJDNJHST7RRTPACYHVJQDJ7R1DWTQHQA, percentage: u1000} {address: 'STEB8ZW46YZJ40E3P7A287RBJFWPHYNQ2AB5ECT8, percentage: u2000})))
```
- Token with no royalties:
```
(contract-call? 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.main mint-single-token {price: u100, for-sale: true} "ipfs://abcalsjdhf" none)
```
