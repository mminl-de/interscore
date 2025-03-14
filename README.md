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
9. Press `?` (followed by Enter/Return) in the backend terminal for possible actions.

## TODO new
- FINAL release binaries in GitHub Releases
- FINAL REMOVE input.json and project.seer and assets
- FINAL how does the backend behave if JSON keys are missing?
- FINAL screenshots of backend options and rentnerend windows

### frontend
- team logos for gamestart
- gameplan: highlight winner team
- FINAL animate line by line
- FINAL comment all relevant CSS
- FINAL handle dealing multiple cards

### rentnerend
- play sound when timer runs out
- stop the crashing after long time
- 7-min-button reading the seven from json (no hardcoding)
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
- Time als time_t definieren
- FINAL make json_load resilient to bad input.json
- Time in backend auch runterzählen (wenn nicht time_t einführen)

### meta
- How does the tiebreak work?
