#import "UFSGenericTableViewDataSource.h"

#include "common.h"

// Internal keys
NSString const *sectionsKey = @"sections";
NSString const *rowsKey = @"rows";
// Section keys
NSString const *canEditRowsKey = @"canEditRows";
NSString const *canMoveRowsKey = @"canMoveRows";
NSString const *hideIndexTitlesKey = @"hideIndexTitles";
NSString const *titleForHeaderKey = @"titleForHeader";
NSString const *hideHeadersKey = @"hideHeaders";
NSString const *titleForFooterKey = @"titleForFooter";
NSString const *hideFootersKey = @"hideFooters";

// New cell keys
NSString const *newCellKey = @"newCell";

// Row keys
NSString const *styleKey = @"style";
NSString const *textKey = @"text";
NSString const *detailTextKey = @"detailText";

@interface UFSGenericTableViewDataSource () {
    id _data_p;
}
@end

@implementation UFSGenericTableViewDataSource

#pragma mark - Initializers

- (id)init {
	return [self initWithDictionary:[NSMutableDictionary dictionary]];
}

- (id)initWithContentsOfFile:(NSString *)path {
	return [self initWithDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:path]];
}

- (id)initWithContentsOfURL:(NSURL *)aURL {
	return [self initWithDictionary:[NSMutableDictionary dictionaryWithContentsOfURL:aURL]];
}

- (id)initWithDictionary:(NSDictionary *)aDictionary {
	if ((self = [super init])) {
		_data = (NSMutableDictionary *)CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)aDictionary, kCFPropertyListMutableContainers);
	}
	return self;
}

- (void)dealloc {
	[_data release];
	_data = nil;

	[_data release];
	_data = nil;

	[super dealloc];
}

#pragma mark - Storing

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag {
	return [_data writeToFile:path atomically:flag];
}

- (BOOL)writeToURL:(NSURL *)aURL atomically:(BOOL)flag {
	return [_data writeToURL:aURL atomically:flag];
}

#pragma mark - State Management

- (void)saveState {
	[_data_p release];
	_data_p = _data;
	_data = (NSMutableDictionary *)CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)_data_p, kCFPropertyListMutableContainers);
}

- (void)restoreState {
	[_data release];
	_data = _data_p;
	_data_p = nil;
}

#pragma mark - Get/Set

- (void)setObject:(id)object forKey:(id <NSCopying>)key {
	[_data setObject:object forKey:key];
}

- (id)objectForKey:(NSString *)key {
	return [_data objectForKey:key];
}

#pragma mark - Sections

- (NSInteger)numberOfSections {
	return [[self objectForKey:sectionsKey] count];
}

- (NSDictionary *)sectionForIndex:(NSInteger)sectionIndex {
	if (sectionIndex == [self numberOfSections]) {
		return [[self objectForKey:newCellKey] objectAtIndex:0];
	}

	@try {
		return [[self objectForKey:sectionsKey] objectAtIndex:sectionIndex];
	}
	@catch (NSException *exception) {
		return nil;
	}
}

- (NSMutableArray *)rowsInSection:(NSInteger)sectionIndex {
	return [[self sectionForIndex:sectionIndex] objectForKey:rowsKey];
}

- (void)addSection:(NSDictionary *)section {
	[[self objectForKey:sectionsKey] addObject:section];
}

- (void)removeSectionAtIndex:(NSInteger)sectionIndex {
	[[self objectForKey:sectionsKey] removeObjectAtIndex:sectionIndex];
}

- (NSArray *)sectionIndexTitles {
	if ([[self objectForKey:hideIndexTitlesKey] boolValue]) {
		return nil;
	}

	NSMutableArray *indexTitles = [NSMutableArray arrayWithCapacity:[self numberOfSections]];
	for (int section = 0; section < [self numberOfSections]; section++) {
		NSString *indexTitle = [[self sectionForIndex:section] objectForKey:titleForHeaderKey];
		if ([indexTitle length] > 0) {
			[indexTitles addObject:[indexTitle substringToIndex:1]];
		} else {
			[indexTitles addObject:@""];
		}
	}
	return indexTitles;
}

- (BOOL)hideTitleForHeaderInSection:(NSInteger)section {
	NSNumber *value = [self inheritedObjectForKey:hideHeadersKey atIndexPath:[NSIndexPath indexPathForRow:-1 inSection:section]];
	return (value) ? [value boolValue] : YES;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
	return ([self hideTitleForHeaderInSection:section]) ? nil : [[self sectionForIndex:section] objectForKey:titleForHeaderKey];
}

- (BOOL)hideTitleForFooterInSection:(NSInteger)section {
	NSNumber *value = [self inheritedObjectForKey:hideFootersKey atIndexPath:[NSIndexPath indexPathForRow:-1 inSection:section]];
	return (value) ? [value boolValue] : YES;
}

- (NSString *)titleForFooterInSection:(NSInteger)section {
	return ([self hideTitleForFooterInSection:section]) ? nil : [[self sectionForIndex:section] objectForKey:titleForFooterKey];
}

#pragma mark - Rows

- (NSInteger)numberOfRowsInSection:(NSInteger)sectionIndex {
	return [[self rowsInSection:sectionIndex] count];
}

- (NSDictionary *)rowAtIndexPath:(NSIndexPath *)indexPath {
	@try {
		return [[self rowsInSection:indexPath.section] objectAtIndex:indexPath.row];
	}
	@catch (NSException *exception) {
		return nil;
	}
}

- (void)addRow:(NSDictionary *)row toSection:(NSInteger)sectionIndex {
	[[self rowsInSection:sectionIndex] addObject:row];
}

- (void)removeRowAtIndexPath:(NSIndexPath *)indexPath {
	[[self rowsInSection:indexPath.section] removeObjectAtIndex:indexPath.row];
}

- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == [self numberOfSections]) {
		return YES;
	}

	NSNumber *value = [self inheritedObjectForKey:canEditRowsKey atIndexPath:indexPath];
	return (value) ? [value boolValue] : YES;
}

- (BOOL)canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == [self numberOfSections]) {
		return NO;
	}

	NSNumber *value = [self inheritedObjectForKey:canMoveRowsKey atIndexPath:indexPath];
	return (value) ? [value boolValue] : YES;
}

- (void)moveRowAtIndexPath:(NSIndexPath *)srcIndexPath toIndexPath:(NSIndexPath *)dstIndexPath {
	NSMutableArray *srcRowsData = [self rowsInSection:srcIndexPath.section];
	NSMutableArray *dstRowsData = [self rowsInSection:dstIndexPath.section];

	NSDictionary *rowDict = [[srcRowsData objectAtIndex:srcIndexPath.row] retain];
	[srcRowsData removeObjectAtIndex:srcIndexPath.row];
	[dstRowsData insertObject:rowDict atIndex:dstIndexPath.row];
	[rowDict release];
}

- (id)inheritedObjectForKey:(id)key atIndexPath:(NSIndexPath *)indexPath {
	id value = [[self rowAtIndexPath:indexPath] objectForKey:key];
	if (value) {
		return value;
	}

	value = [[self sectionForIndex:indexPath.section] objectForKey:key];
	if (value) {
		return value;
	}

	return [self objectForKey:key];
}

#pragma mark - Cells
#define UFSGenericTableViewCell void
- (UFSGenericTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UITableViewCellStyle)cellStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSNumber *obj = [self inheritedObjectForKey:styleKey atIndexPath:indexPath];
	if (obj) {
		return (UITableViewCellStyle)[obj integerValue];
	}

	return UITableViewCellStyleSubtitle;
}

- (void)setText:(NSString *)text forRowAtIndexPath:(NSIndexPath *)indexPath {
	[(NSMutableDictionary *)[self rowAtIndexPath:indexPath] setObject:text forKey:textKey];
}
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self inheritedObjectForKey:textKey atIndexPath:indexPath];
}

- (void)setDetailText:(NSString *)detailText forRowAtIndexPath:(NSIndexPath *)indexPath {
    [(NSMutableDictionary *)[self rowAtIndexPath:indexPath] setObject:detailText forKey:detailTextKey];
}
- (NSString *)detailTextForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self inheritedObjectForKey:detailTextKey atIndexPath:indexPath];
}

////////////////////////////////////////////////////////////////////////////

#pragma mark - UITableViewDataSource Protocol

// Configuring a Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self numberOfSections] + (int)tableView.isEditing;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self numberOfRowsInSection:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return [self sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [[self sectionIndexTitles] indexOfObject:title];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self titleForHeaderInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [self titleForFooterInSection:section];
}

// Inserting or Deleting Table Rows

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self canEditRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (editingStyle) {
	case UITableViewCellEditingStyleDelete:
		[self removeRowAtIndexPath:indexPath];
		[tableView beginUpdates];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
		[tableView endUpdates];
        break;

	case UITableViewCellEditingStyleInsert:
        UIAlert(@"Unimplemented", nil);
        break;

	case UITableViewCellEditingStyleNone:
        break;
	}
}

// Reordering Table Rows

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self canMoveRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	[self moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

// New cell

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"BaseCell";

	UITableViewCellStyle style = [self cellStyleForRowAtIndexPath:indexPath];

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
	}

	cell.textLabel.text = [self textForRowAtIndexPath:indexPath];
    //cell.textLabel.textColor = [UIColor redColor];
    //cell.textLabel.font = [UIFont systemFontOfSize:12]; //[UIFont fontWithName:font size:cell.textLabel.font.pointSize];
	if (indexPath.section == [self numberOfSections]) {
		return cell;
	}

	cell.detailTextLabel.text = [self detailTextForRowAtIndexPath:indexPath];
	//cell.detailTextLabel.textColor = [UIColor redColor];
	//cell.detailTextLabel.font = [UIFont systemFontOfSize:12];

	//cell.imageView.image = [UIImage imageNamed:@"img.jpg"];

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
#if defined __IPHONE_3_0 && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_0
	cell.editingAccessoryView = nil;
#else
	cell.hidesAccessoryWhenEditing = YES;
#endif
	cell.showsReorderControl = YES;

	return cell;
}

@end
