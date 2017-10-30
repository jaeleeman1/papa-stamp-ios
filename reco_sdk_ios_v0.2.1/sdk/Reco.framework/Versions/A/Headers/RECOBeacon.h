//
//  RECOBeacon.h
//  Copyright (c) 2014 Perples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RECOProximity.h"
/**
 RECOBeacon 클래스는 region monitoring시에 발견되는 beacon을 나타냅니다. 사용자는 이 클래스의 인스턴스를 직접 생성하지 않습니다. RECOBeaconManager 객체가 연결된 delegate을 통해 beacon을 전달합니다. 전달받은 beacon의 정보를 활용해 어떤 beacon을 발견했는지 확인할 수 있습니다.

 beacon은 proximityUUID, major, minor 속성으로 구성됩니다. 
 */
typedef double RECOAccuracy;

@interface RECOBeacon : NSObject

/** Beacon의 Proximity ID. (읽기전용)
 */
@property (nonatomic, readonly) NSUUID* proximityUUID;

/** The most significant value in the beacon. (읽기전용)
 */
@property (nonatomic, readonly) NSNumber *major;

/** The least significant value in the beacon. (읽기전용)
 */
@property (nonatomic, readonly) NSNumber *minor;


/** Beacon까지의 상대적인 거리. (읽기전용)

  이 값은 beacon까지 일반적으로 얼마나 떨어져 있는지를 나타냅니다. 이 값을 통해 사용자로부터 상대적으로 가까운 beacon들을 찾아낼 수 있습니다.
 */
@property (nonatomic, readonly) RECOProximity proximity;

/** proximity 값의 정확도. Beacon으로부터 미터 단위로 표시. (읽기전용)

 미터 단위로 표시된 1 sigma (약 68%)의 정확도. 이 속성값으로 같은 proximity 값을 가지는 beacon들을 구분합니다. 각 beacon의 정확한 위치를 결정할 때에 이 값을 사용하지 마십시오. accuracy 값은 RF간섭에 의해 변할 수 있습니다.

 본 속성값은 RECO SDK에서 임의로 계산한 값이 아닌, iOS native library에서 제공하는 값입니다.
 */
@property (nonatomic, readonly) RECOAccuracy accuracy;

/** Beacon 신호의 세기. 단위 데시벨 (decibel). (읽기전용)

 어플리케이션이 beacon을 감지한 순간부터 받은 RSSI 신호값의 평균입니다.

 본 속성값은 RECO SDK에서 임의로 계산한 값이 아닌, iOS native library에서 제공하는 값입니다.
 */
@property (nonatomic, readonly) NSInteger rssi;

@end


