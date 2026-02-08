# Interscoreread
A livestream system for Cycleball that includes an docker image with OBS, stream overlay, backend and advanced replay system as well as a software for the judges.
[cycleball.eu](https://cycleball.eu) integration and if possible REWATT support as judge software are in progress.

## About
This project goal is to make it as easy as possible to livestream cycleball, that isnt just an image without overlay. For more info and motivation visit the projects [website](https://mminl.de/projects/interscore) (keep in mind, that its not finished yet and mya not be updated regularly).

We want to achieve this by providing an high quality judge software running on Windows, MacOS, Linux, Web, Android and theoretically iOS (everything that flutter runs on), while the user additionally just has to install an andorid app or quickly configure a GoPro and stable internet connection.
On a technical level, we just need a RTMP stream to our server and a connected judge software.

We host all the backend via docker compose.
The OBS overlay is a single HTML file launched via the OBS Browser source.
The DOM contents are controlled in Typescript via WebSocket using the judges software/android app via a backend, which serves as websockets-server.
The overlay supports multiple "widgets" showing goals and the timer, teams participating in the tournament, currently playing teams and even red and yellow cards.

Tournament metadata (competing teams, timer lengths, game plan) is fed using a JSON file.

This project was made for our personal use prior to a Cycleball tournament under ridiculous deadlines. We are currently cleaning up the mess.

## Related Projects
- Android App (deprecated): https://github.com/mminl-de/interscore-remoteend
- unofficial cycleball.eu library: https://github.com/mminl-de/cycleu

## Usage

### Docker
The current version is tailord to my server setup, but can easily be replaced for a different setup.
We have 1 incoming (rtmp signal) and 1 incoming/outgoing(ws server) connection.
- The ws server is hosted on port 8081 by default. *On my setup we use an autossh container, portforwarding 8081 to mminl.de (my vps). For this you need to specify a ssh folder or file from the docker host machine and change the login user, that shall be bind into the container in docker-compose.yaml. If you dont want to portforward, but rather forward to the host machine, add the port forwarding in the backend section of docker-compose.yaml and dont start the ssh-tunnel container*
- We host an mediamtx container, as a rtmp-server, the port 1935 is used by default. The sending device has to stream to: `rtmp://IP_OF_HOST:1935/live/stream`
*In my setup the host has a ddns server, so the camera can connect to a static domain*
- OBS *should* be hardware accelerated on both amd and nvidia gpus, but amd is *not* tested well.
Building and running:
- For debugging purposes the obs image has a vncserver integrated. It broadcasts the obs UI on the host machine on port 5900
#### Building
- `cd docker/ && sudo docker compose build`
#### Running
- `cd docker/ && sudo docker compose up`

## Demonstrations
- https://www.youtube.com/watch?v=m4PdxYp68SQ (stream in early development)

# TODO

## meta
- Spiel 11 oder so final screen machen, dass 10 Spiel und finale Tabelle angezeit werden kann
1. should requester gauge delay between request & response?
2. should backend broadcast DATA_TIMESTAMP to everyone or only the requester?
- rename rentnerend to controller
- rename backend to echo or server or something:
	- since backend doesn't fulfill the same task as it used to
- FINAL^2 assets folder in seperate repo (only logos)
- FINAL^4 abstract program further to support other sports
	- Count time up instead of down (e.g. football)


## frontend
- new time system:
	- [x] correctly handle pausing, unpausing and timeskipping
	- [X] update UI accordingly
	- [X] change md struct
	- [ ] implement setting delay
	- [X] change time calculation logic
	- [ ] implement handshake
- BUG Spielplan scrollt nur einmalig
- CONSIDER frontend: zeit gelb, wenn HZpause
- cards
	- BUG Fix Font Problems wth Umlaute in Cards section?
	- Display Team in Cards Widget (Color/Background Color/Border Color/Logo)
	- Kartengrund
	- FINAL handle dealing multiple cards
- Display Widgets for single groups/multiple groups etc
- FINAL^0 team logos for gamestart
- FINAL Reversing der anzeige, je nach Kameraposition (in input.json)
	- rentnerend/remoteend info on which is which (standard/reverse or frontside/backside)
- FINAL make json_load resilient to bad input.json
- FINAL animate line by line
- FINAL comment all relevant CSS
- FINAL IDEA Time estimates:
	- time key in json
	- sending signal to frontend to calculate all estimates
	- frontend calculates difference between promised and actual game lengths
	- schedule delayed by this difference
	- calculations done only when calling the gameplan
- FINAL IDEA Fullscreen Endscore with Team Badge (maybe only winning) (Could have false positives when referee calls "letzter Schlag" or wants more time):
	- post-tournament stats (game data, nothing fancy)
- FINAL^2 Wenn z.B. mind. 3 Tore hintereinander von einem Team innerhalb von 2 min passieren ohne Gegentore, ist Team "on fire" (siehe CS):
	- integer for streak (0 by default)
	- fixed size timer for streak
	- if a team scores, timer resets and streak increments
	- if timer runs out of opponents scores, streak gets reset
- FINAL Seite: Ads unten (or Vollbild/Seite)
- FINAL kompliziertere Animation vom Spielwidget (einzelne Elemente kurz hintereinander reinanimieren, so dass es sich aufbaut)
- FINAL² Widget: Stats für Teams (Win/Loss/Tie, Tor geschossen/Tor gekriegt, %nach Halbzeitführung converted, Torwart/Feldspieler, vorherige Liga, aktueller Ligaplatz) Daten aus cycleball.eu/radball.at
- FINAL³ translations

## rentnerend
### JSON-Creator
- JSON-Creator GUI for non-technical users
- @julian :) Import tournaments from cycleball.eu (and Radball.at when library is ready)
- @julian FINAL Import Spieler, Teams, Vereine, Ligen, Schiedsrichter for custom tournaments from cycleball.eu (and Radball.at)
- FINAL² add export to Spielplan-pdf:
	- we define a standard for what formular keys we expect
	- users can upload their template only if their matches our standard:
		- otherwise error dialog ig
	- we export the results as a writable formular
- FINAL² Add referees
### Input Window
- verletzungscounter
- widget pipelines: 5s this widget, 5s that
- support and create more gameactions easily
- FINAL make the streaming status button accurate
- FINAL Add cycleball.eu push support
- FINAL Cards for Coaches: "Coach von Gifhorn 1 bekommt eine gelbe Karte"
- FINAL delte cards
### Public Window
- zeit sollte rot werden (oder gelb), wenn pausiert (im public window)
- FINAL Reversing der anzeige im Anzeigefenster, je nach Position des Bildschirms/Beamers (maybe button anzeigen, wenn window im fokus?)
- recv & send time handshake
- FINAL Ads, e.g. fullscreen video/picture during a pause
- FINAL Next Game in public window, e.g. before the fullscreen ad during a pause
- FINAL³ IDEA Ansagen durch KI bei der Hälfte
### Remote Window
- FINAL Display Gamerelated information:
	- Scoreboard Infos: Teams playing, Score, Time, Half
	- Connection Status of all Clients (backend, rentnerend, frontend)
	- OBS Scene / replay situation
### Infoend
- know if boss is connected and if no, warn about incorrect info @backend
- zeit als bar um den oval rum
- FINAL Add Logo to Info Window

## backend
- FINAL loggt wie viele leute connecten (Info Window)

## Docker
### Misc
- FINAL better live.mminl.de setup without ddns on host...
- build multiple stream support

### OBS
- Make sure the delay drift is not happening, maybe edit ffmpeg options so we get low delay rtmp stream
- Make replay System work properly, test it throughly
- Find a robust solution to combat delay (like blinking square)
- FINAL Let remoteend/rentnerend remotely start a stream-session
- Better UI for replays
- Better Transition-Animations
- Explore "hotkeys": {"ObsBrowser.Refresh"} option and others to hot reload frontend/rmtp stream etc.
- FINAL Add different replay possibilities (?? make setting for: speed of replay, length of replay)
- FINAL Allow changing/select Streaming Service

## interscore.mminl.de
- UX improvement: look like frontend
- mobile friendly
- tutorial page
- more images and widgets
- in depth view on features, usage

# Interscore input-gui

## Plan
- wizard type
- three pages:
	- General game settings:
		- length of game: number input
		- number of players: number input
		- types of roles: string list
	- Team config:
		- two panes:
			- teams: string list
			- info for selected team:
				- name: text input
				- logo: image button with preview
				- players:
					- name: text input
					- position: dropdown
	- Games: widget list
- final page contains "Generate" button that asks for the JSON location

# stuff
ffplay command for low latency: `ffplay -fflags nobuffer -flags low_delay -framedrop -analyzeduration 0 -sync ext -noframedrop -rtmp_buffer 10 -infbuf rtmp://localhost/live/test`
