//
//  GameLayer.h
//  Highway
//
//  Created by Lei, Wilson on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Car.h"
#import "Box2D.h"
#import "GB2ShapeCache.h"
#import "MyContactListener.h"

@interface GameLayer : CCLayer
{
    CCSprite *background;
    b2World *_world;
    b2Body *_groundBody;
    ccTime nextCar;
    ccTime delayBetweenCar;
    MyContactListener *_contactListener;
}
+(CCScene *) scene;
-(void) initPhysics;
-(void) generateRandomCars: (ccTime) dt;
@end
