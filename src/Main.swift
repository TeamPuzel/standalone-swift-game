
#if arch(wasm32)
@_cdecl("main")
public func __main() {
    Main.main()
}
#endif

@main
struct Main: Game {
    mutating func update() {
        
    }
    
    mutating func frame(renderer: inout Renderer) {
        renderer.clear(with: .red)
        renderer.pixel(x: 1, y: 1)
    }
}
