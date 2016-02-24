#import "UFSGenericTableViewController.h"
#import "UFSGenericTableViewDataSource.h"
#import "UFSGenericTableViewDataSourceKeys.h"
#import "UFSGenericTableViewDelegate.h"

#import "utils.h"

@interface UFSGenericTableViewController () {
	BOOL _discardChanges;
}
@end

@implementation UFSGenericTableViewController

#pragma mark - Editing

- (void)cancelEdit {
	_discardChanges = YES;
	[self setEditing:NO animated:YES];
	_discardChanges = NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];

	if (self.presentingViewController) {
		UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:editing ? UIBarButtonSystemItemCancel : UIBarButtonSystemItemDone target:self action:editing ? @selector(cancelEdit) : @selector(dismiss)];
		self.navigationItem.leftBarButtonItem = b;
		[b release];
	}

	NSIndexSet *idxSet = [NSIndexSet indexSetWithIndex:[_dataSource numberOfSections]];
	[self.tableView beginUpdates];
	if (editing) {
		[self.tableView insertSections:idxSet withRowAnimation:UITableViewRowAnimationFade];
	} else {
		[self.tableView deleteSections:idxSet withRowAnimation:UITableViewRowAnimationFade];
	}
	[self.tableView endUpdates];

	if (editing || !_discardChanges) {
		[_dataSource saveState];
	} else {
		[_dataSource restoreState];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		    [self.tableView reloadData];
		});
	}
}

#pragma mark - UIViewController methods

- (void)dismiss {
	[self dismissViewControllerAnimated:YES completion:^{
		_callback();
	}];
}

- (void)loadView {
	[super loadView];

	[self setSaveFilePath:UtilsDocumentPathWithName(@"genericTable.plist")];

	[self loadState];

	self.title = [_dataSource objectForKey:@"title"];
	self.navigationItem.rightBarButtonItem = ([_dataSource objectForKey:canEditRowsKey]) ? self.editButtonItem : nil;

	//self.tableView.bounces = NO;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (self.presentingViewController) {
		UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
		self.navigationItem.leftBarButtonItem = b;
		[b release];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	//[self saveState];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//	return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];

		BOOL supportedOrientations[7] = {
			NO, 	//UIDeviceOrientationUnknown
			YES,	//UIDeviceOrientationPortrait
			NO, 	//UIDeviceOrientationPortraitUpsideDown
			YES,	//UIDeviceOrientationLandscapeLeft
			YES,	//UIDeviceOrientationLandscapeRight
			NO, 	//UIDeviceOrientationFaceUp
			NO		//UIDeviceOrientationFaceDown
		};
	return supportedOrientations[interfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - Initialization

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if ((self = [super init])) {
		_dataSource = [(UFSGenericTableViewDataSource *)[UFSGenericTableViewDataSource alloc] initWithDictionary:dictionary];
		[self.tableView setDataSource:_dataSource];

		_delegate = [(UFSGenericTableViewDelegate *)[UFSGenericTableViewDelegate alloc] initWithViewController:self andDataSource:_dataSource];
		[self.tableView setDelegate:_delegate];

		//[self loadState];
	}

	return self;
}

- (void)dealloc {
	[_dataSource release];
	_dataSource = nil;
	[_delegate release];
	_delegate = nil;

	[super dealloc];
}

#pragma mark - State Management

- (void)loadState {
	if ([_dataSource data] == nil && [[NSFileManager defaultManager] fileExistsAtPath:_saveFilePath]) {
		_dataSource = [(UFSGenericTableViewDataSource *)[UFSGenericTableViewDataSource alloc] initWithContentsOfFile:_saveFilePath];
	}
#if 0
	NSDictionary *loadingPlist = [NSDictionary dictionaryWithContentsOfFile:_saveFilePath];
	if (loadingPlist) {
		NSArray *val = [loadingPlist objectForKey:@"contentOffset"];
		if (val) {
			CGPoint position = (CGPoint){ [[val objectAtIndex:0] floatValue], [[val objectAtIndex:1] floatValue] };
			[self.tableView setContentOffset:position animated:NO];
		}
	}
#endif
}

- (void)saveState {
	if (!self.editing) {
		[_dataSource writeToFile:_saveFilePath atomically:YES];
	}
}

@end
