# Tron Game in Assembly (x86)

## Main Structure of the Code

1. **Menu and Program Start**
   - The program begins with `ShowMenu`, which displays a menu allowing the user to either start the game or exit.
   - A `MenuLoop` is initiated to allow the program to return to the menu after the game ends.

2. **Start Game**
   - When the user selects "Start game," the program switches to a graphical interface.
   - The game initializes:
     - Player 1 (p1) and Player 2 (p2) positions.
     - Previous positions of both players.
     - Time.
     - Walls are drawn.

3. **Game Loop**
   - The main cycle of the game involves:
     - **Draw:** Updates the positions of both players and their trails. Before setting the pixel color, collision checks are performed.
     - **Delay:** Ensures a brief pause between renders for smoother visuals.
     - **Move:** Handles asynchronous keypress detection. If a key is pressed, the corresponding direction is set for each player (0 = up, 1 = down, 2 = right, 3 = left).
     - **MoveBasedOnDir:** Reads the direction of both players, moves them accordingly, and returns to `Draw`.

## Helper Subroutines

### Movement and Positioning

- **`Move[Direction]`**
  - **Input:**  
    - `ax = posX` OR `bx = posY`
  - **Operation:** Increases or decreases the input value.
  - **Output:** None.

- **`getPosXY`**
  - **Input:**  
    - `di = starting memory address`
  - **Output:**  
    - `ax = posX`  
    - `bx = posY`

- **`setPosXY`**
  - **Input:**  
    - `di = starting memory address`  
    - `ax = posX`  
    - `bx = posY`
  - **Output:** None.

### Drawing

- **`DrawHorizontalLine`**
  - **Input:**  
    - `dx = starting row`
  - **Operation:** Draws a horizontal line in green.
  - **Output:** None.

- **`DrawVerticalLine`**
  - **Input:**  
    - `dx = starting pixel address`
  - **Operation:** Draws a vertical line in green.
  - **Output:** None.

### Graphical Calculations

- **`GetGraphPos`**
  - **Input:**  
    - `ax = posX`  
    - `bx = posY`
  - **Output:**  
    - `graphPos = posY * 320 + posX`

### Collision Detection

- **`CheckForCollisonP1`**
  - **Input:**  
    - `ax = graphPos`
  - **Operation:** If a collision occurs, jumps to `P2Wins`.
  - **Output:** None.

- **`CheckForCollisonP2`**
  - **Input:**  
    - `ax = graphPos`
  - **Operation:** If a collision occurs, jumps to `P1Wins`.
  - **Output:** None.

### Result Handling

- **`P1Wins`**
  - **Operation:** Sets `dx` to `P1WinMsg` and jumps to `ShowResult`.

- **`P2Wins`**
  - **Operation:** Sets `dx` to `P2WinMsg` and jumps to `ShowResult`.

- **`ShowResult`**
  - **Operation:** Displays the result, waits for a key press, then jumps back to `ShowMenu`.

## Notes on Memory and Time Management

- Variables are stored in memory.
- Time-related data is managed using the stack.
