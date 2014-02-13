//
//  GameScene.m
//  bitbird-ios
//
//  Created by Kirushanth on 2014-02-10.
//  Copyright (c) 2014 BitGames. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"

static const uint32_t heroCategory =  0x1 << 0;
static const uint32_t obstacleCategory =  0x1 << 1;
static const uint32_t pointCategory =  0x1 << 2;

static const float BG_VELOCITY = 100.0;
static const float OBJECT_VELOCITY = 170.0;

static const float OBSTACLE_TIME_INTERVAL = 0.6;
static const float FLOOR_HEIGHT = 100.0;
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
	UIImageView *background;
	UILabel *scoreboard;
	
	long score;
	
	SKSpriteNode *floor;
	SKSpriteNode *hero;
	
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
	scoreboard = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 150)];
	scoreboard.textAlignment = UITextAlignmentCenter;
	scoreboard.textColor = [UIColor blackColor];
	scoreboard.font = [UIFont systemFontOfSize:30.0f];
	scoreboard.text = @"0";
	[self.view addSubview:scoreboard];
	
	[self initalizingScrollingBackground];
	[self addHero];
	[self addFloor];
	
	self.physicsWorld.contactDelegate = self;
	self.physicsWorld.gravity = CGVectorMake(0, 0);
}

/* SETUP */

-(void)addHero
{
	//initalizing spaceship node
	hero = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
	[hero setScale:0.25];
	hero.zRotation = - M_PI / 2;
    
	//Adding SpriteKit physicsBody for collision detection
	hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hero.size];
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

-(void)addObstacle
{
    //initalizing spaceship node
    SKSpriteNode *top = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(50, 1000)];
    SKSpriteNode *bottom = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(50, 1000)];
    SKSpriteNode *point = [SKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:CGSizeMake(50, OPENING_HEIGHT)];
    
	[bottom setZRotation:2 * M_PI];
	
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
	floor = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:CGSizeMake(320, FLOOR_HEIGHT)];
//    item = [SKSpriteNode spriteNodeWithImageNamed:@"red-missile.png"];
    
    //Adding SpriteKit physicsBody for collision detection
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floor.size];
    floor.physicsBody.categoryBitMask = obstacleCategory;
    floor.physicsBody.dynamic = NO;
    floor.physicsBody.contactTestBitMask = heroCategory;
    floor.physicsBody.collisionBitMask = 0;
    floor.physicsBody.usesPreciseCollisionDetection = YES;
	floor.zPosition = 101;
    floor.name = @"floor";

    floor.position = CGPointMake(floor.size.width / 2, floor.size.height / 2);
	
    [self addChild:floor];
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

-(void)initalizingScrollingBackground
{
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        [self addChild:bg];
    }
}

- (void)moveBg
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY, 0);
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
		hero.physicsBody.velocity = CGVectorMake(0, 250);
		[hero runAction:soundJump];
	} else {
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
		if( currentTime - _lastObstacleAdded > OBSTACLE_TIME_INTERVAL)
		{
			_lastObstacleAdded = currentTime + OBSTACLE_TIME_INTERVAL;
			[self addObstacle];
		}
		
		[self moveBg];
		[self moveObstacle];
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
	self.physicsWorld.gravity = CGVectorMake(0,-4);
}

- (void)finishGame
{
	[hero runAction:soundDeath completion:^{
//		SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.5];
//		SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
//		[self.view presentScene:gameOverScene transition:reveal];
	}];
	self.physicsWorld.gravity = CGVectorMake(0, 0);
	hero.physicsBody.velocity = CGVectorMake(0, 0);
	gameOver = YES;
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

@end
