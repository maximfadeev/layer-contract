import { AppConfig, UserSession, showConnect } from "@stacks/connect";
import {
  uintCV,
  callReadOnlyFunction,
  cvToValue,
  PostConditionMode,
  trueCV,
  falseCV,
} from "@stacks/transactions";
import { StacksTestnet } from "@stacks/network";
import { openContractCall } from "@stacks/connect";
import { principalCV } from "@stacks/transactions/dist/clarity/types/principalCV";

const CONTRACT_ADDRESS = "ST2124A54ZRRE8TCK86RYSSSNNX9QNQHFNA8SQH15";
const CONTRACT_NAME = "fluttering-azure-perch";
const NETWORK = new StacksTestnet();
const appConfig = new AppConfig(["store_write", "publish_data"]);
export const userSession = new UserSession({ appConfig });
const APP_DETAILS = {
  name: "Layer Marketplace",
  icon: window.location.origin + "/my-app-logo.svg",
};

// Royalties samples
const royaltiesNone = noneCV();

const royaltiesOne = someCV(
  listCV([
    tupleCV({
      address: standardPrincipalCV("ST2124A54ZRRE8TCK86RYSSSNNX9QNQHFNA8SQH15"),
      percentage: uintCV(10 * 100),
    }),
  ])
);

const royaltiesFive = someCV(
  listCV([
    tupleCV({
      address: standardPrincipalCV("ST1F98J2790VGHH7K5DJF09E70WQ9HEWA8Q4ZZC26"),
      percentage: uintCV(10 * 100),
    }),
    tupleCV({
      address: standardPrincipalCV("ST9RFCV05741P0BTXD60J2JN8XTMG0RR60W56PXF"),
      percentage: uintCV(20 * 100),
    }),
    tupleCV({
      address: standardPrincipalCV("ST1F98J2790VGHH7K5DJF09E70WQ9HEWA8Q4ZZC26"),
      percentage: uintCV(10 * 100),
    }),
    tupleCV({
      address: standardPrincipalCV("ST9RFCV05741P0BTXD60J2JN8XTMG0RR60W56PXF"),
      percentage: uintCV(20 * 100),
    }),
    tupleCV({
      address: standardPrincipalCV("ST1F98J2790VGHH7K5DJF09E70WQ9HEWA8Q4ZZC26"),
      percentage: uintCV(10 * 100),
    }),
  ])
);

// Mint Single Token
export async function mint_single_token() {
  let data = {};
  data["price"] = uintCV(10 * 1000000);
  data["for-sale"] = trueCV();

  const metadata = stringAsciiCV("ipfs://sample_ipfs_string");
  const functionArgs = [tupleCV(data), metadata, royaltiesOne];

  const options = {
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: "mint-single-token",
    NETWORK,
    functionArgs,
    APP_DETAILS,
  };
  await openContractCall(options);
}

// Mint Collection
export async function mint_collection() {
  let data = {};
  data["price"] = uintCV(4 * 1000000);
  data["for-sale"] = trueCV();

  const files = someCV(
    listCV([
      tupleCV({
        metadata: stringAsciiCV("ipfs://laskdyoq3u4y5rlskjefql4yulkjq4h58sdf8lkjhansdf"),
        data: tupleCV(data),
      }),
      tupleCV({
        metadata: stringAsciiCV("ipfs://laskdyoq3u4y5rlskjefql4yulkjq4h58sdf8lkjhansdf"),
        data: tupleCV(data),
      }),
      tupleCV({
        metadata: stringAsciiCV("ipfs://laskdyoq3u4y5rlskjefql4yulkjq4h58sdf8lkjhansdf"),
        data: tupleCV(data),
      }),
    ])
  ),

  const functionArgs = [files, royaltiesOne];
  // no files, no royalties: [noneCV(), noneCV()]

  const options = {
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: "mint-collection",
    network,
    functionArgs,
    postConditions: [],
    postConditionMode: PostConditionMode.Allow,
    appDetails: APP_DETAILS,
  }
  await openContractCall(options);
}

// Mint to Collection
export async function mint_to_collection(collectionID) {
  let data = {};
  data["price"] = uintCV(4 * 1000000);
  data["for-sale"] = trueCV();

  const metadata = stringAsciiCV("ipfs://sample_ipfs_string");

  let functionArgs = [
    uintCV(collectionID),
    tupleCV(data),
    metadata,
    royaltiesFive,
  ];

  const options = {
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: "mint-to-collection",
    network,
    functionArgs,
    postConditions: [],
    postConditionMode: PostConditionMode.Allow,
    appDetails: APP_DETAILS,
  };
  await openContractCall(options);
}

// Purchase
export async function purchase(tokenID) {
  let functionArgs = [uintCV(tokenID)];

  const options = {
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: "purchase",
    network,
    functionArgs,
    postConditions: [],
    postConditionMode: PostConditionMode.Allow,
    appDetails: APP_DETAILS,
  };
  await openContractCall(options);
}

// transfers NFT from owner to recipient with no transfer of STX
export async function transfer(tokenID, owner, recipient) {
  const options = {
    functionName: "transfer",
    functionArgs: [uintCV(tokenID), standardPrincipalCV(owner), standardPrincipalCV(recipient)],
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    appDetails: APP_DETAILS,
    network: NETWORK,
    postConditionMode: PostConditionMode.Allow,
    postConditions: [],
  };
  await openContractCall(options);
}

// set price information for an NFT
export async function set_price_data(tokenID, price, isForSale) {
  const options = {
    functionName: "set-price-data",
    functionArgs: [uintCV(tokenID), uintCV(price), isForSale ? trueCV() : falseCV()],
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    network: NETWORK,
    appDetails: APP_DETAILS,
    postConditionMode: PostConditionMode.Allow,
    postConditions: [],
  };
  await openContractCall(options);
}

// Complete sale. Used for Layer's USD and auction flows. Only callable by admin
export async function complete_sale(tokenID, newOwnerAddress, oldOwnerAddres, tokenPrice) {
  const options = {
    functionName: "complete_sale",
    functionArgs: [uintCV(tokenID), standardPrincipalCV(newOwnerAddress), standardPrincipalCV(oldOwnerAddres), uintCV(tokenPrice)],
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    network: NETWORK,
    appDetails: APP_DETAILS,
    postConditionMode: PostConditionMode.Allow,
    postConditions: [],
  };
  await openContractCall(options);
}

// Read only function (no fee to call) that retrieves all data for an NFT
export function get_all_token_data(tokenID) {
  const options = {
    functionName: "get-all-token-data",
    functionArgs: [uintCV(tokenID)],
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    network: NETWORK,
    senderAddress: "ST248HH800501WYSG7Z2SS1ZWHQW1GGH85Q6YJBCC",
  };
  return callReadOnlyFunction(options);
}

// Read only function that retrieves info for a collection 
export function get_collection_data(collectionID) {
  const options = {
    functionName: "get-collection-data",
    functionArgs: [uintCV(collectionID)],
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    network: NETWORK,
    senderAddress: "ST248HH800501WYSG7Z2SS1ZWHQW1GGH85Q6YJBCC",
  };
  return callReadOnlyFunction(options);
}







