//
//  RECOProximity.h
//  Copyright (c) 2014 Perples. All rights reserved.
//

#ifndef reco_sdk_RECOProximity_h
#define reco_sdk_RECOProximity_h

/**
 RECOBeacon 까지의 상대적인 거리를 나타내는 상수.
 */
typedef NS_ENUM(NSInteger, RECOProximity) {
    /** 해당 beacon에 대한 proximity가 결정될 수 없음.
     */
    RECOProximityUnknown,
    /** 해당 beacon이 바로 가까이에 있음.
     */
    RECOProximityImmediate,
    /** 해당 beacon이 근처에 있음.
     */
    RECOProximityNear,
    /** 해당 beacon이 멀리 떨어져 있음.
     */
    RECOProximityFar
};

#endif
