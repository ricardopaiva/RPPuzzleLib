//
//  ViewController.m
//  RPPuzzle
//
//  Created by Ricardo Paiva on 28/12/14.
//  Copyright (c) 2014 Ricardo Paiva. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet RPPuzzleView *puzzleView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *word = @"Sara";
    
    UIImage *catImage = [UIImage imageNamed:@"cat"];
    [self.puzzleView setWord:word image:catImage];
//    [self.puzzleView setHorizontalPieces:[word length] verticalPieces:1];
    [self.puzzleView setHorizontalPieces:2 verticalPieces:1];
    
    [self.puzzleView refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RPPuzzleView delegate methods

- (void)didFinishPuzzle
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GOOD" message:@"Boa!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

@end
