#import "ToneGeneratorViewController.h"
#import "ToneGenerator.h"
#import "UFSGenericTableViewDataSourceKeys.h"
#import "UFSGenericTableViewController.h"

#import <MediaPlayer/MPMediaItem.h>

#import "utils.h"

UIKIT_EXTERN NSString *rvcName(void) {
	return @"ToneGeneratorViewController";
}

@interface NSObject (UFSGenericTableViewDataSource)
- (NSString *)detailTextForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateMediaInfoKey:(NSString *)key withValue:(NSString *)value;
@end

static NSDictionary *UFSSomeDictionary();

@interface ToneGeneratorViewController ()

@property (nonatomic, retain) IBOutlet UIButton *playButton;

@property (nonatomic, retain) IBOutlet UISlider *transferSlider;
@property (nonatomic, retain) IBOutlet UILabel *transferLabel;
- (IBAction)sliderChanged:(UISlider *)slider;

@property (nonatomic, retain) IBOutlet UISegmentedControl *syncControl;
- (void)setSyncFrequency:(NSInteger)n;

@property (nonatomic, retain) IBOutlet UISlider *amplitudeSlider;
@property (nonatomic, retain) IBOutlet UILabel *amplitudeLabel;

@property (nonatomic, retain) IBOutlet UIButton *actionButton;
@property (nonatomic, retain) UFSGenericTableViewController *viewControllerToPresent;

@property (nonatomic, retain) ToneGenerator *toneGenerator;

@end

@implementation ToneGeneratorViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = NSLocalizedString(@"ToneGen", nil);

	_toneGenerator = [[ToneGenerator alloc] initWithMode:2];

	UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(action:)];
	self.navigationItem.leftBarButtonItem = b;
	[b release];

	_viewControllerToPresent = [[UFSGenericTableViewController alloc] initWithDictionary:UFSSomeDictionary()];
	[_viewControllerToPresent setCallback:^{
		[self getPreferences];
	}];
	[self getPreferences];
	NSUInteger *f = (NSUInteger *)_toneGenerator.modulatorData->frequencies;

	CGRect r = UtilsAvailableScreenRect();

	[self.view addSubview:_playButton = ({
		CGRect frame = CGRectMake((r.size.width / 2 - 100 / 2), 20, 100, 50);
		UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		button.frame = frame;
		button.backgroundColor = [UIColor clearColor];
		[button setTitle:NSLocalizedString(@"Transmit", nil) forState:UIControlStateNormal];
		[button setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateHighlighted];
		[button addTarget:self action:@selector(togglePlay:) forControlEvents:UIControlEventTouchUpInside];
		button;
	})];

	[self.view addSubview:_syncControl = ({
		CGRect frame = CGRectMake(r.size.width / 16, 80, r.size.width * 7 / 8, 50);
		UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[
			  [NSString stringWithFormat:@"%dKHz", (int)((CGFloat)f[0] / 1e3)]
			, [NSString stringWithFormat:@"%dKHz", (int)((CGFloat)f[1] / 1e3)]
			, [NSString stringWithFormat:@"%dKHz", (int)((CGFloat)f[2] / 1e3)]
			, [NSString stringWithFormat:@"%dKHz", (int)((CGFloat)f[3] / 1e3)]
		]];
		control.frame = frame;
		control.selectedSegmentIndex = 2;
		[control addTarget:self action:@selector(multiplierButton:) forControlEvents:UIControlEventValueChanged];
		control;
	})];

	[self.view addSubview:_transferLabel = ({
		CGRect frame = CGRectMake(r.size.width * 25 / 32, 140, r.size.width * 6 / 32, 20);
		UILabel *label = [[UILabel alloc] initWithFrame:frame];
		label.textAlignment = NSTextAlignmentRight;
		label.text = @"0%%";
		label.textColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor clearColor];
		label;
	})];

	[self.view addSubview:_transferSlider = ({
		CGRect frame = CGRectMake(r.size.width / 32, 140, r.size.width * 23 / 32, 20);
		UISlider *slider = [[UISlider alloc] initWithFrame:frame];
		slider.value = 0.5;
		[slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
		slider.tag = 1;
		[self sliderChanged:slider];
		slider;
	})];

	for (size_t i = 0; i < 4; i++) {
		[self.view addSubview:({
			CGRect frame = CGRectMake(r.size.width * 1 / 4, 200 + 40 * i, r.size.width * 1 / 4, 20);
			UILabel *label = [[UILabel alloc] initWithFrame:frame];
			label.textAlignment = NSTextAlignmentRight;
			label.text = [NSString stringWithFormat:@"%dKHz", (int)((CGFloat)f[i] / 1e3)];
			label.textColor = [UIColor whiteColor];
			label.backgroundColor = [UIColor clearColor];
			label.tag = 20 + i;
			label;
		})];
		[self.view addSubview:({
			CGRect frame = CGRectMake(r.size.width * 5 / 8, 200 + 40 * i, 0, 0);
			UISwitch *switchView = [[UISwitch alloc] initWithFrame:frame];
			[switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
			switchView.on = YES;
			switchView.tag = 10 + i;
			[switchView setOn:NO animated:YES];
			[self switchChanged:switchView];
			switchView;
		})];
	}

	[self.view addSubview:_amplitudeSlider = ({
		CGRect frame = CGRectMake(r.size.width / 32, 360, r.size.width * 23 / 32, 20);
		UISlider *slider = [[UISlider alloc] initWithFrame:frame];
		slider.value = 0.25;
		slider.minimumValue = 0.1;
		slider.maximumValue = 5;
		[slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
		slider.tag = 2;
		[self sliderChanged:slider];
		slider;
	})];
	[self.view addSubview:_amplitudeLabel = ({
		CGRect frame = CGRectMake(r.size.width * 25 / 32, 360, r.size.width * 6 / 32, 20);
		UILabel *label = [[UILabel alloc] initWithFrame:frame];
		label.textAlignment = NSTextAlignmentRight;
		label.text = @"0.25";
		label.textColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor clearColor];
		label;
	})];
}

- (id)init {
	if ((self = [super init])) {
		[UIApplication.sharedApplication beginReceivingRemoteControlEvents];
		[self becomeFirstResponder];
	}
	return self;
}

- (void)dealloc {
	[UIApplication.sharedApplication endReceivingRemoteControlEvents];
	[self resignFirstResponder];

	_playButton = nil;
	_transferLabel = nil;
	_transferSlider = nil;

	[_toneGenerator dealloc];
	[super dealloc];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
	if (receivedEvent.type == UIEventTypeRemoteControl) {
		switch (receivedEvent.subtype) {

		case UIEventSubtypeRemoteControlPlay:
			[self play];
			break;

		case UIEventSubtypeRemoteControlPause:
			[self pause];
			break;

		case UIEventSubtypeRemoteControlTogglePlayPause:
			[self togglePlay];
			break;

		case UIEventSubtypeRemoteControlPreviousTrack:
			[self setSyncFrequency:_syncControl.selectedSegmentIndex - 1];
			break;

		case UIEventSubtypeRemoteControlNextTrack:
			[self setSyncFrequency:_syncControl.selectedSegmentIndex + 1];
			break;

		default:
			break;
		}
	}
}

- (IBAction)sliderChanged:(UISlider *)slider {
	switch(slider.tag){
	case 1:
		_transferLabel.text = [NSString stringWithFormat:@"%.01f%%", 100 * slider.value];
		_toneGenerator.transferSpeed = slider.value;
	break;
	case 2:
		_amplitudeLabel.text = [NSString stringWithFormat:@"%.01f", slider.value];
		_toneGenerator.amplitude = slider.value;
	break;
	}
}

- (IBAction)switchChanged:(UISwitch *)switchView {
	int idx = switchView.tag - 10;
	_toneGenerator.modulatorData->frequenciesState[idx] = switchView.isOn;
}

- (IBAction)togglePlay:(UIButton *)selectedButton {
	[self togglePlay];
}

- (void)multiplierButton:(UISegmentedControl *)control {
	[self setSyncFrequency:control.selectedSegmentIndex];
}

- (void)action:(UIButton *)button {
	if (_viewControllerToPresent) {
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_viewControllerToPresent];
		[self presentViewController:nav animated:YES completion:^(){}];
		[nav release];
	}
}

- (void)getPreferences {
	NSIndexPath *indexPath;
	NSString *string;
	_toneGenerator.channelCount = [_viewControllerToPresent.dataSource numberOfRowsInSection:0];
	for (size_t i = 0; i < 4 && i < _toneGenerator.channelCount; i++) {
		indexPath = [NSIndexPath indexPathForRow:i inSection:0];

		string = [_viewControllerToPresent.dataSource detailTextForRowAtIndexPath:indexPath];
		_toneGenerator.modulatorData->frequencies[i] = string.integerValue;
		NSInteger frequency = string.integerValue;

		string = [_viewControllerToPresent.dataSource textForRowAtIndexPath:indexPath];
		if (_toneGenerator.modulatorData->words[i]) {
			free(_toneGenerator.modulatorData->words[i]);
		}
		_toneGenerator.modulatorData->words[i] = strdup([string cStringUsingEncoding:NSUTF8StringEncoding]);

		string = [NSString stringWithFormat:@"%dKHz", (int)((CGFloat)frequency / 1e3)];
		[_syncControl setTitle:string forSegmentAtIndex:i];
		((UILabel *)[self.view viewWithTag:20 + i]).text = string;
	}

	indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
	string = [_viewControllerToPresent.dataSource detailTextForRowAtIndexPath:indexPath];
	_toneGenerator.centerFrequency = string.integerValue;

	indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
	string = [_viewControllerToPresent.dataSource detailTextForRowAtIndexPath:indexPath];
	_toneGenerator.deltaFrequency = string.integerValue;
}

- (void)setSyncFrequency:(NSInteger)n {
	n = (n < 0) ? 0 : (n > 3) ? 3 : n;
	NSInteger frequency = _toneGenerator.modulatorData->frequencies[n];
	_toneGenerator.channelIndex = n;

	//UIAlert(debugString0, @(frequency));
	[_syncControl setSelectedSegmentIndex:n];
	[self updateMediaInfo:[NSString stringWithFormat:@"synth @%dKHz", (int)((CGFloat)frequency / 1e3)]];
}

- (void)togglePlay {
	if (_toneGenerator) {
		if (!_toneGenerator.playing) {
			[self play];
		} else {
			[self pause];
		}
	}
}

- (void)play {
	if (_toneGenerator) {
		[_toneGenerator play];
		[_playButton setTitle:NSLocalizedString(@"Pause", nil) forState:0];

		UIApplication.sharedApplication.idleTimerDisabled = YES;
		[self setSyncFrequency:_syncControl.selectedSegmentIndex];
	}
}
- (void)pause {
	if (_toneGenerator) {
		[_toneGenerator pause];
		[_playButton setTitle:NSLocalizedString(@"Transmit", nil) forState:0];

		UIApplication.sharedApplication.idleTimerDisabled = NO;
	}
}

- (void)updateMediaInfo:(NSString *)title {
	[(id)UIApplication.sharedApplication.delegate updateMediaInfoKey:MPMediaItemPropertyTitle withValue:title];
}
@end

static NSDictionary *UFSSomeDictionary() {
	return @{
		@"title" : @"Tableview",
		hideIndexTitlesKey : @YES,
		hideHeadersKey : @NO,
		hideFootersKey : @YES,
		canEditRowsKey : @YES,
		canMoveRowsKey : @YES,
		sectionsKey : @[
			@{
				titleForHeaderKey : @"header",
				titleForFooterKey: @"footer",
				rowsKey : @[
					@{
						textKey : @"Upasa",
						detailTextKey : @"2000"
					},
					@{
						textKey : @"Unada",
						detailTextKey : @"8000"
					},
					@{
						textKey : @"Utono",
						detailTextKey : @"14000"
					},
					@{
						textKey : @"Unoop",
						detailTextKey : @"15500"
					}
				]
			},
			@{
				titleForHeaderKey : @"header",
				titleForFooterKey: @"footer",
				rowsKey : @[
					@{
						textKey : @"Filter freq",
						detailTextKey : @"15500"
					},
					@{
						textKey : @"Delta freq",
						detailTextKey : @"1000"
					}
				]
			}
		],
		newCellKey : @[
			@{
				titleForHeaderKey : @"New header",
				titleForFooterKey: @"New footer",
				hideHeadersKey : @NO,
				canEditRowsKey : @YES,
				canMoveRowsKey : @NO,
				rowsKey : @[
					@{
						textKey : @"New",
						detailTextKey : @"X"
					}
				]
			}
		]
	};
}
