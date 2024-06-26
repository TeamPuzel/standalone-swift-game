
public struct Color: Equatable {
    public let r, g, b, a: UInt8
    
    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    public init(luminance: UInt8, a: UInt8 = 255) {
        self.r = luminance
        self.g = luminance
        self.b = luminance
        self.a = a
    }
    
    public static let clear = Color(r: 0, g: 0, b: 0, a: 0)
    
    public static let black      = Pico.black
    public static let darkBlue   = Pico.darkBlue
    public static let darkPurple = Pico.darkPurple
    public static let darkGreen  = Pico.darkGreen
    public static let brown      = Pico.brown
    public static let darkGray   = Pico.darkGray
    public static let lightGray  = Pico.lightGray
    public static let white      = Pico.white
    public static let red        = Pico.red
    public static let orange     = Pico.orange
    public static let yellow     = Pico.yellow
    public static let green      = Pico.green
    public static let blue       = Pico.blue
    public static let lavender   = Pico.lavender
    public static let pink       = Pico.pink
    public static let peach      = Pico.peach
}

public extension Color {
    enum Strawberry {
        public static let red    = Color(r: 214, g: 95,  b: 118)
        public static let banana = Color(r: 230, g: 192, b: 130)
        public static let apple  = Color(r: 205, g: 220, b: 146)
        public static let lime   = Color(r: 177, g: 219, b: 159)
        public static let sky    = Color(r: 129, g: 171, b: 201)
        public static let lemon  = Color(r: 240, g: 202, b: 101)
        public static let orange = Color(r: 227, g: 140, b: 113)
        
        public static let white = Color(r: 224, g: 224, b: 224)
        public static let light = Color(r: 128, g: 128, b: 128)
        public static let gray  = Color(r: 59,  g: 59,  b: 59 )
        public static let dark  = Color(r: 28,  g: 28,  b: 28 )
        public static let black = Color(r: 15,  g: 15,  b: 15 )
    }
    
    enum Pico {
        public static let black      = Color(r: 0,   g: 0,   b: 0  )
        public static let darkBlue   = Color(r: 29,  g: 43,  b: 83 )
        public static let darkPurple = Color(r: 126, g: 37,  b: 83 )
        public static let darkGreen  = Color(r: 0,   g: 135, b: 81 )
        public static let brown      = Color(r: 171, g: 82,  b: 53 )
        public static let darkGray   = Color(r: 95,  g: 87,  b: 79 )
        public static let lightGray  = Color(r: 194, g: 195, b: 199)
        public static let white      = Color(r: 255, g: 241, b: 232)
        public static let red        = Color(r: 255, g: 0,   b: 77 )
        public static let orange     = Color(r: 255, g: 163, b: 0  )
        public static let yellow     = Color(r: 255, g: 236, b: 39 )
        public static let green      = Color(r: 0,   g: 228, b: 54 )
        public static let blue       = Color(r: 41,  g: 173, b: 255)
        public static let lavender   = Color(r: 131, g: 118, b: 156)
        public static let pink       = Color(r: 255, g: 119, b: 168)
        public static let peach      = Color(r: 255, g: 204, b: 170)
    }
    
    enum UI {
        // CONSDERATION: Automatic theme?
    }
}

extension Color {
    public static func + (lhs: Color, rhs: Color) -> Color {
        .init(r: lhs.r + rhs.r, g: lhs.g + rhs.g, b: lhs.b + rhs.b)
    }
    public static func - (lhs: Color, rhs: Color) -> Color {
        .init(r: lhs.r - rhs.r, g: lhs.g - rhs.g, b: lhs.b - rhs.b)
    }
    public static func + (lhs: Color, rhs: UInt8) -> Color {
        .init(r: lhs.r + rhs, g: lhs.g + rhs, b: lhs.b + rhs)
    }
    public static func - (lhs: Color, rhs: UInt8) -> Color {
        .init(r: lhs.r - rhs, g: lhs.g - rhs, b: lhs.b - rhs)
    }
}
