# Standalone Swift Game

This is an example minimal dependency Swift program taking advantage of the new
experimental embedded mode.

The dependencies are:

Web:
- Nothing at all, just a web browser with WebGL and WASM support.

Windows/Mac/Linux:
- SDL2

It's intended to be built with `make`, but I am trying to get it working
as a Swift package to get sourcekit-lsp support.
