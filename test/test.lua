local ffi = require"ffi"
--- SDL/image header
local sdl = require"sdl2_ffi"
local img = require"sdl2_image"
require"utils"
----------------------------------------

local Input  = {none = 0,left = 1, right = 2, jump = 3 , restart = 4, quit = 5}
local Game   = {}
local Player = {}

--------------
--- newPlayer
--------------
function Player.newPlayer(texture) -- :Player type
  return {
   texture = texture
  }
end

------------
--- newGame
------------
function newGame(renderer)
  return  {
    renderer = renderer,
    inputs   = {false,false,false, false,false,false},
    player   = Player.newPlayer(img.LoadTexture(renderer,"img/space-400.jpg")),
    -- method
    handleInput = Game.handleInput,
    render      = Game.render,
  }
end

-----------
-- toInput
-----------
function toInput(key)
  if key == sdl.SCANCODE_Q or
     key == sdl.SDL_SCANCODE_RETURN or
     key == sdl.SDL_SCANCODE_SPACE or
     key == sdl.SDL_SCANCODE_ESCAPE then
    return Input.quit
  else
    return Input.none
  end
end

--------------------
-- Game:handleInput
--------------------
function Game:handleInput()
  local event = ffi.new("SDL_Event")
  while sdl.pollEvent(event) ~= 0 do
    local kind = event.type
    if kind == sdl.QUIT then
      self.inputs[Input.quit] = true
    elseif kind == sdl.KEYDOWN then
      dprint("keydown")
      self.inputs[toInput(event.key.keysym.scancode)] = true
    elseif kind == sdl.KEYUP then
      dprint("keydup")
      self.inputs[toInput(event.key.keysym.scancode)] = false
    end
  end
end

--------------
--- drawImage
--------------
local angle = ffi.new("double[1]",0)
function drawImage(renderer,texture)
  if 0 > sdl.RenderCopyEx(renderer,texture,nil,nil,angle[0],nil,sdl.FLIP_NONE) then
    print("Error!: RenderCopy() ")
  end
  local speed = 0.005
  angle[0]= angle[0] + speed
end

---------------
--- Game:render
---------------
function Game:render()
   sdl.RenderClear(self.renderer)
   drawImage(self.renderer,self.player.texture)
   sdl.RenderPresent(self.renderer)
end

---------
--- main
---------
function main()
  if sdlFailIf(0 == sdl.init(sdl.INIT_VIDEO + sdl.INIT_TIMER + sdl.INIT_EVENTS),
    "SDL2 initialization failed") then os.exit(1) end
  if sdlFailIf(sdl.TRUE == sdl.SetHint("SDL_RENDER_SCALE_QUALITY", "2"),
     "Linear texture filtering could not be enabled") then os.exit(1) end

  local imgFlags = img.INIT_JPG
  if sdlFailIf(0 ~= img.Init(imgFlags), "SDL2 Image initialization failed") then os.exit(1) end

  local window = sdl.CreateWindow("SDL2_image test written in Luajit",
      sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED,
      480, 480, sdl.WINDOW_SHOWN)
  if sdlFailIf(0 ~= window,"Window could not be created") then os.exit(1) end

  local renderer = sdl.CreateRenderer(window,-1,
    sdl.RENDERER_ACCELERATED or sdl.RENDERER_PRESENTVSYNC)
  if sdlFailIf(0 ~= renderer,"Renderer could not be created") then os.exit(1) end

  --sdl.SetRenderDrawColor(renderer,0x08,0x88,0xff,255)
  sdl.SetRenderDrawColor(renderer,0x00,0x0,0x0,255)

  game = newGame(renderer)

  --------------
  --- Main loop
  --------------
  while not game.inputs[Input.quit] do
    game:handleInput()
    game:render()
  end

  --------------
  --- End procs
  --------------
  sdl.DestroyRenderer(renderer)
  sdl.DestroyWindow(window)
  img.Quit()
  sdl.Quit()
end

---------
--- main
---------
main()
