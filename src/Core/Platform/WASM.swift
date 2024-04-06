
#if arch(wasm32)

// Available JS functions
@_silgen_name("draw")
fileprivate func draw(buf: UnsafePointer<Color>)
@_silgen_name("panicHandler")
fileprivate func panicHandler(string: UnsafePointer<CChar>, count: Int) -> Never
@_silgen_name("random")
fileprivate func random() -> Float
@_silgen_name("setDisplaySize")
fileprivate func setDisplaySize(w: Int, h: Int)

public extension Game {
    static func main() {
        setDisplaySize(w: Self.size.width, h: self.size.height)
    }
}

fileprivate let image = Image(width: 128, height: 128, color: .red)

@_cdecl("frame")
internal func __frame() {
    draw(buf: image.data)
}

#endif

// TODO(!!!!): Get rid of this atrocious spaghetti entry point somehow.
#if arch(wasm32)
@_cdecl("main")
public func __main() {
    Main.main()
}
#endif
