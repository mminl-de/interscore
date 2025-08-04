#include <QAudioOutput>
#include <QMediaPlayer>

#include "audio.hpp"
#include "constants.hpp"

QMediaPlayer player = QMediaPlayer();
QAudioOutput audio_output = QAudioOutput();

void
audio::init(void) {
	player.setAudioOutput(&audio_output);
	player.setSource(QUrl::fromLocalFile(CONSTANTS__SOUND_GAME_END));
	audio_output.setVolume(1);
	// TODO READ do we need to free something?
}

// TODO CONSIDER
void
audio::play(void) {
	player.play();
}
