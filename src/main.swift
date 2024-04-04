
import SDL

@main
struct Main {
    static func main() throws(Error) {
        guard SDL_Init(SDL_INIT_VIDEO) == 0 else {
            throw Error.initializingSDL
        }
        defer { SDL_Quit() }
        
        guard let window = SDL_CreateWindow(
            nil,
            Int32(SDL_WINDOWPOS_CENTERED_MASK),
            Int32(SDL_WINDOWPOS_CENTERED_MASK),
            800, 600,
            SDL_WINDOW_ALLOW_HIGHDPI.rawValue |
            SDL_WINDOW_RESIZABLE.rawValue
        ) else { throw Error.creatingWindow }
        defer { SDL_DestroyWindow(window) }
        SDL_SetWindowMinimumSize(window, 800, 600)
        
        guard let renderer = SDL_CreateRenderer(
            window, -1,
            SDL_RENDERER_ACCELERATED.rawValue |
            SDL_RENDERER_PRESENTVSYNC.rawValue
        ) else { throw Error.creatingRenderer }
        defer { SDL_DestroyRenderer(renderer) }
        
        var event = SDL_Event()
        loop: while true {
            while SDL_PollEvent(&event) > 0 {
                switch event.type {
                    case SDL_QUIT.rawValue: break loop
                    case _: break
                }
            }
            SDL_RenderClear(renderer)
            SDL_RenderPresent(renderer)
        }
    }
    
    enum Error: Swift.Error {
        case initializingSDL
        case creatingWindow
        case creatingRenderer
    }
}
