
/// A target independent game which can be run by a runtime for any platform.
public protocol Game {
    init()
    /// Called reliably every tick.
    mutating func update()
    /// Called every frame, does not guarantee vsync can be skipped.
    mutating func frame(renderer: inout Renderer)
    
    static var size: (width: Int, height: Int) { get }
    static var updatesPerSecond: Int { get }
}

public extension Game {
    mutating func update() {}
    mutating func frame(renderer: inout Renderer) {}
    
    static var size: (width: Int, height: Int) { (128, 128) }
    static var updatesPerSecond: Int { 60 }
}
