//
//  PSPreferencesModule.m
//  ProtocolSnatcher
//
//  Created by Hirotsugu Asari on 2/14/08.
//  Copyright 2008 Hirotsugu Asari. All rights reserved.
//
/* This is the data source for an NSTableView */

#import "PSPreferencesModule.h"

@implementation PSPreferencesModule

- (void) awakeFromNib {
	[versionStringField setObjectValue: [[NSBundle bundleWithIdentifier:@"net.asari.murlr"] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	rules = [[ NSMutableArray alloc ] init ];
	
	[self readRewriteRules];
	[helpPanel setHidesOnDeactivate: YES];
	[helpPanel setReleasedWhenClosed: NO];
	const NSSize prefFrameSize = NSMakeSize(650.0f,450.0f);
	[self setMinSize: prefFrameSize];
	[_preferencesView setFrameSize: prefFrameSize];
	[rulesTableView reloadData];
	[rulesTableView setAllowsColumnReordering: NO];
	[removeButoon setEnabled: NO];
	[rulesTableView registerForDraggedTypes:[NSArray arrayWithObject: MyPrivateTableViewDataType]];
	
}

- (IBAction) addRewriteRule: (id) sender {
	// a new rule with default values
	NSMutableDictionary *newRule = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		@"regular expression", @"matchRegex",
		@"", @"replaceText",
		@"cifs://",@"shareToMount",
		nil
	];
	
	[rules addObject:newRule];
	[rulesTableView reloadData];
	// select the newly created row...
	[rulesTableView selectRowIndexes: [NSIndexSet indexSetWithIndex:([rules count] -1)] byExtendingSelection:NO];
	// and edit the first column
	[rulesTableView editColumn: 0 row:([rules count] -1) withEvent:nil select:YES];

}

- (IBAction) removeRewriteRule: (id) sender {
	if ([rulesTableView selectedRow] < 0) return; // make sure selected row is sane
	if ([rules count] > 0) {
		[rules removeObjectAtIndex:[rulesTableView selectedRow]];
		[rulesTableView reloadData];
	}
	[[NSUserDefaults standardUserDefaults] setObject:rules forKey:@"URLRewriteRules"];
}

- (IBAction) showHelpWindow: (id) sender {
//	NSLog(@"showHelpWindow: %@", [helpPanel windowController]);
	NSString *bundleResourcePath = [[NSBundle bundleWithIdentifier:@"net.asari.murlr"] resourcePath];
	[[helpContent mainFrame] loadRequest: [NSURLRequest requestWithURL:
	 [NSURL fileURLWithPath: [bundleResourcePath stringByAppendingString: @"/help.html"]]]];
	[helpPanel makeKeyAndOrderFront:sender];
}

#pragma mark -
#pragma mark for NSTableView class and NSTableDataSource protocol
- (int) numberOfRowsInTableView: (NSTableView *)aTableView {
	return [rules count];
}

- (id)          tableView: (NSTableView *)aTableView
objectValueForTableColumn: (NSTableColumn *)aTableColumn
					  row:(int)rowIndex {
	NSMutableDictionary *rule = [NSMutableDictionary dictionaryWithDictionary: [rules objectAtIndex:rowIndex]];
	return ([rule objectForKey:[aTableColumn identifier]]);
}

- (void) tableView: (NSTableView *) aTableView
	setObjectValue: (id) anObject
	forTableColumn: (NSTableColumn *) aTableColumn
			   row: (int) rowIndex {
	// TODO: compile regular expressions before setting the object value
	NSMutableDictionary *rule = [NSMutableDictionary dictionaryWithDictionary: [rules objectAtIndex:rowIndex]];
	[rule setObject:anObject forKey:[aTableColumn identifier]];
	[rules replaceObjectAtIndex:rowIndex withObject:rule];
	[[NSUserDefaults standardUserDefaults] setObject:rules forKey:@"URLRewriteRules"];
	[rulesTableView reloadData];
}

- (void) tableViewSelectionDidChange: (NSNotification *)aNotification {
	if ([aNotification name] != NSTableViewSelectionDidChangeNotification) {
		NSLog(@"Received a notification other than NSTableViewSelectionDidChangeNotification");
		return;
	}
	
	if ([[rulesTableView selectedRowIndexes] count] == 1) {
		[removeButoon setEnabled:YES];
	} else {
		[removeButoon setEnabled:NO];
	}
}

#pragma mark -
#pragma mark Drag and Drop
- (BOOL)   tableView:(NSTableView *)aTableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
		toPasteboard:(NSPasteboard *)pboard {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	[pboard declareTypes:[NSArray arrayWithObject:MyPrivateTableViewDataType] owner:self];
	[pboard setData:data forType:MyPrivateTableViewDataType];
	
	return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView
				validateDrop:(id < NSDraggingInfo >)info
				 proposedRow:(NSInteger)row
	   proposedDropOperation:(NSTableViewDropOperation)operation {
	NSPasteboard   *pboard = [info draggingPasteboard];
	NSData*        rowData = [pboard dataForType:MyPrivateTableViewDataType];
	NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	int            dragRow = [rowIndexes firstIndex];

	// ignore this drag unless it is a copy to an acceptable row
	if ( operation != NSDragOperationCopy || row == dragRow || row == dragRow + 1 ) return NSDragOperationNone;
	return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)aTableView
	   acceptDrop:(id < NSDraggingInfo >)info
			  row:(NSInteger)row
	dropOperation:(NSTableViewDropOperation)operation {
	NSPasteboard *pboard = [info draggingPasteboard];
	NSData* rowData = [pboard dataForType:MyPrivateTableViewDataType];
	NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	int dragRow = [rowIndexes firstIndex];  // row index of the dragged row

	NSMutableDictionary *aRule = [rules objectAtIndex:dragRow];
	[rules insertObject:aRule atIndex:row];
	if (row <= dragRow) {
		// rule is dragged up
		[rules removeObjectAtIndex:dragRow + 1];
	} else {
		// rule is dragged down
		[rules removeObjectAtIndex:dragRow];
	}
	[[NSUserDefaults standardUserDefaults] setObject:rules forKey:@"URLRewriteRules"];
	[rulesTableView reloadData];
	return YES;
}

#pragma mark -
- (void)tableViewColumnDidResize:(NSNotification *)aNotification {
//	NSLog(@"table column was resized");
//	NSTableColumn *editedColumn = [[aNotification userInfo] objectForKey:@"NSTableColumn"];
//	NSNumber *oldWidth = [[aNotification userInfo] objectForKey:@"NSOldWidth"];
//	NSLog(@"table column %@ was resized from %4.2f to %4.2f", [editedColumn identifier], [oldWidth floatValue], [editedColumn width]);
}

/*
 * GUI Methods
 */

/* Image to display in the preferences toolbar */
- (NSImage *) imageForPreferenceNamed:(NSString *)_name {
    NSString* path = [[ProtocolSnatcherBundle bundle] pathForImageResource: @"MURLR" ];
    return [[NSImage alloc] initWithContentsOfFile: path];
}

/* Override to return the name of the relevant nib */
- (NSString *) preferencesNibName {
	return @"PSPreferences";
}

//- (NSSize) minSize {
//    return NSMakeSize( 650.0f, 450.0f  );
//}

//- (void) didChange {
//}

- (NSView*) viewForPreferenceNamed:(NSString *)aName {
	// In NIB, set File Owner to this module, and set outlet _preferencesView to NSBox
	if ( ! _preferencesView ) [NSBundle loadNibNamed: [self preferencesNibName] owner:self];
	[_preferencesView setNeedsDisplay:YES];
	return _preferencesView;
}

/* Called when switching preference panels. */
//- (void) willBeDisplayed {
//}

/* Called when window closes or "save" button is clicked. */
//- (void) saveChanges {
//}

/* Not sure how useful this is, so far always seems to return YES. */
//- (BOOL) hasChangesPending {
//	return YES;
//}

/* Called when we relinquish ownership of the preferences panel. */
//- (void)moduleWillBeRemoved {
//}

/* Called after willBeDisplayed, once we "own" the preferences panel. */
//- (void)moduleWasInstalled {
//}

//- (void)initializeFromDefaults {
//	[super initializeFromDefaults];
//}

- (BOOL)moduleCanBeRemoved {
	return YES;
}

- (BOOL)preferencesWindowShouldClose {
	return YES;
}

- (void)dealloc {
	[rules release];
	[super dealloc];
}

- (void) readRewriteRules {
	[rules removeAllObjects];
	id anObject;
	
	NSMutableArray *rulesArray = [[NSUserDefaults standardUserDefaults] objectForKey: @"URLRewriteRules"];
	NSEnumerator   *enumerator = [rulesArray objectEnumerator];
	
	while (anObject = [enumerator nextObject])
	{
		[rules addObject:anObject];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject: rules forKey: @"URLRewriteRules"];
}


@end