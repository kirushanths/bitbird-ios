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
static const uint32_t floorCategory =  0x1 << 2;

static const float BG_VELOCITY = 100.0;
static const float OBJECT_VELOCITY = 160.0;

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
		
		soundJump = [SKAction playSoundFileNamed:@"jump.wav" waitForCompletion:NO];
		
        [self initalizingScrollingBackground];
        [self addHero];
		[self addFloor];
		
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
    }
	
    return self;
}

/* SETUP */

-(void)addHero
{
	//initalizing spaceship node
	hero = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
	[hero setScale:0.5];
	hero.zRotation = - M_PI / 2;
    
	//Adding SpriteKit physicsBody for collision detection
	hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hero.size];
	hero.physicsBody.categoryBitMask = heroCategory;
	hero.physicsBody.dynamic = YES;
	hero.physicsBody.contactTestBitMask = obstacleCategory;
	hero.physicsBody.collisionBitMask = 0;
	hero.physicsBody.usesPreciseCollisionDetection = YES;
	hero.name = @"hero";
	hero.position = CGPointMake(120,300);
	
	[self addChild:hero];
}

-(void)addObstacle
{
    //initalizing spaceship node
    SKSpriteNode *missile;
    missile = [SKSpriteNode spriteNodeWithImageNamed:@"red-missile.png"];
    [missile setScale:0.15];
    
    //Adding SpriteKit physicsBody for collision detection
    missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.size];
    missile.physicsBody.categoryBitMask = obstacleCategory;
    missile.physicsBody.dynamic = YES;
    missile.physicsBody.contactTestBitMask = heroCategory;
    missile.physicsBody.collisionBitMask = 0;
    missile.physicsBody.usesPreciseCollisionDetection = YES;
    missile.name = @"obstacle";
    
    //selecting random y position for missile
    int r = arc4random() % 300;
    missile.position = CGPointMake(self.frame.size.width + 20,r);
	
    [self addChild:missile];
}

- (void)addFloor
{
    SKSpriteNode *item;
	item = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:CGSizeMake(320, 120)];
//    item = [SKSpriteNode spriteNodeWithImageNamed:@"red-missile.png"];
    
    //Adding SpriteKit physicsBody for collision detection
    item.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:item.size];
    item.physicsBody.categoryBitMask = obstacleCategory;
    item.physicsBody.dynamic = NO;
    item.physicsBody.contactTestBitMask = heroCategory;
    item.physicsBody.collisionBitMask = 0;
    item.physicsBody.usesPreciseCollisionDetection = YES;
    item.name = @"floor";

    item.position = CGPointMake(item.size.width / 2, item.size.height / 2);
	
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
		if( currentTime - _lastObstacleAdded > 1)
		{
			_lastObstacleAdded = currentTime + 1;
			//		[self addObstacle];
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
        (secondBody.categoryBitMask & obstacleCategory) != 0)
    {
        [hero removeFromParent];
        SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
        [self.view presentScene:gameOverScene transition:reveal];
		
    }
}

- (void)startGame
{
	gameStarted = YES;
	self.physicsWorld.gravity = CGVectorMake(0,-4);
}

- (BOOL)isGameRunning
{
	return gameStarted && !gameOver;
}

@end
