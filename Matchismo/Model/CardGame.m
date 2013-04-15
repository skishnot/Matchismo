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
    if (!self.isMatch3mode) {
        [self match2logic:index];
    } else {
        [self match3logic:index];
    }
}

- (void)match2logic:(NSUInteger)index
{
    // flip a card #1, report
    Card *card = [self cardAtIndex:index];
    NSLog(@"Flipped %@", card.contents);
    self.flipResult = [NSString stringWithFormat:@"Flipped %@", card.contents];
    
    // if it is playable
    if (!card.isUnplayable) {
        
        // and the card is face down
        if (!card.isFaceUp) {
            
            // then "flip" the card, and subtract 1 point for flipping a card
            card.faceUp = !card.isFaceUp;
            self.score -= FLIP_COST;
            
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
                        
                        // calculate the score, then report
                        self.score += matchScore * MATCH_BONUS;
                        NSLog(@"Matched. %@ & %@ for %d points.", card.contents, otherCard.contents, matchScore * MATCH_BONUS);
                        self.flipResult = [NSString stringWithFormat:@"%@ & %@ are a match! Gained %d points.", card.contents, otherCard.contents, matchScore * MATCH_BONUS];
                        
                    } else {
                        
                        // if no, flip down the Other Crad, penalty is applied, then report
                        otherCard.faceUp = NO;
                        self.score -= MISMATCH_PENALTY;
                        NSLog(@"Not a match. %@ & %@ for -%d points.", card.contents, otherCard.contents, MISMATCH_PENALTY);
                        self.flipResult = [NSString stringWithFormat:@"%@ & %@ are not a match. Lost %d points.", card.contents, otherCard.contents, MISMATCH_PENALTY];
                    }
                    
                    // for loop is broken if a card was found
                    break;
                }
            }
        }
    }
}

- (void)match3logic:(NSUInteger)index
{
    // define card #1, then check if it's playable and face down
    Card *card1 = [self cardAtIndex:index];
    if (!card1.isUnplayable && !card1.isFaceUp) {
        
        // then "flip" the card, and subtract 1 point for flipping a card
        card1.faceUp = !card1.isFaceUp;
        self.score -= FLIP_COST;
        NSLog(@"Flipped %@", card1.contents);
        self.flipResult = [NSString stringWithFormat:@"Flipped %@", card1.contents];
        
        // then look for card2
        Card *card2 = [self findCard2Using:card1];
        if (card2) {
            NSLog(@"Flipped %@ and %@", card1.contents, card2.contents);
            self.flipResult = [NSString stringWithFormat:@"Flipped %@ and %@", card1.contents, card2.contents];
        }

        // then look for card3
        Card *card3 = [self findCard3Using:card1 and:card2];
        if (card3) {
            NSLog(@"Flipped %@, %@, and %@", card1.contents, card2.contents, card3.contents);
        }
        
        // then calculate the match score depending on the quality of the match
        int matchScore = [self findMatchScoreUsing:card1 :card2 and:card3];
        
        // then reset the card values for the next round
        
            for (Card *card2 in self.cards) {
                
                // if there is a card (that we call "card2") that is face up and playable
                if (card2.isFaceUp && !card2.isUnplayable) {
                    
                    // report first
                    NSLog(@"Flipped %@ and %@", card1.contents, card2.contents);
                    self.flipResult = [NSString stringWithFormat:@"Flipped %@ and %@", card1.contents, card2.contents];
                    
                    //then look through other cards for card3
                    
                    // then see if it is a match
                    int matchScore = [card match:@[otherCard]];
                    if (matchScore) {
                        
                        // if yes, both cards are now unplayable
                        card.unplayable = YES;
                        otherCard.unplayable = YES;
                        
                        // calculate the score, then report
                        self.score += matchScore * MATCH_BONUS;
                        NSLog(@"Matched. %@ & %@ for %d points.", card.contents, otherCard.contents, matchScore * MATCH_BONUS);
                        self.flipResult = [NSString stringWithFormat:@"%@ & %@ are a match! Gained %d points.", card.contents, otherCard.contents, matchScore * MATCH_BONUS];
                        
                    } else {
                        
                        // if no, flip down the Other Crad, penalty is applied, then report
                        otherCard.faceUp = NO;
                        self.score -= MISMATCH_PENALTY;
                        NSLog(@"Not a match. %@ & %@ for -%d points.", card.contents, otherCard.contents, MISMATCH_PENALTY);
                        self.flipResult = [NSString stringWithFormat:@"%@ & %@ are not a match. Lost %d points.", card.contents, otherCard.contents, MISMATCH_PENALTY];
                    }
                    
                    // for loop is broken if a card was found
                    break;
                }
            }
        }
    }
}

- (Card *)findCard2Using:(Card *)card1
{
    Card *card2 = nil;
    
    // go through the cards for potential card2 candidate
    for (int i = 0; i < [self.cards count]; i++) {
        Card *potentialCard2 = self.cards[i];
        
        // it has to be face up, playable, and not card1
        if (potentialCard2.isFaceUp && !potentialCard2.isUnplayable && !card1) {
            
            // if found, assign it to card2, then break
            card2 = self.cards[i];
            break;
        }
    }
    
    return card2;
}

- (Card *)findCard3Using:(Card *)card1 and:(Card *)card2
{
    Card *card3 = nil;
    
    // go through the cards for potential card2 candidate
    for (int i = 0; i < [self.cards count]; i++) {
        Card *potentialCard3 = self.cards[i];
        
        // it has to be face up, playable, and not card1
        if (potentialCard3.isFaceUp && !potentialCard3.isUnplayable && !card1 && !card2) {
            
            // if found, assign it to card2, then break
            card3 = self.cards[i];
            break;
        }
    }
    
    return card3;
}

- (int)findMatchScoreUsing:(Card *)card1 :(Card *)card2 and:(Card *)card3
{
    
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

- (void)reset
{
    self.score = 0;
    self.flipResult = @"Matchismo!";
}

@end
