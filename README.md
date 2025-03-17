# Interscore
An overlay for OBS Studio that displays scores and other info about streamed sports games.

## About
The OBS overlay is a single HTML file launched via the Browser source.
The DOM contents are controlled via the WebSocket protocol using a CLI server program, meant for admins.
Another client uses Qt6 and is meant for the referees and the public display in the hall. The can change the HTML contents by using the server as the middleman.

Tournament metadata (competing teams, timer lengths, game plan) is fed using a JSON file.

The overlay supports multiple "widgets" showing goals and the timer, teams participating in the tournament, currently playing teams and even red and yellow cards.

This project was made for our personal use in a Cycleball tournament under hilarious deadlines.

## Usage
1. `git clone --recursive https://github.com/hiimsergey/interscore && cd interscore`
2. Ensure your OBS edition supports Browser Source.
3. Compile the frontend script and the binaries with `make js b-install r-install`.
4. Fill out `input.json` given the template at `input.template.json`.
5. Open `frontnend/index.html` in OBS Studio and set appropriate dimensions.
6. Launch the `interscore` binary.
7. Give the `interscore-rentnerend` binary to your nearest referee.
8. Reload the HTML page so that you see `Client upgraded to WebSocket connection!` in the backend terminal.
9. Press `?` (followed by Enter/Return) in the backend terminal to see possible actions.

## Demonstrations
- https://www.youtube.com/watch?v=3LFNC_H9lVw (a little unstable but brings the idea across)

# TODO
## Lehren/Ideen vom 2. Stream
- +20/+1min/Text-Feld für schnelle Custom-Zeit
- FINAL³ Idee: Ansagen durch KI bei der Hälfte
- Gleich Spielen ab der Hälfte zum nächsten Spiel ansagen/neues Widget dafür (evtl in gamestart widget)
- Leertaste als Shortcut für Start/Stop
- FINAL² Livereload, dass man backend neustarten kann
- Widget spawn animation fixen(manchmal kaputt)
- Beim Spielzurücksetzen spielt die Zeit verrückt
- Nicht erlauben, dass mehrere Widgets gleichzeitig aktiviert sind
- Welche Spiele sichtbar sind im Livetable und Gameplan ist schlecht.

## TODO new
- FINAL release binaries in GitHub Releases
- FINAL REMOVE input.json and project.seer and assets
- FINAL screenshots of backend options and rentnerend windows

### frontend
- team logos for gamestart
- FINAL animate line by line
- FINAL comment all relevant CSS
- FINAL handle dealing multiple cards
- FINAL Ads

### rentnerend
- public window:
	- (other widgets between games)
- private window:
	- deal yellow and red cards
- FINAL Feedback/Suggestions Site + Widget
- FINAL Halbzeituhr
- FINAL Add possibility of teams missing
- FINAL Add referees
- FINAL FINAL JSON-Creator GUI for non-technical users
- FINAL FINAL port to windows/mac

### backend
- FINAL abstract program so it's applicable for other games
- (graceful Ctrl-C handling)
- obs integration
- FINAL make json_load resilient to bad input.json

### meta
- How does the tiebreak work?
