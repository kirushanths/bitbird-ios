//
//  GameScene.m
//  bitbird-ios
//
//  Created by Kirushanth on 2014-02-10.
//  Copyright (c) 2014 BitGames. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"
#import "BGBird.h"
#import "BGConstants.h"

static const uint32_t heroCategory =  0x1 << 0;
static const uint32_t obstacleCategory =  0x1 << 1;
static const uint32_t pointCategory =  0x1 << 2;

static const float BG_VELOCITY = 100.0;
static const float OBJECT_VELOCITY = 170.0;

static const int START_DELAY = 3;

static const float OBSTACLE_TIME_INTERVAL = 0.6;
static const float FLOOR_HEIGHT = 118.0;
static const float OPENING_HEIGHT = 100.0;
static const float OPENING_PADDING = 70.0;

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}



@implementation GameScene {
	UIView *overlay;
	UIView *adView;
	
	UIImageView *background;
	UILabel *scoreboard;
	UILabel *instructions;
	UILabel *gameoverText;
	
	UIButton *replayButton;
	UIButton *rateButton;
	
	long score;
	
	BGBird *hero;
	
	SKAction *actionTouch;
	SKAction *actionDeath;
	
	SKAction *soundJump;
	SKAction *soundDeath;
	SKAction *soundScore;
	
	NSTimeInterval _lastUpdateTime;
	NSTimeInterval _dt;
	NSTimeInterval _lastObstacleAdded;
	
	BOOL gameStarted;
	BOOL gameOver;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
	{
        self.backgroundColor = [SKColor whiteColor];
		score = 0;
		
		soundJump = [SKAction playSoundFileNamed:@"jump.wav" waitForCompletion:NO];
		soundDeath = [SKAction playSoundFileNamed:@"gameover.wav" waitForCompletion:NO];
		soundScore = [SKAction playSoundFileNamed:@"coin.wav" waitForCompletion:NO];
    }
	
    return self;
}

- (void)didMoveToView:(SKView *)view
{
	overlay = [[UIView alloc] initWithFrame:self.frame];
	overlay.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4f];
	[self.view addSubview:overlay];
	
	scoreboard = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 150)];
	scoreboard.textAlignment = NSTextAlignmentCenter;
	scoreboard.textColor = [UIColor blackColor];
	scoreboard.font = [UIFont fontWithName:@"Fipps-Regular" size:35];
	scoreboard.text = @"0";
	[self.view addSubview:scoreboard];
	
	instructions = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	instructions.textAlignment = NSTextAlignmentCenter;
	instructions.textColor = [UIColor blackColor];
	instructions.font = [UIFont fontWithName:@"Fipps-Regular" size:20];
	instructions.text = @"TAP to START";
	[self.view addSubview:instructions];
	
	gameoverText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	gameoverText.textAlignment = NSTextAlignmentCenter;
	gameoverText.textColor = [UIColor blackColor];
	gameoverText.font = [UIFont fontWithName:@"Fipps-Regular" size:30];
	gameoverText.text = @"GAME OVER";
	gameoverText.hidden = YES;
	[self.view addSubview:gameoverText];
	
	float buttonHeight = 60;
	replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	replayButton.frame = CGRectMake(0, self.frame.size.height - buttonHeight, self.frame.size.width, buttonHeight);
	replayButton.backgroundColor = SE_COLOR_BLUE;
	[replayButton.titleLabel setFont:[UIFont fontWithName:@"Fipps-Regular" size:18]];
	[replayButton setTitle:@"Play Again" forState:UIControlStateNormal];
	[replayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	replayButton.hidden = YES;
	[replayButton addTarget:self action:@selector(startOver) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:replayButton];
	
	[self addSky];
	[self addFloor];
	[self addHero];
	
	self.physicsWorld.contactDelegate = self;
	self.physicsWorld.gravity = CGVectorMake(0, 0);
	self.physicsBody.friction = 0.0;
}

/* SETUP */

-(void)addHero
{
	//initalizing spaceship node
	hero = [BGBird createBird];
	[hero startAnimation];
    
	//Adding SpriteKit physicsBody for collision detection
	hero.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(hero.size.width / 2) - 3];
	hero.physicsBody.categoryBitMask = heroCategory;
	hero.physicsBody.dynamic = YES;
	hero.physicsBody.contactTestBitMask = obstacleCategory;
	hero.physicsBody.collisionBitMask = 0;
	hero.physicsBody.usesPreciseCollisionDetection = YES;
	hero.name = @"hero";
	hero.zPosition = 102;
	hero.position = CGPointMake(120,300);
	
	[self addChild:hero];
}

- (void)rotateHero
{
	float limit = 0.15;
 	float normalizedSpeed = hero.physicsBody.velocity.dy / 1000;
	normalizedSpeed = MIN(limit, normalizedSpeed);
	normalizedSpeed = MAX(-limit, normalizedSpeed);
	hero.zRotation = M_PI * normalizedSpeed;
}

-(void)addObstacle
{
    //initalizing spaceship node
    SKSpriteNode *top = [SKSpriteNode spriteNodeWithImageNamed:@"pipe.png"];
    SKSpriteNode *bottom = [SKSpriteNode spriteNodeWithImageNamed:@"pipe.png"];
    SKSpriteNode *point = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(50, OPENING_HEIGHT)];
    
	[top setZRotation:M_PI];
	
	top.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:top.size];
	bottom.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bottom.size];
	point.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:point.size];
	
	top.physicsBody.categoryBitMask = bottom.physicsBody.categoryBitMask = obstacleCategory;
	point.physicsBody.categoryBitMask = pointCategory;
	top.physicsBody.dynamic = bottom.physicsBody.dynamic = point.physicsBody.dynamic = NO;
	top.physicsBody.contactTestBitMask = bottom.physicsBody.contactTestBitMask = point.physicsBody.contactTestBitMask = heroCategory;
	top.physicsBody.collisionBitMask = bottom.physicsBody.collisionBitMask = point.physicsBody.collisionBitMask = 0;
	top.physicsBody.usesPreciseCollisionDetection = bottom.physicsBody.usesPreciseCollisionDetection = point.physicsBody.usesPreciseCollisionDetection = YES;
	top.name = bottom.name = point.name = @"obstacle";
    top.zPosition = bottom.zPosition = 100;
	point.zPosition = 99;
	
    //selecting random y position for missile
	int padding = OPENING_PADDING;
    int r = arc4random() % (int) (self.frame.size.height - FLOOR_HEIGHT - OPENING_HEIGHT - (padding * 2));
	
    bottom.position = CGPointMake(self.frame.size.width + 20, FLOOR_HEIGHT + padding + r - (bottom.size.height / 2));
	top.position = CGPointMake(self.frame.size.width + 20, bottom.position.y + OPENING_HEIGHT + top.size.height);
	point.position = CGPointMake(self.frame.size.width + 20, FLOOR_HEIGHT + padding + r + OPENING_HEIGHT / 2);
	
    [self addChild:top];
	[self addChild:bottom];
	[self addChild:point];
}

- (void)addFloor
{
	for (int i = 0; i < 2; i++) {
		SKSpriteNode *floor = [SKSpriteNode spriteNodeWithImageNamed:@"floor.png"];
		
		floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floor.size];
		floor.physicsBody.categoryBitMask = obstacleCategory;
		floor.physicsBody.dynamic = NO;
		floor.physicsBody.contactTestBitMask = heroCategory;
		floor.physicsBody.collisionBitMask = 0;
		floor.physicsBody.usesPreciseCollisionDetection = YES;
		floor.zPosition = 101;
		floor.name = @"floor";
		floor.anchorPoint = CGPointMake(0, 0.5);
		floor.position = CGPointMake(i * floor.size.width, floor.size.height / 2);
		
		[self addChild:floor];
	}
}

- (void)addSky
{
	SKSpriteNode *item = [SKSpriteNode spriteNodeWithImageNamed:@"sky.png"];
	item.zPosition = 90;
	item.anchorPoint = CGPointMake(0, 0);
	item.position = CGPointMake(0, self.frame.size.height - item.size.height);
	[self addChild:item];
}

- (void)moveObstacle
{
    NSArray *nodes = self.children;//1
    
    for(SKNode * node in nodes){
		if ([node.name isEqualToString:@"obstacle"]) {
            SKSpriteNode *ob = (SKSpriteNode *) node;
            CGPoint obVelocity = CGPointMake(-OBJECT_VELOCITY, 0);
            CGPoint amtToMove = CGPointMultiplyScalar(obVelocity,_dt);
            
            ob.position = CGPointAdd(ob.position, amtToMove);
            if(ob.position.x < -100)
            {
                [ob removeFromParent];
            }
        }
    }
}

- (void)moveFloor
{
    [self enumerateChildNodesWithName:@"floor" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-OBJECT_VELOCITY, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
     }];
}

/* TOUCH */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([self isGameRunning]) {
		hero.physicsBody.velocity = CGVectorMake(0, 300);
		[hero runAction:soundJump];
	} else if (!gameOver) {
		[self startGame];
	}
}

-(void)update:(CFTimeInterval)currentTime {
    
    if (_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
	if ([self isGameRunning]) {
		
		if (_lastObstacleAdded == 0)
			_lastObstacleAdded = currentTime + START_DELAY;
		
		if(currentTime - _lastObstacleAdded > OBSTACLE_TIME_INTERVAL)
		{
			_lastObstacleAdded = currentTime + OBSTACLE_TIME_INTERVAL;
			[self addObstacle];
		}
		
		[self moveFloor];
		[self moveObstacle];
		[self rotateHero];
	}
}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
	
	if ((firstBody.categoryBitMask & heroCategory) != 0 &&
        (secondBody.categoryBitMask & pointCategory) != 0)
	{
		[self addScore];
	}
    
    if ((firstBody.categoryBitMask & heroCategory) != 0 &&
        (secondBody.categoryBitMask & obstacleCategory) != 0)
    {
        [self finishGame];
    }
}

- (void)startGame
{
	gameStarted = YES;
	self.physicsWorld.gravity = CGVectorMake(0,-5);
	instructions.hidden = YES;
	overlay.hidden = YES;
}

- (void)finishGame
{
	[hero runAction:soundDeath completion:^{
		[hero stopAnimation];
//		SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.5];
//		SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
//		[self.view presentScene:gameOverScene transition:reveal];
	}];
	self.physicsWorld.gravity = CGVectorMake(0, 0);
	hero.physicsBody.velocity = CGVectorMake(0, 0);
	overlay.hidden = NO;
	gameoverText.hidden = NO;
	replayButton.hidden = NO;
	rateButton.hidden = NO;
	gameOver = YES;
}

- (void)startOver
{
	[overlay removeFromSuperview];
	[gameoverText removeFromSuperview];
	[replayButton removeFromSuperview];
	[rateButton removeFromSuperview];
	[instructions removeFromSuperview];
	[scoreboard removeFromSuperview];
	[background removeFromSuperview];
	[adView removeFromSuperview];
	
	SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.5];
	GameOverScene * scene = [GameOverScene sceneWithSize:self.view.bounds.size];
	scene.scaleMode = SKSceneScaleModeAspectFill;
	[self.view presentScene:scene transition:reveal];
}

- (void)addScore
{
	[hero runAction:soundScore];
	score++;
	scoreboard.text = [NSString stringWithFormat:@"%ld", score];
}

- (BOOL)isGameRunning
{
	return gameStarted && !gameOver;
}

- (void)showAdvert
{
	if (adView) {
		[adView removeFromSuperview];
	}
	adView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
	adView.backgroundColor = [UIColor blackColor];
	
	ADBannerView *bannerAd = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
	bannerAd.delegate = self;
	[adView addSubview:bannerAd];
	
	[self.view addSubview:adView];
}

#pragma mark - Ad Delegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;
{
	NSLog(@"Banner Error %@", [error localizedDescription]);
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	
}

@end
