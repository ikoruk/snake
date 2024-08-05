import ANSITerminal

func getKeyPressedDirection() -> Direction? {
    if keyPressed() {
      let code = readCode()

      if code == 27 {
        let key = readKey()

        switch key.code {
            case .up   : return Direction.up
            case .down : return Direction.down
            case .left : return Direction.left
            case .right: return Direction.right
            default    : break
        }
      }
    }

    return nil
}
