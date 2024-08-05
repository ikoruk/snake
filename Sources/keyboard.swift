import ANSITerminal

enum Direction {
  static var allCases: [Direction] {
    return [.left, .right, .down, .up]
  }

  case left
  case right
  case down
  case up
  case esc
}

func getKeyPressedDirection() -> Direction? {
  if keyPressed() {
    let code = readCode()

    if code == 27 {
      let key = readKey()

      if key.code == .none {
        return Direction.esc
      }

      switch key.code {
      case .up: return Direction.up
      case .down: return Direction.down
      case .left: return Direction.left
      case .right: return Direction.right
      default: break
      }
    }
  }

  return nil
}
