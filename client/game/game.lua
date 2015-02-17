require 'game.env.constants'
require 'game.env.globals'
require 'game.env.images'

local scenes = {
  login = Scene:new('game/scenes/json/login.json', 'game.scenes.logic.login'),
  game = Scene:new('game/scenes/json/game.json', 'game.scenes.logic.game')
}

function love.load()
  -- Listen for new messages from the server
  TCP:listen()
end

function love.draw()
  scenes[currentScene]:tick()
  tick()
end

function love.keypressed(key)
  KeyState:keyPress(key)
end

function love.textinput(t)
  KeyState:enter(t)
end

function tick()
  -- Non drawing related tick events.
  MouseState:tick()
  NetworkEvents:tick()

  love.window.setTitle('Moongate - testclient (' .. love.timer.getFPS() .. ' fps)')
end