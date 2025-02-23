# Interscore
An overlay for OBS Studio that displays scores and other info about streamed sports games.

## TODO new

### lessons from last use
- dont swap keybinding for teams after teamswitches
- time as a nummer für sich:
	- proper time reset
	- time is paused after setting by default
	- proper time input
- finish other widgets
- (easier WS connection)
- dont spam ii to update scoreboard

### frontend
- animations:
    - ingame bar opening and closing
    - players list spawning
    - table spawning

### rentnerend
- play sound when timer runs out
- 7-min-button reading the seven from json (no hardcoding)
- public window:
	- playing teams
	- score
	- time
	- colors
	- (other widgets between games)
- private window:
	- same as public (except other widgets)
	- deal yellow and red cards
	- pause time button
- Feedback/Suggestions Site + Widget FINAL

### backend
- (graceful Ctrl-C handling)
- save to json
- Sollten wir immer wieder den Tunierstate zwischenspeichern, falls das Programm aus irgendwelchen Gründen mal geschlossen werden sollte? In dem Zug, könnte man dann auch alles als JSON als Input definieren, so dass man auch manuell was ändern könnte und dann die JSON vom Programm reloaded wird. (Grundskizze in input.json)
- FINAL abstract program so it's applicable for other games
- ENSURE `n` and `p` work
- `+` and `-` functionality (add/remove seconds)

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

## Structure of data :moyai:
```c
struct Root {
    struct current_game {
        Game gamestate;
        bool halftime;
        int time_left;
    }
    struct all_games {
        Game[] games;
    }
    String[] teams;
}

struct Game {
    String team_1;
    String team_2;
    Score halftimescore;
    Score score;
    Card[] cards_handed; //FINAL
}

struct Score {
    int team_1;
    int team_2;
}

//FINAL
struct Card {
    Player player;
    enum {YELLOW_CARD, RED_CARD};
}

//FINAL
struct Team {
    Player Torwart;
    Player Außenspieler;
}
```
