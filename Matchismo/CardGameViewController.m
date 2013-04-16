//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Karl Lee on 2013-02-22.
//  Copyright (c) 2013 Karl Lee. All rights reserved.
//

#import "CardGameViewController.h"
#import "PlayingCardDeck.h"
#import "CardGame.h"

@interface CardGameViewController ()
@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
@property (nonatomic) int flipcount;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (strong, nonatomic) CardGame *game;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *flipResultLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gameLogicController;

@end

@implementation CardGameViewController

- (CardGame *)game
{
    if (!_game) _game = [[CardGame alloc] initWithCardCount:[self.cardButtons count]
                                                 usingDeck:[[PlayingCardDeck alloc] init]];
    return _game;
}

- (void)setCardButtons:(NSArray *)cardButtons
{
    _cardButtons = cardButtons;
    [self updateUI];
}

- (void)updateUI
{
    // make sure the UI matches the model. Also possibly send info to model
    for (UIButton *cardButton in self.cardButtons) {
        Card *card = [self.game cardAtIndex:[self.cardButtons indexOfObject:cardButton]];
        [cardButton setTitle:card.contents forState:UIControlStateSelected];
        [cardButton setTitle:card.contents forState:UIControlStateSelected|UIControlStateDisabled];
        cardButton.selected = card.isFaceUp;
        cardButton.enabled = card.isFaceUp ? NO : YES;
        cardButton.alpha = (card.isUnplayable ? 0.3 : 1.0);
    }
    self.flipResultLabel.text = [self.game flipResult];
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
    [self updateGameLogicSetting];
}

- (void)setFlipcount:(int)flipcount
{
    _flipcount = flipcount;
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", self.flipcount];
    NSLog(@"flip count updated to %d", self.flipcount);
}

- (IBAction)flipCard:(UIButton *)sender
{
    [self.game flipCardAtIndex:[self.cardButtons indexOfObject:sender]];
    self.flipcount++;
    self.gameLogicController.enabled = NO;
    [self updateUI];
}

- (IBAction)redeal {
    self.game = nil;
    [self.game reset];
    self.flipcount = 0;
    self.gameLogicController.enabled = YES;
    [self updateUI];
}

-(void)updateGameLogicSetting
{
    if (self.gameLogicController.selectedSegmentIndex == 0) {
        self.game.match3mode = NO;
    } else {
        self.game.match3mode = YES;
    }
}

- (IBAction)changeGameLogicSetting:(UISegmentedControl *)sender {
    [self updateGameLogicSetting];
}

@end
