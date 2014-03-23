//
//  TRPTripCreationView.m
//  Tripster
//
//  Created by Brian Gerstle on 3/22/14.
//  Copyright (c) 2014 UMiami. All rights reserved.
//

#import "TRPTripCreationView.h"

@interface TRPTripCreationView ()
@property (nonatomic, strong) UITextField *locationField;
@property (nonatomic, strong) UIButton *createPlaylistButton;
@property (nonatomic, strong) UISegmentedControl *filterTypeSelect;
@end

@implementation TRPTripCreationView
@synthesize tabView, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        isGenre = false;
        
        artistModel = [[ArtistModel alloc] init];
        [artistModel setDelegate:self];
        tripmodel = [TRPMutableTripModel getTripModel];
        
        self.locationField = [[UITextField alloc] init];
        [self.locationField setDelegate:self];
        self.locationField.borderStyle = UITextBorderStyleRoundedRect;
        self.locationField.placeholder = @"Location";
        [self addSubview:self.locationField];
        
        NSArray *itemArray = [NSArray arrayWithObjects:@"Artist", @"Genre", nil];
        self.filterTypeSelect = [[UISegmentedControl alloc] initWithItems:itemArray];
        self.filterTypeSelect.selectedSegmentIndex = 0;
        [self.filterTypeSelect addTarget:self action:@selector(changeFilterType:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.filterTypeSelect];
        
        self.createPlaylistButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.createPlaylistButton addTarget:self action:@selector(createPlaylist:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.createPlaylistButton];
        
        selectedArtistsOrGenres = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.filterTypeSelect.selectedSegmentIndex == 0)
        return [[tripmodel artistIDs] count];
    else if (self.filterTypeSelect.selectedSegmentIndex == 1)
        return [queriedGenres count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *identifier;
    NSString *cellText;
    
    // Check for a reusable cell first, use that if it exists
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // If there is no reusable cell of this type, create a new one
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    if (self.filterTypeSelect.selectedSegmentIndex == 0)
        cellText = [[[tripmodel artistIDs] objectAtIndex:indexPath.row] objectForKey:@"name"];
    else if (self.filterTypeSelect.selectedSegmentIndex == 1)
        cellText = [queriedGenres objectAtIndex:indexPath.row];
    else
        cellText = @"";
    
    [[cell textLabel] setText:cellText];
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
    

    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        // remove from selectedArtists
        [selectedArtistsOrGenres removeObjectIdenticalTo:[cell.textLabel text]];
        
    } else {
        if ([selectedArtistsOrGenres count] < 5) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            // add to selectedArtists
            [selectedArtistsOrGenres addObject:[cell.textLabel text]];
        }
    }
    [cell setSelected:NO];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;

    CGRect locationFieldFrame = CGRectInset(self.bounds, 40, 0);
    locationFieldFrame.size.height = 30;
    locationFieldFrame.origin.y = 20;
    self.locationField.frame = locationFieldFrame;
    
    self.createPlaylistButton.frame = CGRectMake(0.0, height - 50.0, width, locationFieldFrame.size.height);
    [self.createPlaylistButton setTitle:@"Create Playlist" forState:UIControlStateNormal];
    
    CGFloat bottomOfLocField = self.locationField.frame.origin.y + self.locationField.frame.size.height + 10;
    self.filterTypeSelect.frame = CGRectMake((width - self.locationField.frame.size.width)/2.0, bottomOfLocField, self.locationField.frame.size.width, 30);
    
    tabView = [[UITableView alloc] init];
    tabView.dataSource = self;
    tabView.delegate = self;
    CGFloat bottomOfTypeSel = self.filterTypeSelect.frame.origin.y + self.filterTypeSelect.frame.size.height + 10;
    tabView.frame = CGRectMake(0.0, bottomOfTypeSel, width, self.createPlaylistButton.frame.origin.y - bottomOfTypeSel - 10);
    [self addSubview:tabView];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField{
    self.locationField.placeholder = nil;
}

//when clicking the return button in the keybaord
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO; // We do not want UITextField to insert line-breaks.
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

    [artistModel createArtistsModelforLocation:textField.text];
    [tripmodel setLocation:textField.text];
}

- (void)changeFilterType:(UISegmentedControl *)sender
{
    isGenre = !isGenre;
    [tabView reloadData];
}

-(void)didReceiveArtistModel:(NSArray *)artists AndGeneratedGenres:(NSArray *)genres withMessage:(NSString *)message{
    NSLog(@" Artist Array %@",artists);
    [tripmodel setArtistIDs:nil];
    [tripmodel setArtistIDs:[artists mutableCopy]];
    [queriedGenres removeAllObjects];
    queriedGenres = [genres mutableCopy];
    [tabView reloadData];
}

-(void)createPlaylist:(id)sender{
    // TODO: Genres.
    [tripmodel setIsGenre:isGenre];
    [tripmodel setChosenSeeds:[selectedArtistsOrGenres copy]];
//    for (NSString *string in [tripmodel chosenSeeds]) {
//        NSLog(@"Copied: %@",string);
//    }
//    
//    NSLog(@"filterTypeSelect shows: %d", [[self filterTypeSelect] selectedSegmentIndex]);
    
    [delegate pushNextVC];
}
@end
