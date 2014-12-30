//
//  RPPuzzlePiece.m
//  Jogo das Palavras
//
//  Created by Ricardo Paiva on 20/12/14.
//
//

#import "RPPuzzlePiece.h"
#import <QuartzCore/QuartzCore.h>

static NSString *const nibNameKey = @"RPPuzzlePiece";

@interface RPPuzzlePiece()
//@property (weak, nonatomic) IBOutlet IBInspectable UIImageView *lockerImageView;

- (IBAction)buttonTouchUpInside:(id)sender;
@end


@implementation RPPuzzlePiece

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
//        [self commonInit];
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self commonInit];
        [self setup];
    }
    return self;
}

- (NSString *)nibName
{
    return nibNameKey;
}

#pragma mark - Public Methods

- (void)refresh
{
//    BOOL showLocker = [self.dataSource showLevelLockerInViewWithTag:self.tag];
//    [self.lockerImageView setAlpha:(showLocker ? 1 : 0)];
    
    [self setup];
}

#pragma mark - Private Methods


- (void)setup
{
    UIImage *image = nil;
    
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
//    switch (self.tag) {
//        case kGameSample:
//        {
//            [self.numberLabel setText:@""];
//            [self.textLabel setText:NSLocalizedString(@"SAMPLE", nil)];
//            image = [UIImage imageNamed:@"ls_letter_btn_green"];
//            break;
//        }
//        case kGameAllWords:
//        {
//            [self.numberLabel setText:@""];
//            [self.textLabel setText:NSLocalizedString(@"ALLWORDS", nil)];
//            image = [UIImage imageNamed:@"ls_letter_btn_orange"];
//            break;
//        }
//        case kGame3Letters:
//        {
//            [self.numberLabel setText:@"3"];
//            [self.textLabel setText:NSLocalizedString(@"LETTERS", nil)];
//            image = [UIImage imageNamed:@"ls_letter_btn_red"];
//            break;
//        }
//        case kGame4Letters:
//        {
//            [self.numberLabel setText:@"4"];
//            [self.textLabel setText:NSLocalizedString(@"LETTERS", nil)];
//            image = [UIImage imageNamed:@"ls_letter_btn_purple"];
//            break;
//        }
//        case kGame5Letters:
//        {
//            [self.numberLabel setText:@"5"];
//            [self.textLabel setText:NSLocalizedString(@"LETTERS", nil)];
//            image = [UIImage imageNamed:@"ls_letter_btn_yellow"];
//            break;
//        }
//        case kGame6Letters:
//        {
//            [self.numberLabel setText:@"6"];
//            [self.textLabel setText:NSLocalizedString(@"LETTERS", nil)];
//            image = [UIImage imageNamed:@"ls_letter_btn_light_blue"];
//            break;
//        }
//        case kGame7Letters:
//        {
//            [self.numberLabel setText:@"7"];
//            [self.textLabel setText:NSLocalizedString(@"LETTERS", nil)];
//            image = [UIImage imageNamed:@"ls_letter_btn_dark_green"];
//            break;
//        }
//        case kGame8Letters:
//        {
//            [self.numberLabel setText:@"8"];
//            [self.textLabel setText:NSLocalizedString(@"LETTERS", nil)];
//            image = [UIImage imageNamed:@"ls_letter_btn_light_brown"];
//            break;
//        }
//        case kGame9Letters:
//        {
//            [self.numberLabel setText:@"9"];
//            [self.textLabel setText:NSLocalizedString(@"LETTERS", nil)];
//            image = [UIImage imageNamed:@"ls_letter_btn_dark_brown"];
//            break;
//        }
//        default:
//            NSAssert(NO, @"Invalid game level");
//            break;
//    }
//    
//    [self.backgroundButton setBackgroundImage:image forState:UIControlStateNormal];
    
}


- (IBAction)buttonTouchUpInside:(id)sender {
//    [self.delegate didPressButtonWithTag:self.tag];
}
@end
