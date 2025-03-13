# Interscore
An overlay for OBS Studio that displays scores and other info about streamed sports games.

## About
The OBS overlay is a single HTML file launched via the Browser source.
The file contents are controlled via the WebSocket protocol using a CLI server program, meant for admins.
Another client uses Qt6 and is meant for the referees and the public display in the hall. The can change the HTML contents by using the server as the middleman.

Tournament metadata (competing teams, timer lengths, game plan) is fed using a JSON file.

The overlay supports multiple "widgets" showing goals and the timer, teams participating in the tournament, currently playing teams and even red and yellow cards.

This project was made for our personal use in a Cycleball tournament under hilarious deadlines.

## Usage
1. Ensure your OBS edition supports Browser Source.
2. Compile the frontend script and the binaries with `make js b-install r-install`.
3. Fill out `input.json` given the template at `input.template.json`.
4. Open `frontnend/index.html` in OBS Studio and set appropriate dimensions.
5. Launch the `interscore` binary.
6. Give the `interscore-rentnerend` binary to your nearest referee.
7. Reload the HTML page so that you see `Client upgraded to WebSocket connection!` in the backend terminal.
8. Press `?` (followed by Enter/Return) in the backend terminal for possible actions.

## TODO new
- FINAL release binaries in GitHub Releases
- FINAL REMOVE input.json and
- FINAL how does the backend behave if JSON keys are missing?
- FINAL screenshots of backend options and rentnerend windows

### frontend
- scoreboard: whatever's happening with the score cells
- smooth time animation
- FINAL animate line by line
- (total CSS redesign)
- background for headings
- comment all relevant CSS
- gradient colors
- team logos for gamestart
- gameplan: highlight winner team

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

### meta
- Rauskriegen wer Feld und Außenspieler ist
- How does the tiebreak work?
- find colors for teams
