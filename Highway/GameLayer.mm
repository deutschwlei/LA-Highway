//
//  GameLayer.m
//  Highway
//
//  Created by Lei, Wilson on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"

#define PTM_RATIO 32

@implementation GameLayer
-(id)init{
    if(self = [super init]){
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"car-body.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"highway.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"car.plist"];
        
        [self initPhysics];
        
        background = [CCSprite spriteWithSpriteFrameName:@"highway1.png"];
        [self addChild:background z:0];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(0,0);
        
        //[self generateRandomCars];
        nextCar = 0.5f;
        delayBetweenCar = 0.2f;
        srand(time(NULL));
        [self schedule:@selector(tick:)];
        [self schedule:@selector(generateRandomCars:)];
    }
    return self;
}

-(void) generateRandomCars: (ccTime) dt
{
    nextCar -= dt;
    if(nextCar <=0)
    {
        //generate 1 car on the right side
        //get a random color car
        int i = rand()%6+1;
        
        //get a random position
        int rpx = rand()%118 + 186;
        int rpy = -50;
        int forceDir = 1;

        //get a random force
        int rf = floor((rand()%30+50)/2) * forceDir;
        
        
        Car *aCar = [[Car alloc]initWithSpriteFrameName:[NSString stringWithFormat:@"car%i.png", i]];
        [self addChild:aCar z:1];
        aCar.position = ccp(rpx,rpy);
        aCar.tag = 1;
        
        //the car body
        b2BodyDef carBodyDef;
        carBodyDef.type = b2_dynamicBody;
        carBodyDef.position.Set(aCar.position.x/PTM_RATIO, aCar.position.y/PTM_RATIO);
        carBodyDef.userData = aCar;
        b2Body *carBody = _world->CreateBody(&carBodyDef);
        
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:carBody forShapeName:@"car1"];
        [aCar setAnchorPoint:[[GB2ShapeCache sharedShapeCache]anchorPointForShape:@"car1"]];
        
        //give car a impulse
        b2Vec2 force = b2Vec2(0,rf);
        carBody->ApplyLinearImpulse(force, carBodyDef.position);
        //carBody->ApplyForceToCenter(force);
        
        //generate 1 car on the left side
        //get a random color car
        i = rand()%6+1+10;
        
        //get a random position
        rpx = rand()%108+16;
        rpy = 480+50;
        forceDir = -1.0f;
        
        //get a random force
        rf = floor((rand()%30+50)/2) * forceDir;
        
        
        Car *aLeftCar = [[Car alloc]initWithSpriteFrameName:[NSString stringWithFormat:@"car%i.png", i]];
        [self addChild:aLeftCar z:1];
        aLeftCar.position = ccp(rpx,rpy);
        aLeftCar.tag = 1;
        
        //the car body
        b2BodyDef carBodyDef2;
        carBodyDef2.type = b2_dynamicBody;
        carBodyDef2.position.Set(aLeftCar.position.x/PTM_RATIO, aLeftCar.position.y/PTM_RATIO);
        carBodyDef2.userData = aLeftCar;
        b2Body *carBody2 = _world->CreateBody(&carBodyDef2);
        
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:carBody2 forShapeName:@"car11"];
        [aLeftCar setAnchorPoint:[[GB2ShapeCache sharedShapeCache]anchorPointForShape:@"car11"]];
        
        //give car a impulse
        b2Vec2 force2 = b2Vec2(0,rf);
        carBody2->ApplyLinearImpulse(force2, carBodyDef2.position);
        
        
        nextCar = rand()%4*0.1+delayBetweenCar;
    }
}

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
	_world = new b2World(gravity);
	
    //add contact listener
    _contactListener = new MyContactListener();
    _world->SetContactListener(_contactListener);
	
	// Do we want to let bodies sleep?
	_world->SetAllowSleeping(true);
	
	_world->SetContinuousPhysics(true);
	
	//m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	//_world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	//m_debugDraw->SetFlags(flags);		
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = _world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
	
	//groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
	//groundBody->CreateFixture(&groundBox,0);
	
	// top
	//groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	//groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
    
    // two middle lines
    groundBox.Set(b2Vec2(160/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(160/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
    //groundBox.Set(b2Vec2(167/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(167/PTM_RATIO,0));
	//groundBody->CreateFixture(&groundBox,0);
    
    
}

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    GameLayer *layer = [GameLayer node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

- (void)removeBoom:(CCSprite *) aSprite{
    [self removeChild:aSprite cleanup:true];

}
- (void)tick:(ccTime) dt {
    _world->Step(dt, 10, 10);    
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {    
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *)b->GetUserData();                        
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO,
                                  b->GetPosition().y * PTM_RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
            //delete out of bound car
            if(sprite.position.y > 550 || sprite.position.y < -100){
                [self removeChild:sprite cleanup:true];
            }
        }
    }
    
    std::vector<b2Body *>toDestroy;
    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin();
        pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
            
            // Sprite A = ball, Sprite B = Block
            if (spriteA.tag == 1 && spriteB.tag == 1) {
                
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyB)
                    == toDestroy.end()) {
                    
                    CCSprite *boomSprite = [CCSprite spriteWithFile:@"boom2.png"];
                    boomSprite.position = spriteA.position;   
                    [self addChild: boomSprite];
                    id action1 = [CCFadeOut actionWithDuration:2.0f];
                    id action2 = [CCScaleTo actionWithDuration:0.5f scale:2.0f];
                    id action3 = [CCEaseOut actionWithAction:action2 rate:4];
                    
                    [boomSprite runAction:[CCSequence actions:action3,action1, [CCCallFuncN actionWithTarget:self selector:@selector(removeBoom:)], nil]];
                    
                    toDestroy.push_back(bodyB);
                }
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA)
                    == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                }
            }

        }
    }
    
    std::vector<b2Body *>::iterator pos2;
    for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
        b2Body *body = *pos2;
        if (body->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *) body->GetUserData();
            [self removeChild:sprite cleanup:YES];
        }
        _world->DestroyBody(body);
    }
}
@end
