//
//  PSPreferencesModule.h
//  ProtocolSnatcher
//
//  Created by Hirotsugu Asari on 2/14/08.
//  Copyright 2008 Hirotsugu Asari. All rights reserved.
//

#import "ProtocolSnatcher.h"

@interface PSPreferencesModule: NSPreferencesModule
{
	IBOutlet NSTextField *versionStringField;

	IBOutlet NSTableView *rulesTableView;
	IBOutlet NSPanel *helpPanel;
	IBOutlet WebView *helpContent;
	IBOutlet NSButton *removeButoon;
	
	NSMutableArray *rules;
	/* rules is an array of dictionaries, each dictionary representing a rule */
	BOOL _canRemove;
}

- (IBAction) addRewriteRule: (id) sender;
- (IBAction) removeRewriteRule: (id) sender;
- (IBAction) showHelpWindow: (id) sender;

- (IBAction) open: (id) sender;
- (void) openPanelDidEnd: (NSOpenPanel *)openPanel returnCode: (int)returnCode contextInfo: (void *)x;

- (IBAction) save: (id) sender;
- (void)savePanelDidEnd:(NSSavePanel *)savePanel returnCode:(int)returnCode  contextInfo:(void  *)x;

/* NSTableDataSource methods */
/* http://developer.apple.com/documentation/Cocoa/Reference/ApplicationKit/Protocols/NSTableDataSource_Protocol/Reference/Reference.html */
//- (int) numberOfRowsInTableView: (NSTableView *)aTableView;
//- (id) tableView: (NSTableView *)aTableView objectValueForTableColumn: (NSTableColumn *)aTableColumn row:(int)rowIndex;
//- (void) tableView: (NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
//- (void) tableView: (NSTableView *)aTableView setObjectValue: (id)anObject forTableColumn: (NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
//- (BOOL) tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard;
//- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation;
//- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation;

@end
