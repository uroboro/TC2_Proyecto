#import "UFSGenericTableViewDelegate.h"
#import "UFSGenericTableViewDataSource.h"
#import "UFSBasicEditor.h"

#import "utils.h"

@interface NSObject (UFSGenericTableViewDataSource)
- (NSString *)detailTextForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation UFSGenericTableViewDelegate

#pragma mark - Initializers

- (id)initWithViewController:(UIViewController *)viewController {
    return [self initWithViewController:viewController andDataSource:nil];
}

- (id)initWithDataSource:(id <UITableViewDataSource>)dataSource {
    return [self initWithViewController:nil andDataSource:dataSource];
}

- (id)initWithViewController:(UIViewController *)viewController andDataSource:(id <UITableViewDataSource>)aDataSource {
    if ((self = [super init])) {
        _viewController = viewController;
        _dataSource = aDataSource;
    }

    return self;
}

#pragma mark - UITableViewDelegate Protocol

#pragma mark - Configuring Rows for the Table View
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 2.0 and later.
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 7.0 and later.
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 2.0 and later.
	return 0;
}
*/
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 2.0 and later.
}

#pragma mark - Managing Accessory Views

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 2.0 and later.
}

#pragma mark - Managing Selections

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 2.0 and later.
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 2.0 and later.

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	[cell setSelected:NO animated:YES];

// Fixed class
	NSString *controllerClass = @"UFSBasicEditor";//[rowDict objectForKey:@"controllerClass"];
	if (controllerClass) {
		__block UFSBasicEditor *detail = [NSClassFromString(controllerClass) new];
        [detail setWord:[(id)_dataSource textForRowAtIndexPath:indexPath]];
        [detail setFrequency:(NSUInteger)[(id)_dataSource detailTextForRowAtIndexPath:indexPath].integerValue];

        [detail setCallback:^(NSString *word, NSInteger frequency) {
            //UIAlert(debugString0, wwword);
            [(UFSGenericTableViewDataSource *)_dataSource setText:word forRowAtIndexPath:indexPath];
            [(UFSGenericTableViewDataSource *)_dataSource setDetailText:@(frequency).description forRowAtIndexPath:indexPath];
            [((UITableViewController *)_viewController).tableView reloadData];
        }];
		[(UINavigationController *)_viewController.parentViewController pushViewController:detail animated:YES];
		[detail release];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 3.0 and later.
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 3.0 and later.
}

#pragma mark - Modifying the Header and Footer of Sections
/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	// Available in iOS 2.0 and later.
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	// Available in iOS 2.0 and later.
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	// Available in iOS 2.0 and later.
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
	// Available in iOS 7.0 and later.
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	// Available in iOS 2.0 and later.
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
	// Available in iOS 7.0 and later.
	return 0;
}
*/
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
	// Available in iOS 6.0 and later.
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
	// Available in iOS 6.0 and later.
}

#pragma mark - Editing Table Rows

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 2.0 and later.
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 2.0 and later.
}

// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 2.0 and later.

	// No editing style if not editing or the index path is nil.
	if (!_viewController.editing || !indexPath) {
		return UITableViewCellEditingStyleNone;
	}
	// Determine the editing style based on whether the cell is a placeholder for adding content or already
	// existing content. Existing content can be deleted.
	if (indexPath.section >= [_dataSource numberOfSectionsInTableView:tableView] - 1) {
		return UITableViewCellEditingStyleInsert;
	} else {
		return UITableViewCellEditingStyleDelete;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 3.0 and later.
	return @"Delete";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// Available in iOS 2.0 and later.
	return YES;
}

#pragma mark - Reordering Table Rows

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	// Available in iOS 2.0 and later.
	NSIndexPath *idxPath = proposedDestinationIndexPath;

	NSUInteger lastSection = [_dataSource numberOfSectionsInTableView:tableView] - 2; // -1 for new cell row
	NSUInteger lastRowInLastSection = [_dataSource tableView:tableView numberOfRowsInSection:lastSection] - 1;

	if (proposedDestinationIndexPath.section > lastSection) {
		idxPath = [NSIndexPath indexPathForRow:lastRowInLastSection inSection:lastSection];
	}
	return idxPath;
}

#pragma mark - Tracking the Removal of Views
#pragma mark - Copying and Pasting Row Content
#pragma mark - Managing Table View Highlighting
#pragma mark - Managing Table View Focus
#pragma mark -

@end
