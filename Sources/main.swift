// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ANSITerminal

var width = 80
var height = 20

struct Game {
    var data: [[String]] = []

    var snakes: [Snake] = []

    init(snakes: [Snake]) {
        self.snakes = snakes

        var tempArray: [String] = []
        tempArray.append("+")
        for _ in 0..<width-2 {
            tempArray.append("⎯")
        }
        tempArray.append("+")
        data.append(tempArray)

        tempArray = []
        for _ in 0..<height-2 {
            tempArray.append("|")
            for _ in 0..<width-2 {
                tempArray.append(" ")
            }
            tempArray.append("|")
            data.append(tempArray)
            tempArray = []
        }

        tempArray.append("+")
        for _ in 0..<width-2 {
            tempArray.append("—")
        }
        tempArray.append("+")
        data.append(tempArray)
        tempArray = []
    }

    mutating func clearGrid() {
        for i in 1..<height-1 {
            for j in 1..<width-1 {
                self.data[i][j] = " "
            }
        }
    }

    mutating func updateSnakes(pressedDirection: Direction?) {
        for snake in snakes {
            snake.move(direction: pressedDirection)
            for (i, pos) in snake.positions.enumerated() {
                if i == snake.positions.count - 1 {
                    self.data[pos.0][pos.1] = "0".blue.bold
                } else {
                    self.data[pos.0][pos.1] = "0"
                }
            }
        }
    }

    mutating func update() {
        clearGrid()
        let direction = getKeyPressedDirection()
        updateSnakes(pressedDirection: direction)
    }

    func render() {
        clearScreen()

        let fullString = data.reduce("") { $0 + ($1.reduce("") { $0 + $1 }) + "\n" }
        print(fullString)
    }

    func checkLose() {
        for snake in snakes {
            if snake.isDead() {
                print("You lose")
                exit(0)
            }
        }
    }
}

enum Direction {
    case left
    case right
    case down
    case up
}

class Snake {
    var direction: Direction = .right
    var positions: [(Int, Int)] = [];
    var length = 20

    init() {
        for _ in 0..<length {
            positions.append((1, 1))
        }
    }

    func move(direction: Direction?) {
        if (self.direction == .left && direction != .right) ||
            (self.direction == .right && direction != .left) ||
            (self.direction == .up && direction != .down) ||
            (self.direction == .down && direction != .up)
        {
            self.direction = direction ?? self.direction
        }

        var newPos: (Int, Int) = positions.last! 
        switch self.direction {
            case .left  : newPos = (newPos.0, newPos.1 - 1)
            case .right : newPos = (newPos.0, newPos.1 + 1)
            case .up    : newPos = (newPos.0 - 1, newPos.1)
            case .down  : newPos = (newPos.0 + 1, newPos.1)
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

        positions.append(newPos)
        positions.removeFirst()
    }

    func isDead() -> Bool {
        if positions[0...positions.count-2].contains(where: { $0 == positions[positions.count-1] }) {
            return true
        }
        return false
    }
}

struct Food {
    var position: (Int, Int) = (1, 1)
}

func loop(game: inout Game) {
    var tic: Int = 0
    while true {
        storeCursorPosition()
        
        game.update()
        game.render()

        game.checkLose()

        tic += 1

        delay(100)
    }
}

var snake: Snake = Snake()
var game = Game(snakes: [snake])

// cursorOff()

loop(game: &game)

// cursorOn()
