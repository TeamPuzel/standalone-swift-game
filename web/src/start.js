
window.addEventListener("load", main)

/** @type WebAssembly.WebAssemblyInstantiatedSource */
let wasm
/** @type WebGLRenderingContext | null */
let context = null
/** @type WebGLTexture | null */
let displayTexture = null

/** @type number */
let displayWidth = 0
/** @type number */
let displayHeight = 0

/** 
 * @param { string } code
 * @returns { number | null }
  */
function parseKey(code) {
    // console.log(code)
    switch (code) {
        case "KeyW": return 0
        case "ArrowUp": return 0
        
        case "KeyA": return 1
        case "ArrowLeft": return 1
        
        case "KeyS": return 2
        case "ArrowDown": return 2
        
        case "KeyD": return 3
        case "ArrowRight": return 3
        
        case "Comma": return 4
        case "Period": return 5
        default: return null
    }
}

async function main() {
    wasm = await WebAssembly.instantiateStreaming(
        fetch("/game.wasm"),
        { env }
    )
    
    wasm.instance.exports.main()
    
    displayWidth = wasm.instance.exports.displayWidth()
    displayHeight = wasm.instance.exports.displayHeight()
    
    window.addEventListener("keydown", (e) => {
        if (parseKey(e.code) != null)
            wasm.instance.exports.key_down(parseKey(e.code))
    })
    
    window.addEventListener("keyup", (e) => {
        if (parseKey(e.code) != null)
            wasm.instance.exports.key_up(parseKey(e.code))
    })
    
    await run()
}

async function run() {
    /** @type HTMLCanvasElement */
    const surface = document.getElementById("surface")
    surface.width = displayWidth * 8
    surface.height = displayHeight * 8
    surface.style.width = displayWidth * 4 + "px"
    surface.style.height = displayHeight * 4 + "px"
    
    context = surface.getContext("webgl")
    if (!context) { console.error("Could not create context."); return }
    
    context.clearColor(0, 0, 0, 1)
    context.clear(context.COLOR_BUFFER_BIT)
    
    const shader = createShader(context)
    
    // Coordinates
    
    const testRectangle = [
        -1.0, -1.0,    0, 1,
        -1.0,  1.0,    0, 0,
         1.0, -1.0,    1, 1,
        
         1.0, -1.0,    1, 1,
        -1.0,  1.0,    0, 0,
         1.0,  1.0,    1, 0
    ]
    
    const buf = context.createBuffer()
    context.bindBuffer(context.ARRAY_BUFFER, buf)
    context.bufferData(
        context.ARRAY_BUFFER,
        new Float32Array(testRectangle),
        context.STATIC_DRAW
    )
    
    const v_position = context.getAttribLocation(shader, "v_position")
    const v_texCoord = context.getAttribLocation(shader, "v_texCoord")
    
    context.vertexAttribPointer(v_position, 2, context.FLOAT, false, 16, 0)
    context.enableVertexAttribArray(v_position)
    
    context.vertexAttribPointer(v_texCoord, 2, context.FLOAT, false, 16,  8)
    context.enableVertexAttribArray(v_texCoord)
    
    // Texture
    
    displayTexture = context.createTexture()
    context.bindTexture(context.TEXTURE_2D, displayTexture)
    context.texParameteri(
        context.TEXTURE_2D,
        context.TEXTURE_WRAP_S,
        context.CLAMP_TO_EDGE
    )
    context.texParameteri(
        context.TEXTURE_2D,
        context.TEXTURE_WRAP_T,
        context.CLAMP_TO_EDGE
    )
    context.texParameteri(
        context.TEXTURE_2D,
        context.TEXTURE_MIN_FILTER,
        context.NEAREST
    )
    context.texParameteri(
        context.TEXTURE_2D,
        context.TEXTURE_MAG_FILTER,
        context.NEAREST
    )
    context.activeTexture(context.TEXTURE0)
    
    context.useProgram(shader)
    
    loop()
}

function loop() {
    let frameStart = performance.now()
    wasm.instance.exports.frame()
    let elapsed = performance.now() - frameStart
    
    if (16.67 - elapsed > 0) {
        setTimeout(() => {
            loop()
        }, 16.67 - elapsed);
    } else {
        setTimeout(() => {
            loop()
        }, 33.33 - elapsed);
    }
}

// MARK: Shaders ---------------------------------------------------------------

const vertexShader =
`
attribute vec2 v_position;
attribute vec2 v_texCoord;
varying   vec2 f_texCoord;

void main() {
    f_texCoord = v_texCoord;
    gl_Position = vec4(v_position, 0.0, 1.0);
}
`

const fragmentShader =
`
precision mediump float;

varying vec2      f_texCoord;
uniform sampler2D f_sampler;

void main() {
    gl_FragColor = texture2D(f_sampler, f_texCoord);
}
`

/** @param { WebGLRenderingContext } context */
function createShader(context) {
    const v = context.createShader(context.VERTEX_SHADER)
    const f = context.createShader(context.FRAGMENT_SHADER)
    
    context.shaderSource(v, vertexShader)
    context.shaderSource(f, fragmentShader)
    
    context.compileShader(v)
    context.compileShader(f)
    
    if (!context.getShaderParameter(v, context.COMPILE_STATUS)) {
        console.error("VERTEX SHADER: ", context.getShaderInfoLog(v))
    }
    if (!context.getShaderParameter(f, context.COMPILE_STATUS)) {
        console.error("FRAGMENT SHADER: ", context.getShaderInfoLog(f))
    }
    
    const p = context.createProgram()
    context.attachShader(p, v)
    context.attachShader(p, f)
    context.linkProgram(p)
    
    return p
}

// MARK: - API -----------------------------------------------------------------

const env = {
    draw,
    random,
    randomInRange,
    panicHandler
}

function draw(buf) {
    const array = new Uint8Array(
        wasm.instance.exports.memory.buffer,
        buf, displayWidth * displayHeight * 4
    )
    
    context.texImage2D(
        context.TEXTURE_2D, 0,
        context.RGBA, displayWidth, displayHeight, 0, context.RGBA, context.UNSIGNED_BYTE,
        array
    )
    
    context.clear(context.COLOR_BUFFER_BIT)
    context.drawArrays(context.TRIANGLES, 0, 6)
}

function random() {
    return Math.random()
}

function randomInRange(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function panicHandler(pointer, length) {
    console.error("WASM PANIC", decodeString(pointer, length))
    throw "PANIC"
}

function decodeString(pointer, length) {
    const slice = new Uint8Array(
        wasm.instance.exports.memory.buffer,
        pointer,
        length
    )
    return new TextDecoder().decode(slice);
};
