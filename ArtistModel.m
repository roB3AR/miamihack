//
//  ArtistModel.m
//  Tripster
//
//  Created by Andrew Ayers on 3/22/14.
//  Copyright (c) 2014 UMiami. All rights reserved.
//

#import "ArtistModel.h"

@implementation ArtistModel

@synthesize delegate;

-(id)init
{
    self = [super init];
    if(self){
        // Perform Custom init here
    }
    return self;
}


-(void)createArtistsModelforLocation:(NSString *)location{
    
    //[self init];
    [ENAPI initWithApiKey:kEchoNestAPIKey
              ConsumerKey:kEchoNestConsumerKey
          AndSharedSecret:kEchoNestSharedSecret];
    
    
    NSString *endPoint = @"artist/search";
    request = [ENAPIRequest requestWithEndpoint:endPoint];
    [request setDelegate:self];
    [request setValue:location forParameter:@"artist_location"];
    
    NSArray *bucket = [[NSArray alloc] initWithObjects: @"genre", @"hotttnesss", @"discovery", @"artist_location", nil];
    [request setValue:bucket forParameter:@"bucket"];
    [request setIntegerValue:50 forParameter:@"results"];
    // [request setValue:[NSNumber numberWithInt:25] forParameter:@"results"];
    [request setValue:@"hotttnesss-desc" forParameter:@"sort"];
    //[request startAsynchronous]; This should work, and the methods should be here to make it, but it doesn't! Help needed here.
    [request startAsynchronous];

}

-(void)requestFinished:(ENAPIRequest *)request{
    //Artist request
    NSDictionary *response = [[request response] objectForKey:@"response"];
    
    if(request.responseStatusCode == 200){ // Successful query
        
        NSLog(@"Successful query");
        NSArray *artists = [response objectForKey:@"artists"];
        if([artists count] > 0){ // Valid Area
            for(NSDictionary *artist in artists){
                NSLog(@"Artist: %@", [artist objectForKey:@"name"]);
                NSDictionary *location = [artist objectForKey:@"artist_location"];
                NSLog(@"City: %@", [location objectForKey:@"city"]); // To get the artist's location. may be more specific than search                
            }
            [self didReceiveArtistModel:artists withMessage:@"success"];
        } else{
            NSLog(@"Invalid Area");
            [self didReceiveArtistModel:nil withMessage:@"invalid area"];
        }
    }
}

-(void)requestFailed:(ENAPIRequest *)request{
    //Error Handling for failed artist request
    [self didReceiveArtistModel:nil withMessage:@"request failed"];
}

#pragma mark protocol methods

-(void)didReceiveArtistModel:(NSArray *)artists withMessage:(NSString *)message{
    
    NSMutableDictionary *allGenres = [[NSMutableDictionary alloc] init];
    for(NSDictionary *artist in artists){
        NSLog(@"Artist: %@", [artist objectForKey:@"name"]);
        NSDictionary *location = [artist objectForKey:@"artist_location"];
        NSLog(@"City: %@", [location objectForKey:@"city"]); // To get the artist's location. may be more specific than search.
        NSDictionary *genresForArtist = [artist objectForKey:@"genres"];
        for(NSDictionary *genre in genresForArtist){
            NSString *genr = [genre objectForKey:@"name"];
            if([allGenres objectForKey:genr]){
                int count = [[allGenres objectForKey:genr] integerValue];
                [allGenres setObject:[NSNumber numberWithInt:++count] forKey:genr];
            } else{ // add it
                [allGenres setObject:[NSNumber numberWithInt:1] forKey:genr];
            }
        }
    }
    
    NSArray *sortedGenres;
    
    sortedGenres = [allGenres keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] > [obj2 integerValue]) {
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    NSArray* topGenres;
    
    if([sortedGenres count] < 20){
        topGenres = sortedGenres;
    } else{
        for(int i = 0; i < 20; i++){
            [temp addObject:[sortedGenres objectAtIndex:i]];
        }
        topGenres = [NSArray arrayWithArray:temp];
    }
    
    if([delegate respondsToSelector:@selector(didReceiveArtistModel:AndGeneratedGenres:withMessage:)]){
        [delegate didReceiveArtistModel:artists AndGeneratedGenres:topGenres withMessage:message];
    }
}
@end
