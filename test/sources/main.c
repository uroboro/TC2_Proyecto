#include "toneunit.h"

void nowPlayingInfo(char *string);

int main(int argc, char **argv, char **envp) {
	AudioComponentInstance toneUnit = NULL;
	createToneUnit(&toneUnit);

	startAudio(&toneUnit);
	CFRunLoopRun();
	stopAudio(&toneUnit);

	freeAudio(&toneUnit);

	return 0;
}
