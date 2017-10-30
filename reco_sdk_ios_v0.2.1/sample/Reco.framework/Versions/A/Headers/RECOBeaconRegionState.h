//
//  RECOBeaconState.h
//  Copyright (c) 2014 Perples. All rights reserved.
//

#ifndef reco_sdk_RECOBeaconRegionState_h
#define reco_sdk_RECOBeaconRegionState_h

/**
 현재 위치와 region의 경계선 간의 관계를 나타내는 상수.
 */
typedef NS_ENUM(NSInteger, RECOBeaconRegionState) {
    /** 현재 해당 region의 안에 있는지 밖에 있는지 알 수 없음.
     */
    RECOBeaconRegionUnknown,
    /** 현재 해당 region의 내부에 있음.
     */
    RECOBeaconRegionInside,
    /** 현재 해당 region의 외부에 있음.
     */
    RECOBeaconRegionOutside,
};

#endif
