#ifndef TONEUNIT_H
#define TONEUNIT_H

#import <AudioToolbox/AudioToolbox.h>

#define SAMPLERATE 44100

char createToneUnit(AudioComponentInstance *toneUnit);

char startAudio(AudioComponentInstance *toneUnit);

char stopAudio(AudioComponentInstance *toneUnit);

char freeAudio(AudioComponentInstance *toneUnit);

#endif /* TONEUNIT_H */
