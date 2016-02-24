#include "rendertone.h"
#import "toneunit.h"

#define COUNT_OF(x) ((sizeof(x)/sizeof(0[x])) / ((size_t)(!(sizeof(x) % sizeof(0[x])))))

#define HUMAN_MIN_FREQUENCY 20
#define HUMAN_MAX_FREQUENCY 22050

void manchesterize(char *word, char *buffer) {
	if (word == NULL || buffer == NULL) return;
	int l = strlen(word);
	for (int i = 0; i < l; i++) {
		for (int b = 0; b < 8; b++) {
			char bit = buffer[16 * i + 2 * b + 1] = (word[i] >> (7 - b)) && 0x1;
			buffer[16 * i + 2 * b + 0] = bit;
		}
	}
}

static char buff[9];
void fillBuff(char c) {
	for (int i = 0; i < 8; i++) {
		buff[i] = '0' + ((c >> i) & 0x1);
	}
	buff[8] = 0;
}

#define kDataStreamSideRight 1
#define kDataStreamSideLeft  0

OSStatus RenderTone(
	void *inRefCon,
	AudioUnitRenderActionFlags	*ioActionFlags,
	const AudioTimeStamp		*inTimeStamp,
	UInt32						inBusNumber,
	UInt32						inNumberFrames,
	AudioBufferList 			*ioData)
{
	static const double M_2PI = 2.0 * M_PI;
	static double theta_increment = M_2PI / SAMPLERATE;
	double amplitude = 0.25;

	// Get the tone parameters out of the view controller
	AudioComponentInstance *toneUnit = (AudioComponentInstance *)inRefCon;
	static int stop = 0;
	if (stop == 43*2) {
		CFRunLoopStop(CFRunLoopGetMain());
		return noErr;
	}
	stop++;

	double freqs[] = { 2000.0, 4000.0, 8000.0, 16000.0 };
	double df = 500;

	static char *words[] = {
		"UªUª"
	};

	static char transferSpeed = (char)(43 * 0.1);
	static unsigned char tick = 0;
	static char bit_p = 0;
	char bit = (tick / transferSpeed) % 2;
	tick++;
	tick %= 2 * transferSpeed;

	// Word-bit offsets. [0,16*strlen(word)] range for each offset
	static int offsets[] = { 0, 0, 0, 0 };

	Float32 *bufferR = (Float32 *)ioData->mBuffers[kDataStreamSideRight].mData;
	static double theta[] = { 0, 0, 0, 0};

	Float32 *bufferL = (Float32 *)ioData->mBuffers[kDataStreamSideLeft].mData;

	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
		//Right channel
		bufferR[frame] = 0;
		for (int w = 0; w < COUNT_OF(words); w++) {
			const char *word = words[w];

			unsigned char letterOffset = offsets[w] / 16;
			const char letter = word[letterOffset];

			char manchesterOffset = offsets[w] % 16;
			char manchesterByte = manchesterOffset / 2;
			char manchesterSection = manchesterOffset % 2;

			char manchesterBit = (letter >> manchesterByte) & 0x1;
			char val = manchesterBit == manchesterSection;

			double freq = freqs[w] + df * (1 - 2 * val);

			if (frame == 0) {
				fillBuff(letter);
				printf("%d,%03d\t", w, offsets[w]);
				printf("\"%s\"[%d]='%c'\t", word, letterOffset, letter);
				printf("%s[%d]=%d\t", buff, manchesterByte, manchesterBit);
				printf("%d==%d=%d\t", manchesterBit, manchesterSection, val);
				printf("%d\n", (int)freq);
			}

			bufferR[frame] += amplitude * sin(theta[w]);
			// Save radian offset within [0, 2*PI] range
			theta[w] += theta_increment * freq;
			while (theta[w] > M_2PI) {
				theta[w] -= M_2PI;
			}
		}

		//Left channel
		bufferL[frame] = bufferR[frame];
	}

	for (int w = 0; w < COUNT_OF(words); w++) {
		if (bit != bit_p) {
			offsets[w]++;
			offsets[w] %= 16 * strlen(words[w]);
		}
	}

	bit_p = bit;

	return noErr;
}
