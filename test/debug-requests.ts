// Minimal debug: test what the SDK actually sends
const MVLITE_URL = "http://127.0.0.1:8090";

async function main() {
  // Test 1: raw fetch to /v1 (like curl)
  console.log("=== Raw fetch /v1 ===");
  try {
    const r1 = await fetch(`${MVLITE_URL}/v1`);
    console.log(`Status: ${r1.status}, Body length: ${(await r1.text()).length}`);
  } catch (e: any) { console.log(`Error: ${e.message}`); }

  // Test 2: raw fetch to /v1/ (with slash)
  console.log("=== Raw fetch /v1/ ===");
  try {
    const r2 = await fetch(`${MVLITE_URL}/v1/`);
    console.log(`Status: ${r2.status}, Body length: ${(await r2.text()).length}`);
  } catch (e: any) { console.log(`Error: ${e.message}`); }

  // Test 3: SDK getLedgerInfo — what URL does it actually call?
  const { Aptos, AptosConfig, Network } = await import("@aptos-labs/ts-sdk");
  
  // Try with /v1 in the URL
  console.log("\n=== SDK with fullnode = MVLITE_URL/v1 ===");
  try {
    const config1 = new AptosConfig({ network: Network.CUSTOM, fullnode: `${MVLITE_URL}/v1` });
    const aptos1 = new Aptos(config1);
    const info1 = await aptos1.getLedgerInfo();
    console.log(`OK: chain_id=${info1.chain_id}`);
  } catch (e: any) { console.log(`Error: ${e.message}`); }

  // Try WITHOUT /v1 in the URL
  console.log("\n=== SDK with fullnode = MVLITE_URL (no /v1) ===");
  try {
    const config2 = new AptosConfig({ network: Network.CUSTOM, fullnode: MVLITE_URL });
    const aptos2 = new Aptos(config2);
    const info2 = await aptos2.getLedgerInfo();
    console.log(`OK: chain_id=${info2.chain_id}`);
  } catch (e: any) { console.log(`Error: ${e.message}`); }
}

main();
