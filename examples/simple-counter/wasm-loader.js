const decoder = new TextDecoder("utf-8");

export async function initWasm(options = {}) {
    const { wasmPath, rootId = "app" } = options;
    if (!wasmPath) {
        throw new Error("wasmPath is required");
    }

    const root = document.getElementById(rootId);
    if (!root) {
        throw new Error(`Missing root element #${rootId}`);
    }

    const nodes = new Map();
    nodes.set(0, root);

    let wasm = null;

    function readString(ptr, len) {
        const mem = wasm.exports.memory;
        const bytes = new Uint8Array(mem.buffer, ptr, len);
        return decoder.decode(bytes);
    }

    const imports = {
        js: {
            js_createElement: (tag_ptr, tag_len, node_id) => {
                const tag = readString(tag_ptr, tag_len);
                const el = document.createElement(tag);
                nodes.set(node_id, el);
                return node_id;
            },
            js_setAttribute: (el_id, name_ptr, name_len, value_ptr, value_len) => {
                const el = nodes.get(el_id);
                if (!el) return;
                const name = readString(name_ptr, name_len);
                const value = readString(value_ptr, value_len);
                el.setAttribute(name, value);
            },
            js_setTextContent: (el_id, text_ptr, text_len) => {
                const el = nodes.get(el_id);
                if (!el) return;
                const text = readString(text_ptr, text_len);
                el.textContent = text;
            },
            js_appendChild: (parent_id, child_id) => {
                const parent = nodes.get(parent_id) || root;
                const child = nodes.get(child_id);
                if (parent && child) parent.appendChild(child);
            },
            js_removeChild: (parent_id, child_id) => {
                const parent = nodes.get(parent_id) || root;
                const child = nodes.get(child_id);
                if (parent && child) parent.removeChild(child);
            },
            js_replaceChild: (parent_id, new_id, old_id) => {
                const parent = nodes.get(parent_id) || root;
                const new_node = nodes.get(new_id);
                const old_node = nodes.get(old_id);
                if (parent && new_node && old_node) parent.replaceChild(new_node, old_node);
            },
        },
    };

    const wasmUrl = new URL(wasmPath, import.meta.url);
    const response = await fetch(wasmUrl);
    const bytes = await response.arrayBuffer();
    const result = await WebAssembly.instantiate(bytes, imports);
    wasm = result.instance;

    window.wasmModule = wasm;
    if (typeof wasm.exports.run === "function") {
        wasm.exports.run();
    }
}
