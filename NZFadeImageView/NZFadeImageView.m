//
//  NZFadeImageView.m
//  NZFadeImageView
//
//  Created by Bruno Furtado on 19/12/13.
//  Copyright (c) 2013 No Zebra Network. All rights reserved.
//

#import "NZFadeImageView.h"

static const int kAnimateInterval = 20;
static const float kAnimateDuration = .7f;
static NSString* const kResource = @"NZFadeImageView-Images";


@interface NZFadeImageView ()

@property (strong, nonatomic) NSMutableArray *names;
@property (nonatomic, strong) NSTimer *timer;

- (void)animate;

- (void)setAnimateInterval:(CGFloat)animateInterval
                  animated:(BOOL)animated;

- (void)startAnimationAnimated;


@end



@implementation NZFadeImageView

#pragma mark -
#pragma mark - UIImageView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.names = [[NSMutableArray alloc] init];
                
        NSString *path = [[NSBundle mainBundle] pathForResource:kResource ofType:@"plist"];
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
        
        for (NSString *name in array) {
            [self.names addObject:[UIImage imageNamed:name]];
        }
        
        [self setAnimateInterval:kAnimateInterval];
        [self setAnimateDuration:kAnimateDuration];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_global_queue(0, 0),
        ^{
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(startAnimationAnimated)
                                                         name:UIApplicationDidBecomeActiveNotification
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(stopAnimation)
                                                         name:UIApplicationWillResignActiveNotification
                                                       object:nil];
        });
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setAnimateInterval:0];
    [self setAnimationDuration:0];
    [self setNames:nil];
    [self setTimer:nil];
}

#pragma mark -
#pragma mark - Public methods

- (void)setAnimateInterval:(CGFloat)animateInterval
{
    [self setAnimateInterval:animateInterval animated:NO];
    
}

- (void)startAnimation
{
    [self setAnimateInterval:_animateInterval];
}

- (void)stopAnimation
{
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
    }
}

#pragma mark -
#pragma mark - Private methods

- (void)animate
{
    for (int i = 0; i < [self.names count]; i++) {
        UIImage *image = [self.names objectAtIndex:i];
        float plusFinalAnimateDuration = self.animateDuration/2;
        
        if ([self.image isEqual:image]) {
            int nextIndex = i+1;
            
            if (nextIndex >= [self.names count]) {
                nextIndex = 0;
            }
            
            [UIView animateWithDuration:self.animateDuration animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.image = [self.names objectAtIndex:nextIndex];
                    
                    [UIView animateWithDuration:self.animateDuration + plusFinalAnimateDuration animations:^{
                        self.alpha = 1;
                    }];
                }
            }];
            
            [NSThread sleepForTimeInterval:(self.animateDuration*2) + plusFinalAnimateDuration];
            
            break;
        }
    }
}

- (void)setAnimateInterval:(CGFloat)animateInterval animated:(BOOL)animated
{
    _animateInterval = animateInterval;
    
    [self stopAnimation];
    
    if (animated) {
        [self animate];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_animateInterval
                                                  target:self
                                                selector:@selector(animate)
                                                userInfo:nil
                                                 repeats:YES];
    
}

- (void)startAnimationAnimated
{
    [self setAnimateInterval:_animateInterval animated:YES];
}

@end