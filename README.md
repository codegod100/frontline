# Frontline

A Zig/WebAssembly frontend framework with Svelte-like reactivity.

## Architecture

- **lib/vdom.zig**: Virtual DOM with diffing for efficient updates
- **lib/js_interop.zig**: JavaScript interop layer for DOM manipulation
- **lib/signals.zig**: Reactive state system with signals and computed values
- **lib/component.zig**: Component system with state management

## Building the Library

```bash
zig build
```

This creates the static library in `zig-out/lib/`.

## Examples

### Simple Counter
A basic counter component demonstrating reactive state.

```bash
cd examples/simple-counter
zig build
python3 -m http.server 8000
```
Open `http://localhost:8000` in your browser.

Or serve with a simple HTTP server of your choice.

### Landing Page
Shows off the framework's capabilities and features.

```bash
cd examples/landing-page
zig build
python3 -m http.server 8000
```
Open `http://localhost:8000` in your browser.

### Composition Demo
Demonstrates multiple independent components working together.

```bash
cd examples/composition-demo
zig build
python3 -m http.server 8000
```
Open `http://localhost:8000` in your browser.

## Example Usage

```zig
const frontline = @import("../../lib");
const ui = frontline.ui;

var counter_component: ?*frontline.Component = null;

fn renderCounter(comp: *frontline.Component, allocator: std.mem.Allocator) !*frontline.VNode {
    const count = frontline.Component.getState(i32, comp, "count");

    var buf: [32]u8 = undefined;
    const count_str = std.fmt.bufPrint(&buf, "{d}", .{count}) catch "0";

    return ui.build(allocator, ui.node("div", &.{}, &.{
        ui.text("Count: "),
        ui.span(&.{}, &.{ ui.text(count_str) }),
    }));
}

export fn incrementCount() void {
    if (counter_component) |comp| {
        const count = frontline.Component.getState(i32, comp, "count");
        frontline.Component.setState(i32, comp, "count", count + 1);
    }
}

export fn run() void {
    const allocator = std.heap.wasm_allocator;
    
    counter_component = frontline.Component.init(allocator, renderCounter) catch return;
    if (counter_component) |comp| {
        frontline.Component.createState(i32, comp, "count", 0) catch return;
        
        const root = renderCounter(comp, allocator) catch return;
        root.mount(0);
        comp.root = root;
    }
}
```

## Example Usage

```zig
// Create a component with the UI DSL
fn renderCounter(comp: *Component, allocator: std.mem.Allocator) !*VNode {
    const count = comp.getState(i32, "count");

    var buf: [32]u8 = undefined;
    const count_str = std.fmt.bufPrint(&buf, "{d}", .{count}) catch "0";

    return ui.build(allocator, ui.node("div", &.{}, &.{
        ui.text("Count: "),
        ui.span(&.{}, &.{ ui.text(count_str) }),
    }));
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
