import { initWasm } from "./wasm-loader.js";

initWasm({ wasmPath: "./zig-out/bin/main.wasm" });
