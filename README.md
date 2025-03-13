# Interscore
An overlay for OBS Studio that displays scores and other info about streamed sports games.

## TODO About
- client-server using WebSockets for control
- CLI WebSocket server in C, meant for admins
- another client in Qt6 for referees, uses two windows for displaying score in the arena
- uses localhost html page for overlaying stuff on OBS as client
- multiple widgets: counting goals and time, showing all teams, now playing teams, red and yellow cards
- custom tournament data using JSON (template in input.template.json)
- made for own use for a local Cycleball Tournament under hilarious deadlines

## Usage
1. Compile the frontend script and the binaries with `make js b-install r-install`.
2. Open `frontnend/index.html` in OBS Studio and set appropriate dimensions.
3. Launch the `interscore` binary.
4. Give the `interscore-rentnerend` binary to your nearest referee.
5. Reload the HTML page so that you see `Client upgraded to WebSocket connection!` in the backend terminal.
6. Press `?` (followed by Enter/Return) in the backend terminal for possible actions.

## TODO new
- FINAL release binaries in GitHub Releases
- FINAL REMOVE input.json and

### frontend
- scoreboard: whatever's happening with the score cells
- smooth time animation
- FINAL animate line by line
- (total CSS redesign)
- background for headings
- comment all relevant CSS
- gradient colors
- team logos for gamestart

### rentnerend
- sync backup via json file
- play sound when timer runs out
- fix mg_random bug
- stop the crashing after long time
- 7-min-button reading the seven from json (no hardcoding)
- public window:
	- colors ?
	- (other widgets between games)
- private window:
	- colors ?
	- deal yellow and red cards
- FINAL Feedback/Suggestions Site + Widget
- FINAL Halbzeituhr
- FINAL Add possibility of teams missing
- FINAL Add referees
- FINAL FINAL JSON-Creator GUI for non-technical users
- FINAL FINAL port to windows/mac

### backend
- gameplan: there should be 6 games, not 7
- handle dealing multiple cards
- d key causing SEGFAULT on empty input
- Sollten wir immer wieder den Tunierstate zwischenspeichern, falls das Programm aus irgendwelchen Gründen mal geschlossen werden sollte? In dem Zug, könnte man dann auch alles als JSON als Input definieren, so dass man auch manuell was ändern könnte und dann die JSON vom Programm reloaded wird. (Grundskizze in input.json)
- FINAL abstract program so it's applicable for other games
- ENSURE `n` and `p` work
- (graceful Ctrl-C handling)

### readme
- context about what (and why) this is
- describe the backend
- describe the rentnerend (both windows)

### meta
- Rauskriegen wer Feld und Außenspieler ist
- How does the tiebreak work?
- find colors for teams

## Included info on different scenes/moments in stream
### FINAL Start of game/halftime
- list of players in both teams (with roles)

### Ingame
- both team's names (and colors)
- game timer
- countdown bar
- is second halftime?
- FINAL team logos

### Halftime pause
- Score at halftime
- first or second halftime?

### Live table
- Numbers list of
- All previous games calculated and printed with:
    - team names
    - numbers of games won
    - number of games tied
    - number of games lost
    - points
    - goals
    - goals caseered
    - tordiff

### Turnierverlauf
- previous games' info in a table (see above)
    - team names
    - score at halftime
    - final score
    - FINAL Cards given to players

## User API description
- user fills out a JSON with certain properties:
    - team list:
        - player list per team
    - list of games
    - time per game
    - halftimes per game
- program checks if every required field is filled (including array items)
- server generates a hotkey table for quick goals assignment and transitions
```
