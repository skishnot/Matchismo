//
//  CardGame.m
//  Matchismo
//
//  Created by Karl Lee on 2013-02-27.
//  Copyright (c) 2013 Karl Lee. All rights reserved.
//

#import "CardGame.h"

@interface CardGame ()
@property (readwrite, nonatomic) int score;
@property (strong, nonatomic) NSMutableArray *cards; // of Card
@property (readwrite, nonatomic) NSString *flipResult;
@end

@implementation CardGame

- (NSMutableArray *)cards
{
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

#define MATCH_BONUS 4
#define MISMATCH_PENALTY 2
#define FLIP_COST 1
- (void)flipCardAtIndex:(NSUInteger)index
{
    // flipped a card
    Card *card = [self cardAtIndex:index];
    NSLog(@"Flipped %@", card.contents);
    self.flipResult = [NSString stringWithFormat:@"Flipped %@", card.contents];
    
    // there is a card, and it is playable
    if (card && !card.isUnplayable) {
        
        // and the card is face down
        if (!card.isFaceUp) {
            
            // then look through other cards
            for (Card *otherCard in self.cards) {
                
                // and for each Other Card that is face up and playable
                if (otherCard.isFaceUp && !otherCard.isUnplayable) {
                    
                    // see if it is a match
                    int matchScore = [card match:@[otherCard]];
                    if (matchScore) {
                        
                        // if yes, both cards are now unplayable
                        card.unplayable = YES;
                        otherCard.unplayable = YES;
                        self.score += matchScore * MATCH_BONUS;
                        NSLog(@"Matched. %@ & %@ for %d points.", card.contents, otherCard.contents, matchScore * MATCH_BONUS);
                        self.flipResult = [NSString stringWithFormat:@"%@ & %@ are a match! Gained %d points.", card.contents, otherCard.contents, matchScore * MATCH_BONUS];
                    } else {
                        
                        // if no, then penalty is applied
                        otherCard.faceUp = NO;
                        self.score -= MISMATCH_PENALTY;
                        NSLog(@"Not a match. %@ & %@ for -%d points.", card.contents, otherCard.contents, MISMATCH_PENALTY);
                        self.flipResult = [NSString stringWithFormat:@"%@ & %@ are not a match. Lost %d points.", card.contents, otherCard.contents, MISMATCH_PENALTY];
                    }
                    // for loop is broken if either happens
                    break;
                }
            }
            
            // subtract 1 point for flipping a card
            self.score -= FLIP_COST;
        }
        
        // then the card is turned face down
        card.faceUp = !card.isFaceUp;
    }
}

- (Card *)cardAtIndex:(NSUInteger)index
{
    return (index < [self.cards count]) ? self.cards[index] : nil;
}

- (id)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck
{
    self = [super init];
    
    if (self) {
        for (int i = 0; i < count; i++) {
            Card *card = [deck drawRandomCard];
            if (card) {
                self.cards[i] = card; // lazy instantiation
            } else {
                self = nil;
                break;
            }
        }
    }
    
    return self;
}

@end
