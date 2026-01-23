import { initWasm } from "./wasm-loader.js";

const params = new URL(import.meta.url).searchParams;
const wasmParam = params.get("wasm") || "./zig-out/bin/main.wasm";
const wasmUrl = new URL(wasmParam, document.baseURI).href;

initWasm({ wasmPath: wasmUrl });
