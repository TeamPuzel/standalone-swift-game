
// MARK: - Shared

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

// MARK: - WASM

#if arch(wasm32)

// Available JS functions
@_silgen_name("draw") fileprivate func draw(buf: UnsafePointer<Color>)
@_silgen_name("panicHandler") fileprivate func panicHandler(string: UnsafePointer<CChar>, count: Int) -> Never
@_silgen_name("random") fileprivate func random() -> Float

extension Game {
    static func main() {
        
    }
}

let image = Image(width: 128, height: 128, color: .red)

@_cdecl("frame")
public func __frame() {
    draw(buf: image.data)
}

@_cdecl("displayWidth")
public func __displayWidth() -> Int { 128 }

@_cdecl("displayHeight")
public func __displayHeight() -> Int { 128 }

#endif

// MARK: - SDL

#if canImport(SDL)

import SDL

extension Game {
    static func main() throws(SDLError) {
        guard SDL_Init(SDL_INIT_VIDEO) == 0 else {
            throw SDLError.initializingSDL
        }
        defer { SDL_Quit() }
        
        let windowWidth = self.size.width * 4
        let windowHeight = self.size.height * 4
        
        guard let window = SDL_CreateWindow(
            CString("Test").buffer,
            Int32(SDL_WINDOWPOS_CENTERED_MASK),
            Int32(SDL_WINDOWPOS_CENTERED_MASK),
            Int32(windowWidth), Int32(windowHeight),
            SDL_WINDOW_ALLOW_HIGHDPI.rawValue //|
            //SDL_WINDOW_RESIZABLE.rawValue
        ) else { throw SDLError.creatingWindow }
        defer { SDL_DestroyWindow(window) }
        //SDL_SetWindowMinimumSize(window, windowWidth, windowHeight)
        
        guard let renderer = SDL_CreateRenderer(
            window, -1,
            SDL_RENDERER_ACCELERATED.rawValue |
            SDL_RENDERER_PRESENTVSYNC.rawValue
        ) else { throw SDLError.creatingRenderer }
        defer { SDL_DestroyRenderer(renderer) }
        
        var game = Self()
        var target = Renderer(width: self.size.width, height: self.size.height)
        
        guard let texture = SDL_CreateTexture(
            renderer,
            SDL_PIXELFORMAT_RGBA32.rawValue,
            Int32(SDL_TEXTUREACCESS_STREAMING.rawValue),
            Int32(target.display.width), Int32(target.display.height)
        ) else { throw SDLError.creatingTexture }
        defer { SDL_DestroyTexture(texture) }
        
        SDL_UpdateTexture(
            texture, nil,target.display.data,
            Int32(target.display.width * MemoryLayout<Color>.stride)
        )
        
        var windowPixelWidth: Int32 = 0
        var windowPixelHeight: Int32 = 0
        SDL_GetWindowSizeInPixels(window, &windowPixelWidth, &windowPixelHeight)
        
        var displayRect = SDL_Rect(x: 0, y: 0, w: windowPixelWidth, h: windowPixelHeight)
        
        var event = SDL_Event()
        loop: while true {
            while SDL_PollEvent(&event) > 0 {
                switch event.type {
                    case SDL_QUIT.rawValue: break loop
                    case _: break
                }
            }
            SDL_RenderClear(renderer)
            game.update() // TODO(!!!): This needs to run at a fixed rate, not vsync
            game.frame(renderer: &target)
            
            SDL_UpdateTexture(
                texture, nil, target.display.data,
                Int32(target.display.width * MemoryLayout<Color>.stride)
            )
            SDL_RenderCopy(renderer, texture, nil, &displayRect)
            
            SDL_RenderPresent(renderer)
        }
    }
}

enum SDLError: Error {
    case initializingSDL
    case creatingWindow
    case creatingRenderer
    case creatingTexture
}

fileprivate extension Key {
    var scancode: SDL_Scancode? {
        return switch self {
            case .a: SDL_SCANCODE_A
            case .b: SDL_SCANCODE_B
            case .c: SDL_SCANCODE_C
            case .d: SDL_SCANCODE_D
            case .e: SDL_SCANCODE_E
            case .f: SDL_SCANCODE_F
            case .g: SDL_SCANCODE_G
            case .h: SDL_SCANCODE_H
            case .i: SDL_SCANCODE_I
            case .j: SDL_SCANCODE_J
            case .k: SDL_SCANCODE_K
            case .l: SDL_SCANCODE_L
            case .m: SDL_SCANCODE_M
            case .n: SDL_SCANCODE_N
            case .o: SDL_SCANCODE_O
            case .p: SDL_SCANCODE_P
            case .q: SDL_SCANCODE_Q
            case .r: SDL_SCANCODE_R
            case .s: SDL_SCANCODE_S
            case .t: SDL_SCANCODE_T
            case .u: SDL_SCANCODE_U
            case .v: SDL_SCANCODE_V
            case .w: SDL_SCANCODE_W
            case .x: SDL_SCANCODE_X
            case .y: SDL_SCANCODE_Y
            case .z: SDL_SCANCODE_Z
            case .num1: SDL_SCANCODE_1
            case .num2: SDL_SCANCODE_2
            case .num3: SDL_SCANCODE_3
            case .num4: SDL_SCANCODE_4
            case .num5: SDL_SCANCODE_5
            case .num6: SDL_SCANCODE_6
            case .num7: SDL_SCANCODE_7
            case .num8: SDL_SCANCODE_8
            case .num9: SDL_SCANCODE_9
            case .num0: SDL_SCANCODE_0
            case .space: SDL_SCANCODE_SPACE
            case _: nil
        }
    }
}

fileprivate func closestSize(for software: Int, fitting native: Int) -> Int {
    max(software * (native / software), software);
}

fileprivate func getRectFittingDisplay(width: Int, height: Int) -> SDL_Rect {
    let closestWidth = closestSize(for: 480, fitting: width);
    let closestHeight = closestWidth * 270 / 480
    var rect = SDL_Rect(
        x: Int32((width - closestWidth) / 2),
        y: Int32((height - closestHeight / 2)),
        w: Int32(closestWidth),
        h: Int32(closestHeight)
    )

    if (rect.h > height) {
        let closestHeight = closestSize(for: 270, fitting: height)
        let closestWidth = closestHeight * 480 / 270;
        rect = SDL_Rect(
            x: Int32((width - closestWidth) / 2),
            y: Int32((height - closestHeight / 2)),
            w: Int32(closestWidth),
            h: Int32(closestHeight)
        )
        rect.y = Int32((height - closestHeight) / 2);
        rect.h = Int32(closestHeight);
        rect.x = Int32((width - closestWidth) / 2);
        rect.w = Int32(width);
    }
    
    return rect
}

#endif
