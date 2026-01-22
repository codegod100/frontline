# Frontline

A Zig/WASM frontend framework with Svelte-like compile-time reactivity.

## Architecture

- **src/js_interop.zig**: JavaScript interop layer for DOM manipulation
- **src/signals.zig**: Reactive state system with signals and computed values
- **src/vdom.zig**: Virtual DOM with diffing for efficient updates
- **src/component.zig**: Component system with state management
- **src/app.zig**: Example counter application

## Building

```bash
zig build
```

This compiles Zig code to WebAssembly (wasm32-freestanding target).

## Running

```bash
deno run --allow-net --allow-read serve.js
```

Then open http://localhost:8000

## Example Usage

```zig
// Create a component with render function
fn renderCounter(comp: *Component, allocator: std.mem.Allocator) !*VNode {
    const count = comp.getState(i32, "count");
    
    const container = try VNode.createElement(allocator, "div");
    const text = try VNode.createText(allocator, "Count: ");
    
    try container.appendChild(text);
    return container;
}

// Initialize component with state
counter_component = Component.init(allocator, renderCounter) catch return;
counter_component.createState(i32, "count", 0) catch return;

// Update state and trigger re-render
counter_component.setState(i32, "count", new_value);
```

## Features

- Svelte-like compile-time reactivity
- Minimal runtime (runs in WASM)
- Virtual DOM with efficient diffing
- Signal-based state management
- Direct DOM manipulation via JS interop
