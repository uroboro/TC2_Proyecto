#import "ToneRenderer.h"
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

static inline char manchesterBitOfWordAtOffset(const char *word, int offset) {
	unsigned char letterOffset = offset / 16;
	const char letter = word[letterOffset];

	char manchesterOffset = offset % 16;
	char manchesterByte = manchesterOffset / 2;
	char manchesterSection = manchesterOffset % 2;

	char manchesterBit = (letter >> manchesterByte) & 0x1;
	return manchesterBit == manchesterSection;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState) {
	id generator = (id)inClientData;
	if ([generator respondsToSelector:@selector(stop)]) {
		[generator stop];
	}
}

OSStatus ToneRenderer(
	void						*inRefCon,
	AudioUnitRenderActionFlags	*ioActionFlags,
	const AudioTimeStamp		*inTimeStamp,
	UInt32						inBusNumber,
	UInt32						inNumberFrames,
	AudioBufferList 			*ioData)
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	static const double M_2PI = 2.0 * M_PI;
	static CGFloat theta_increment = M_2PI / SAMPLERATE;
	CGFloat amplitude = 0.25;

	// Get the parameters out of the view controller
	id<ToneRenderer> generator = (id<ToneRenderer>)inRefCon;
	NSUInteger transferSpeed = 2 * 43 * generator.transferSpeed;

	// Frequencies definitions
	NSUInteger centerFrequency = generator.centerFrequency;
	NSUInteger channelCount = generator.channelCount;
	NSUInteger channelIndex = generator.channelIndex;
	NSInteger df = generator.deltaFrequency;

	NSInteger *freqs = generator.modulatorData->frequencies;
	BOOL *states = generator.modulatorData->frequenciesState;
	char **words = generator.modulatorData->words;

	NSUInteger syncFrequency = centerFrequency - freqs[channelIndex];

	amplitude = (generator.amplitude > 0 && generator.amplitude < 10) ? generator.amplitude : amplitude;

	static unsigned char tick = 0;
	static char bit_p = 0;
	char bit = (tick / transferSpeed) % 2;
	tick++;
	tick %= 2 * transferSpeed;

	// Word-bit offsets. [0,16*strlen(word)] range for each offset
	static int offsets[] = { 0, 0, 0, 0 };

//NSLog(@"XXXX %d buffers", ioData->mNumberBuffers);

	Float32 *bufferR = (Float32 *)ioData->mBuffers[kDataStreamSideRight].mData;
	static CGFloat theta[] = { 0, 0, 0, 0};

	Float32 *bufferL = (Float32 *)ioData->mBuffers[kDataStreamSideLeft].mData;
	static CGFloat thetaL = 0;
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++) {
		//Right channel
		bufferR[frame] = 0.000001;
#if 01
		for (int w = 0; w < channelCount; w++) {
			if (states[w] == NO) continue;
			char val = manchesterBitOfWordAtOffset(words[w], offsets[w]);

			double freq = freqs[w] + df * (1 - 2 * val);

			bufferR[frame] += amplitude * sin(theta[w]);
			// Save radian offset within [0, 2*PI] range
			theta[w] += theta_increment * freq;
			while (theta[w] > M_2PI) {
				theta[w] -= M_2PI;
			}
		}
#endif
		//Left channel
		bufferL[frame] = 0.000001;
#if 01
		bufferL[frame] += amplitude * sin(thetaL);
		// Save radian offset within [0, 2*PI] range
		thetaL += theta_increment * syncFrequency;
		while (thetaL > M_2PI) {
			thetaL -= M_2PI;
		}
#endif
	}

	for (int w = 0; w < channelCount; w++) {
		if (bit != bit_p) {
			offsets[w]++;
			offsets[w] %= 16 * strlen(words[w]);
		}
	}
	bit_p = bit;

	[pool release];
	return noErr;
}
