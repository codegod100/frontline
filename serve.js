import { serve } from 'https://deno.land/std@0.200.0/http/server.ts';

serve(async (req) => {
    const url = new URL(req.url);
    
    if (url.pathname === '/') {
        const html = await Deno.readTextFile('./index.html');
        return new Response(html, {
            headers: { 'content-type': 'text/html' },
        });
    }
    
    if (url.pathname === '/zig-out/bin/frontend-framework.wasm') {
        const wasm = await Deno.readFile('./zig-out/bin/frontend-framework.wasm');
        return new Response(wasm, {
            headers: { 'content-type': 'application/wasm' },
        });
    }
    
    return new Response('Not found', { status: 404 });
}, { port: 8000 });

console.log('Server running on http://localhost:8000');
