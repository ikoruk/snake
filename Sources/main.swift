// The Swift Programming Language
// https://docs.swift.org/swift-book

import ANSITerminal
import Foundation

struct Game {
  var data: [[String]] = []

  var snakes: [Snake] = []

  var food = Food()

  var shouldClose = false

  init(snakes: [Snake]) {
    self.snakes = snakes

    var tempArray: [String] = []
    tempArray.append("\u{250c}")
    for _ in 0..<width - 2 {
      tempArray.append("\u{2500}")
    }
    tempArray.append("\u{2510}")
    data.append(tempArray)

    tempArray = []
    for _ in 0..<height - 2 {
      tempArray.append("\u{2502}")
      for _ in 0..<width - 2 {
        tempArray.append(" ")
      }
      tempArray.append("\u{2502}")
      data.append(tempArray)
      tempArray = []
    }

    tempArray.append("\u{2514}")
    for _ in 0..<width - 2 {
      tempArray.append("\u{2500}")
    }
    tempArray.append("\u{2518}")
    data.append(tempArray)
    tempArray = []
  }

  mutating func clearGrid() {
    for i in 1..<height - 1 {
      for j in 1..<width - 1 {
        self.data[i][j] = " "
      }
    }
  }

  mutating func updateSnakes(_ pressedDirection: Direction?) {
    for (i, snake) in snakes.enumerated() {
      if snake.isAI {
        var bestDirection: Direction = .right
        var bestDist: Int = Int.max

        // choose direction to move to food fastest, try to avoid other snakes
        for direction in Direction.allCases {
          if snake.direction == .left && direction == .right { continue }
          if snake.direction == .right && direction == .left { continue }
          if snake.direction == .up && direction == .down { continue }
          if snake.direction == .down && direction == .up { continue }

          let newPos = snake.newPosition(direction)

          // if the new position is occupied, skip
          var occupied = false
          for (j, otherSnake) in snakes.enumerated() {
            if otherSnake.realPositions(i == j).contains(where: { $0 == newPos }) {
              occupied = true
              break
            }
          }

          if occupied { continue }

          let dist =
            abs(food.position.0 - newPos.0) + abs(food.position.1 - newPos.1)

          if dist < bestDist {
            bestDist = dist
            bestDirection = direction
          }
        }

        snake.move(bestDirection)
      } else {
        snake.move(pressedDirection)
      }
    }
  }

  mutating func draw() {
    // update dead snake last
    let snakesArray = snakes.sorted(by: { !$0.isDead && $1.isDead })
    for snake in snakesArray {
      for (i, pos) in snake.positions.enumerated() {
        if i == snake.positions.count - 1 {
          if snake.isDead {
            self.data[pos.0][pos.1] = "X".foreColor(snake.color).bold
          } else {
            self.data[pos.0][pos.1] = "Ö".foreColor(snake.color).bold
          }
        } else if i == 0 {
          self.data[pos.0][pos.1] = "o".foreColor(snake.color)
        } else {
          self.data[pos.0][pos.1] = "0".foreColor(snake.color)
        }
      }
    }
    self.data[food.position.0][food.position.1] = "\u{00A9}".red.bold
  }

  mutating func updateFood(_ data: [[String]]) {
    for snake in snakes {
      if snake.currentPosition == food.position {
        snake.increaseLength()
        snake.increaseScore(food.score)
      }
      while snake.positions.contains(where: { $0 == food.position }) {
        food = Food()
      }
    }
  }

  mutating func updateIsDead() {
    for (i, snake) in snakes.enumerated() {
      // check if snake is dead
      for (j, otherSnake) in snakes.enumerated() {
        if otherSnake.realPositions(i == j).contains(where: { $0 == snake.currentPosition }) {
          snake.isDead = true
        }
      }
    }
  }

  mutating func update() {
    let direction = getKeyPressedDirection()
    if direction == .esc {
      shouldClose = true
      return
    }

    updateSnakes(direction)
    updateFood(data)
    updateIsDead()

    clearGrid()
    draw()
  }

  func render() {
    var fullString = data.reduce("") { $0 + ($1.reduce("") { $0 + $1 }) + "\n" }

    for (i, snake) in snakes.enumerated() {
      fullString += "\nSnake \(i+1) Score: \(snake.score)"
    }

    print(fullString)
  }

  func checkLose() -> Bool {
    var someoneDied = false

    if shouldClose {
      print("Exiting...")
      return true
    }

    if snakes.count == 1 && snakes.first!.isDead {
      print("You lost")
      return true
    }

    if snakes.count == 2 && snakes[0].isDead {
      print("Snake 2 won")
      return true
    } else if snakes.count == 2 && snakes[1].isDead {
      print("Snake 1 won")
      return true
    }

    for (i, snake) in snakes.enumerated() {
      if snake.isDead {
        print("Snake \(i+1) lost")
        someoneDied = true
      }
    }

    if someoneDied {
      return true
    }

    return false
  }
}

class Snake {
  var direction: Direction = .right
  var positions: [(Int, Int)] = []
  var length = 5
  var color: UInt8 = 14

  var score = 0
  var isDead = false
  var isAI = false
  var difficulty = 8

  init(
    _ initialPos: (Int, Int) = (1, 1), direction: Direction = .right, isAI: Bool = false,
    color: UInt8 = 14, difficulty: Int = 8
  ) {
    self.direction = direction
    self.isAI = isAI
    self.color = color
    self.difficulty = difficulty

    for _ in 0..<length {
      positions.append(initialPos)
    }
  }

  func increaseLength(_ increase: Int = 3) {
    for _ in 0..<increase {
      positions.insert(positions.first!, at: 0)
    }
  }

  func increaseScore(_ increase: Int) {
    score += increase
  }

  var currentPosition: (Int, Int) {
    return positions.last!
  }

  func realPositions(_ isSelf: Bool) -> ArraySlice<(Int, Int)> {
    let lastIndex = positions.count - (isSelf ? 2 : 1)

    // the first position which is different from the one after it in the array
    for (i, pos) in positions[0...lastIndex].enumerated() {
      if pos != positions[i + 1] {
        return positions[i...lastIndex]
      }
    }
    return positions[lastIndex...lastIndex]
  }

  func newPosition(_ direction: Direction) -> (Int, Int) {
    var newPos = positions.last!

    switch direction {
    case .left: newPos = (newPos.0, newPos.1 - 1)
    case .right: newPos = (newPos.0, newPos.1 + 1)
    case .up: newPos = (newPos.0 - 1, newPos.1)
    case .down: newPos = (newPos.0 + 1, newPos.1)
    default: break
    }

    if newPos.0 < 1 {
      newPos.0 = height - 2
    }
    if newPos.1 < 1 {
      newPos.1 = width - 2
    }
    if newPos.0 >= height - 1 {
      newPos.0 = 1
    }
    if newPos.1 >= width - 1 {
      newPos.1 = 1
    }

    return newPos
  }

  func move(_ direction: Direction?) {
    if !isAI {
      if (self.direction == .left && direction != .right)
        || (self.direction == .right && direction != .left)
        || (self.direction == .up && direction != .down)
        || (self.direction == .down && direction != .up)
      {
        self.direction = direction ?? self.direction
      }
    } else if Int.random(in: 0..<10) < difficulty {
      self.direction = direction ?? self.direction
    }

    positions.append(newPosition(self.direction))
    positions.removeFirst()
  }
}

struct Food {
  var position: (Int, Int) = (1, 1)
  var score = 40

  init() {
    position = (Int.random(in: 1..<height - 1), Int.random(in: 1..<width - 1))
  }
}

func loop(_ game: inout Game) {
  var tic: Int = 0
  while true {
    storeCursorPosition()

    game.update()
    game.render()

    if game.checkLose() {
      break
    }

    tic += 1

    delay(1000 / speed)

    restoreCursorPosition()
  }
}

var difficulty = 8
var width = 50
var height = 25
var speed = 10

if CommandLine.arguments.contains("--help") {
  print("Usage: \(CommandLine.arguments[0]) [options]")

  print("Options:")
  print("  --difficulty [0-10]  Set the difficulty of the game (default: \(difficulty))")
  print("  --width [width]      Set the width of the game (default: \(width))")
  print("  --height [height]    Set the height of the game (default: \(height))")
  print("  --speed [1-100]     Set the speed of the game (default: \(speed))")
  print("  --help               Show this help message")
  exit(0)
}

for (i, arg) in CommandLine.arguments.enumerated() {
  if arg == "--difficulty" {
    difficulty = Int(CommandLine.arguments[i + 1]) ?? difficulty
  } else if arg == "--width" {
    width = Int(CommandLine.arguments[i + 1]) ?? width
  } else if arg == "--height" {
    height = Int(CommandLine.arguments[i + 1]) ?? height
  } else if arg == "--speed" {
    speed = max(min(Int(CommandLine.arguments[i + 1]) ?? speed, 100), 1)
  }
}

clearLine()

print("Swift Snake by Yuliy and Guruprasad".green.bold)

var snake = Snake((height / 2, width / 4))
var otherSnake = Snake(
  (height / 2, 3 * width / 4), direction: .left, isAI: true, color: 11, difficulty: difficulty)
var game = Game(snakes: [snake, otherSnake])

cursorOff()

loop(&game)

cursorOn()
