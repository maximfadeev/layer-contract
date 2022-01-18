(impl-trait 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE.nft-trait.nft-trait)
(define-non-fungible-token Layer-NFT uint)
(define-data-var last-token-id uint u10000000000)
(define-data-var last-collection-id uint u200000)
(define-data-var admin-fee uint u1000)
(define-map token-data {token-id: uint} {price: uint, for-sale: bool})
(define-map token-metadata {token-id: uint} (string-ascii 256))
(define-map token-royalties {token-id: uint} {royalties: (list 6 {address: principal, percentage: uint}), owner-percentage: uint})
(define-map collection-data {collection-id: uint} {last-file-id: uint, owner: principal})
(define-data-var admin principal 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)

;; ERROR CODES
(define-constant ERR-INSUFFICIENT-STX (err u975))
(define-constant ERR-TOKEN-NOT-FOR-SALE (err u976))
(define-constant ERR-ROYALTIES-TOTAL-OVERFLOW (err u977))
(define-constant ERR-NOT-AUTHORIZED (err u978))
(define-constant ERR-COULD-NOT-CALCULATE-ROYALTY-DATA (err u979))
(define-constant ERR-FAILED-TO-MINT-TO-COLLECTION (err u980))
(define-constant ERR-COLLECTION-DOES-NOT-EXIST (err u981))
(define-constant ERR-FAILED-TO-CALCULATE-ROYALTIES (err u982))
(define-constant ERR-PURCHASE-FAILED (err u983))
(define-constant ERR-PURCHASE-NFT-TRANSFER-FAILED (err u984))
(define-constant ERR-TOKEN-OWNER-FAILED-TO-UNWRWAP (err u985))
(define-constant ERR-DATA-FAILED-TO-UNWRAP (err u986))
(define-constant ERR-PAY-ROYALTIES-DATA-FAILED (err u987))
(define-constant ERR-NO-PRICE-RES (err u989))
(define-constant ERR-FAILED-TO-GET-COLLECTION-INFO (err u992))
(define-constant ERR-FAILED-TO-TRANSFER-TOKEN (err u994))
(define-constant ERR-FAILED-TO-SET-TOKEN-DATA (err u995))
(define-constant ERR-TOKEN-METADATA-NOT-SET (err u996))
(define-constant ERR-TOKEN-ID-NOT-SET (err u997))
(define-constant ERR-ROYALTIES-NOT-SET (err u998))
(define-constant ERR-GETTING-NFT-OWNER (err u999))
(define-constant ERR-COULD-NOT-GET-TOKEN-URI (err u1000))

(define-private (mint-token (token-id uint) (data {price: uint, for-sale: bool}) (metadata (string-ascii 256)) (royalty-data {royalties: (list 6 {address: principal, percentage: uint}), owner-percentage: uint}))
  (begin 
    (try! (nft-mint? Layer-NFT token-id tx-sender))
    (map-insert token-data {token-id: token-id} data)
    (map-insert token-metadata {token-id: token-id} metadata)
    (map-insert token-royalties {token-id: token-id} royalty-data)
    (ok token-id)
  )
)

(define-public (mint-single-token (data {price: uint, for-sale: bool}) (metadata (string-ascii 256)) (royalties (optional (list 5 {address: principal, percentage: uint}))))
  (let
    (
      (royalty-data (unwrap! (calculate-royalty-data royalties) ERR-COULD-NOT-CALCULATE-ROYALTY-DATA))
      (token-id (+ u1 (var-get last-token-id)))
    )
    (try! (mint-token token-id data metadata royalty-data))
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (mint-collection (files (optional (list 100 {metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))}))))
  (let
    (
      (collection-id (+ u1 (var-get last-collection-id)))
      (first-token-id (* collection-id u100000))
      (last-file-id (fold mint-collection-nft-helper (default-to (list ) files) first-token-id))
    )
    (map-set collection-data {collection-id: collection-id} {last-file-id: last-file-id, owner: tx-sender})
    (var-set last-collection-id collection-id)
    (ok collection-id)
  )
)

(define-private (mint-collection-nft-helper (file {metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))}) (token-id uint)) 
  (if (is-ok (mint-token (+ u1 token-id) (get data file) (get metadata file) (unwrap! (calculate-royalty-data (get royalties file)) u1)))
    (+ u1 token-id)
    token-id
  )
)

(define-public (mint-to-collection (collection-id uint) (files (list 100 {metadata: (string-ascii 256), data: {price: uint, for-sale: bool}, royalties: (optional (list 5 {address: principal, percentage: uint}))})))
  (let
    (
      (collection-info (unwrap! (map-get? collection-data {collection-id: collection-id}) ERR-COLLECTION-DOES-NOT-EXIST))
      (token-id (get last-file-id collection-info))
      (collection-owner (get owner collection-info))
      (last-file-id (fold mint-collection-nft-helper files token-id))
    )
    (asserts! (is-eq tx-sender collection-owner) ERR-NOT-AUTHORIZED)
    (map-set collection-data {collection-id: collection-id} {owner: collection-owner, last-file-id: last-file-id})
    (ok last-file-id)
  )
)

(define-private (calculate-total-royalties-percentage-helper (royalty {address: principal, percentage: uint}) (running-percentage uint))
  (+ running-percentage (get percentage royalty))
)

(define-private (calculate-royalty-data (royalties (optional (list 5 {address: principal, percentage: uint}))))
  (let
    (
      (all-royalties (concat (list {address: (var-get admin), percentage: (var-get admin-fee)}) (default-to (list ) royalties)))
      (total-royalties-percentage (fold calculate-total-royalties-percentage-helper all-royalties u0))
      (owner-percentage (- u10000 total-royalties-percentage))
    )
    (asserts! (<= total-royalties-percentage u10000) ERR-ROYALTIES-TOTAL-OVERFLOW)
    (ok {royalties: all-royalties, owner-percentage: owner-percentage})
  )
)

(define-public (purchase (token-id uint))
  (let 
    (
      (data (unwrap! (map-get? token-data { token-id: token-id }) ERR-DATA-FAILED-TO-UNWRAP))
      (is-token-for-sale (get for-sale data))
      (token-price (get price data))
      (token-owner (unwrap! (nft-get-owner? Layer-NFT token-id) ERR-TOKEN-OWNER-FAILED-TO-UNWRWAP))
    )
    (asserts! is-token-for-sale ERR-TOKEN-NOT-FOR-SALE)
    (asserts! (>= (stx-get-balance tx-sender) token-price) ERR-INSUFFICIENT-STX)
    (try! (pay token-id token-price token-owner))
    (try! (nft-transfer? Layer-NFT token-id token-owner tx-sender))
    (ok (map-set token-data { token-id: token-id } {for-sale: false, price: token-price}))
  )
)

(define-public (pay (token-id uint) (price uint) (owner-address principal))
  (let
    (
      (royalties-data (unwrap! (map-get? token-royalties {token-id: token-id}) ERR-PAY-ROYALTIES-DATA-FAILED))
      (royalties (get royalties royalties-data))
      (owner-percentage (get owner-percentage royalties-data))
      (royalties-with-owner-share (append royalties {percentage: owner-percentage, address: owner-address}))
    )
    (fold pay-percentage royalties-with-owner-share (ok price))
  )
)

(define-private (pay-percentage (royalty {percentage: uint, address: principal}) (price-res (response uint uint)))
  (let 
    (
      (price (unwrap! price-res ERR-NO-PRICE-RES))
      (stx-to-pay (/ (* price (get percentage royalty)) u10000))
    )
    (try! (stx-transfer? stx-to-pay tx-sender (get address royalty)))
    (ok price)
  )
)

(define-public (complete-sale (token-id uint) (new-owner-address principal) (old-owner-address principal) (token-price uint))
  (begin 
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (ok (try! (nft-transfer? Layer-NFT token-id old-owner-address new-owner-address)))
  )
)

(define-public (set-token-price-data (token-id uint) (price uint) (for-sale bool))
  (begin 
    (asserts! (is-eq (some tx-sender) (nft-get-owner? Layer-NFT token-id)) ERR-NOT-AUTHORIZED)
    (ok (map-set token-data {token-id: token-id} {price: price, for-sale: for-sale}))
  )
)

(define-public (change-collection-owner (collection-id uint) (new-owner principal))
  (let ((collection-info (unwrap! (map-get? collection-data {collection-id: collection-id}) ERR-FAILED-TO-GET-COLLECTION-INFO)))
    (asserts! (is-eq tx-sender (get owner collection-info)) ERR-NOT-AUTHORIZED)
    (ok (map-set collection-data {collection-id: collection-id} {owner: new-owner, last-file-id: (get last-file-id collection-info)}))
  )
)

(define-public (set-admin-fee (fee uint))
  (begin 
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (ok (var-set admin-fee fee))
  )
)

(define-public (change-admin (new-admin principal))
  (begin 
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (ok (var-set admin new-admin))
  )
)

(define-public (validate-auth (challenge-token (string-ascii 500))) (ok true))

(define-public (transfer (token-id uint) (owner principal) (recipient principal))
  (begin 
    (asserts! (is-eq (some tx-sender) (nft-get-owner? Layer-NFT token-id)) ERR-NOT-AUTHORIZED)
    (try! (nft-transfer? Layer-NFT token-id owner recipient))
    (ok (map-set token-data {token-id: token-id} (merge (unwrap! (map-get? token-data {token-id: token-id}) ERR-FAILED-TO-SET-TOKEN-DATA) {for-sale: false})))
  )
)

(define-read-only (get-all-token-data (token-id uint))
  (ok {
      token-id: token-id,
      token-metadata: (unwrap! (map-get? token-metadata {token-id: token-id}) ERR-TOKEN-METADATA-NOT-SET),
      token-data: (unwrap! (map-get? token-data {token-id: token-id}) ERR-TOKEN-ID-NOT-SET),
      token-royalties: (unwrap! (map-get? token-royalties {token-id: token-id}) ERR-ROYALTIES-NOT-SET),
      token-owner: (unwrap! (nft-get-owner? Layer-NFT token-id) ERR-GETTING-NFT-OWNER),
    })
)

(define-read-only (get-collection-data (collection-id uint))
  (map-get? collection-data {collection-id: collection-id}))
  
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? Layer-NFT token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (unwrap! (map-get? token-metadata { token-id: token-id }) ERR-COULD-NOT-GET-TOKEN-URI)))
)