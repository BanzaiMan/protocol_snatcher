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

- (void) awakeFromNib
{
    [versionStringField setObjectValue: [[NSBundle bundleWithIdentifier:@"net.asari.murlr"] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    rules = [[ NSMutableArray alloc ] init ];

    [helpPanel setHidesOnDeactivate: YES];
    [helpPanel setReleasedWhenClosed: NO];
    const NSSize prefFrameSize = NSMakeSize(650.0f,513.0f);
    [self setMinSize: prefFrameSize];
    [_preferencesView setFrameSize: prefFrameSize];
    [rulesTableView reloadData];
    [rulesTableView setAllowsColumnReordering: NO];
    [removeButoon setEnabled: NO];
    [rulesTableView registerForDraggedTypes:[NSArray arrayWithObject: MyPrivateTableViewDataType]];

}

- (IBAction) addRewriteRule: (id) sender
{
    // a new rule with default values
    NSMutableDictionary *newRule = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        @"", @"matchRegex", @"", @"replaceText", @"",@"shareToMount", nil ];

    [rules addObject:newRule];
    [rulesTableView reloadData];
    // select the newly created row...
    [rulesTableView selectRowIndexes: [NSIndexSet indexSetWithIndex:([rules count] -1)] byExtendingSelection:NO];
    // and edit the first column
    [rulesTableView editColumn: [rulesTableView columnWithIdentifier:@"matchRegex"] row:([rules count] -1) withEvent:nil select:YES];

}

- (IBAction) removeRewriteRule: (id) sender
{
    if ([rulesTableView selectedRow] < 0) return; // make sure selected row is sane
    if ([rules count] > 0) {
        [rules removeObjectAtIndex:[rulesTableView selectedRow]];
        [rulesTableView reloadData];
    }
    [[NSUserDefaults standardUserDefaults] setObject:rules forKey:@"URLRewriteRules"];
}

- (IBAction) showHelpWindow: (id) sender
{
    NSString *bundleResourcePath = [[NSBundle bundleWithIdentifier:@"net.asari.murlr"] resourcePath];
    [[helpContent mainFrame] loadRequest: [NSURLRequest requestWithURL:
    [NSURL fileURLWithPath: [bundleResourcePath stringByAppendingPathComponent: @"help.html"]]]];
    [helpPanel makeKeyAndOrderFront:sender];
}

#pragma mark -
#pragma mark for NSTableView class and NSTableDataSource protocol
- (int) numberOfRowsInTableView: (NSTableView *)aTableView
{
    return [rules count];
}

- (id) tableView: (NSTableView *)aTableView
    objectValueForTableColumn: (NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
    NSMutableDictionary *rule = [NSMutableDictionary dictionaryWithDictionary: [rules objectAtIndex:rowIndex]];
    return ([rule objectForKey:[aTableColumn identifier]]);
}

- (void) tableView: (NSTableView *) aTableView
    setObjectValue: (id) anObject
    forTableColumn: (NSTableColumn *) aTableColumn
    row: (int) rowIndex
{
    NSMutableDictionary *rule = [NSMutableDictionary dictionaryWithDictionary: [rules objectAtIndex:rowIndex]];
    [rule setObject:anObject forKey:[aTableColumn identifier]];
    [rules replaceObjectAtIndex:rowIndex withObject:rule];
    [[NSUserDefaults standardUserDefaults] setObject:rules forKey:@"URLRewriteRules"];
    [aTableView reloadData];
}

- (BOOL) control: (NSControl *)control textShouldEndEditing: (NSText *)fieldEditor
{
    
    if (![control isKindOfClass:[NSTableView class]]) return YES;

    NSTableView *aTableView = (NSTableView *)control;
    if ([aTableView editedColumn] != [aTableView columnWithIdentifier: @"matchRegex"]) return YES;
    
    @try {
        OGRegularExpression *regex = [OGRegularExpression regularExpressionWithString:[fieldEditor string]];
    }
    @catch (NSException *e) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Invalid Regular Expression"
                                         defaultButton:@"Edit"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:[NSString stringWithFormat:@"String \"%@\" is not a valid regular expression.\nReason: %@",[fieldEditor string], e]];
        [alert beginSheetModalForWindow:[aTableView window]
                          modalDelegate:nil
                         didEndSelector:nil
                            contextInfo:nil];
        return NO;
    }
    
    return YES;
}

- (void) tableViewSelectionDidChange: (NSNotification *)aNotification
{
    [removeButoon setEnabled: [[rulesTableView selectedRowIndexes] count] == 1];
}

- (void)tableViewColumnDidResize:(NSNotification *)aNotification
{
    //	NSLog(@"table column was resized");
    //	NSTableColumn *editedColumn = [[aNotification userInfo] objectForKey:@"NSTableColumn"];
    //	NSNumber *oldWidth = [[aNotification userInfo] objectForKey:@"NSOldWidth"];
    //	NSLog(@"table column %@ was resized from %4.2f to %4.2f", [editedColumn identifier], [oldWidth floatValue], [editedColumn width]);
}

#pragma mark -
#pragma mark Drag and Drop
- (BOOL) tableView:(NSTableView *)aTableView
    writeRowsWithIndexes:(NSIndexSet *)rowIndexes
    toPasteboard:(NSPasteboard *)pboard
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:MyPrivateTableViewDataType] owner:self];
    [pboard setData:data forType:MyPrivateTableViewDataType];

    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info
    proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard   *pboard = [info draggingPasteboard];
    NSData*        rowData = [pboard dataForType:MyPrivateTableViewDataType];
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    int            dragRow = [rowIndexes firstIndex];

    // ignore this drag unless it is a copy to an acceptable row
    if ( operation != NSDragOperationCopy || row == dragRow || row == dragRow + 1 ) return NSDragOperationNone;
    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation
{
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
/*
 * GUI Methods
 */

/* Image to display in the preferences toolbar */
- (NSImage *) imageForPreferenceNamed:(NSString *)_name
{
    NSString* path = [[ProtocolSnatcherBundle bundle] pathForImageResource: @"MURLR" ];
    return [[NSImage alloc] initWithContentsOfFile: path];
}

/* Override to return the name of the relevant nib */
- (NSString *) preferencesNibName
{
    return @"PSPreferences";
}

//- (NSSize) minSize {
//    return NSMakeSize( 650.0f, 450.0f  );
//}

//- (void) didChange {
//}

- (NSView*) viewForPreferenceNamed:(NSString *)aName
{
    // In NIB, set File Owner to this module, and set outlet _preferencesView to NSBox
    if ( ! _preferencesView ) [NSBundle loadNibNamed: [self preferencesNibName] owner:self];
    [_preferencesView setNeedsDisplay:YES];
    return _preferencesView;
}

/* Called when switching preference panels. */
//- (void) willBeDisplayed {
//}

///* Called when window closes or "save" button is clicked. */
//- (void) saveChanges {
//    NSLog(@"in saveChanges...");
//}

//- (BOOL) hasChangesPending {
//    NSLog(@"in hasChangesPending: %d", _hasChanges);
//	return _hasChanges;
//}

/* Called when we relinquish ownership of the preferences panel. */
//- (void)moduleWillBeRemoved {
//}

/* Called after willBeDisplayed, once we "own" the preferences panel. */
//- (void)moduleWasInstalled {
//}

//- (BOOL)moduleCanBeRemoved
//{
//    NSLog(@"in moduleCanBeRemoved");
//    if ([self hasChangesPending]) return NO;
//    return YES;
//}
//
//- (BOOL)preferencesWindowShouldClose
//{
//    NSLog(@"in preferencesWindowShouldClose");
//    return YES;
//}

- (void)dealloc
{
    [rules release];
    [super dealloc];
}

- (void) initializeFromDefaults
{
    [super initializeFromDefaults];
    [rules removeAllObjects];
    id anObject;

    NSMutableArray *rulesArray = [[NSUserDefaults standardUserDefaults] objectForKey: @"URLRewriteRules"];

    for (anObject in rulesArray)
    {
        [rules addObject:anObject];
    }
}

#pragma mark -
#pragma mark Custom Methods
- (IBAction) open:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    NSString *directory = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"URLRewriterLastDirectory"];
    if (!directory) directory = NSHomeDirectory();
    [openPanel beginSheetForDirectory: directory
                                 file: nil
                                types: [NSArray arrayWithObject:@"plist"]
                       modalForWindow: [rulesTableView window]
                        modalDelegate: self
                       didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:)
                          contextInfo: NULL];    
}

- (void) openPanelDidEnd: (NSOpenPanel *)openPanel returnCode: (int)returnCode contextInfo: (void *)x
{
    if (returnCode != NSOKButton) return;
    
    NSString *rulesFilePath = [[openPanel filenames] objectAtIndex:0];
    NSData *rawData;
    NSString *error;
    NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
    
    [[NSUserDefaults standardUserDefaults] setObject:[rulesFilePath stringByDeletingLastPathComponent] forKey:@"URLRewriterLastDirectory"];
    
    NSMutableArray *rulesArray = [NSMutableArray array];
    
    id plist;
    
    rawData = [NSData dataWithContentsOfFile:rulesFilePath];
    
    plist = [NSPropertyListSerialization propertyListFromData:rawData
                                             mutabilityOption:NSPropertyListImmutable
                                                       format:&format
                                             errorDescription:&error];
    if (![plist isKindOfClass:[NSArray class]] || [plist count] == 0) {
          [[NSAlert alertWithMessageText:@"" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""]runModal];
          return;
    }
    
    id aRule;
    int numBadRules = 0;
    int numGoodRules = 0;
    for ( aRule in plist ) {
        if (![aRule isKindOfClass:[NSDictionary class]]) {
            ++numBadRules;
            continue;
        }
        NSString *matchRegex   = [aRule objectForKey:@"matchRegex"];
        NSString *replaceText  = [aRule objectForKey:@"replaceText"];
        NSString *shareToMount = [aRule objectForKey:@"shareToMount"];
        if ( matchRegex == nil || replaceText == nil || shareToMount == nil ) {
            ++numBadRules;
            continue;
        }
        [rulesArray addObject: aRule];
        ++numGoodRules;
    }
    
    [rules addObjectsFromArray: rulesArray];
    /*
    [[NSAlert alertWithMessageText:@"Import complete"
                    defaultButton:@"OK" alternateButton:nil otherButton:nil
        informativeTextWithFormat:[NSString stringWithFormat:@"Imported %d rules and rejected %d rules",numGoodRules,numBadRules]]runModal];
    */
    [rulesTableView reloadData];
}

- (IBAction) save: (id) sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    NSString *directory = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"URLRewriterLastDirectory"];
    if (!directory) directory = NSHomeDirectory();
    [savePanel beginSheetForDirectory: directory
                                 file: @"rules.plist"
                       modalForWindow: [rulesTableView window]
                        modalDelegate: self
                       didEndSelector: @selector(savePanelDidEnd:returnCode:contextInfo:)
                          contextInfo: NULL];
}

- (void)savePanelDidEnd:(NSSavePanel *)savePanel returnCode:(int)returnCode  contextInfo:(void  *)x
{
    if (returnCode != NSOKButton) return;
    
    NSString *exportFilePath = [savePanel filename];
    NSData *exportData;
    NSString *error;
    
    [[NSUserDefaults standardUserDefaults] setObject:[savePanel directory] forKey:@"URLRewriterLastDirectory"];
    exportData = [NSPropertyListSerialization dataFromPropertyList:rules format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    if (exportData) {
        [exportData writeToFile: exportFilePath atomically: YES];
    } else {
        NSLog(error);
        [error release];
    }
}

@end