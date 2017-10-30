//
//  RECOBeaconRegion.h
//  Copyright (c) 2014 Perples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/** The most significant value in a beacon
 */
typedef uint16_t RECOBeaconMajorValue;
/** The least significant value in a beacon
 */
typedef uint16_t RECOBeaconMinorValue;

/**
 RECOBeaconRegion 클래스 디바이스가 블루투스 beacon에 얼마나 근접했느냐에 기반하여 지역 (region)을 정의합니다. Beacon region은 개발자가 입력한 정보와 매칭되는 beacon을 찾습니다. 매칭되는 beacon이 탐지되면 적합한 알림 (notification)을 전달합니다.

 Beacon region을 탐색하는 방법은 두 가지가 있습니다. Beacon의 근처에 가까워졌거나 멀어졌을 때 알림을 받으려면 RECOBeaconManager 의 startMonitoringBeaconsInRegion: 메소드를 호출합니다. Beacon 이 근처에 있을 때, beacon 에 대한 상대적인 위치가 변경될 때마다 알림을 받으려면 startRangingBeaconsInRegion: 메소드를 호출합니다.

 RECOBeaconRegion 객체는 CLRegion 객체의 인스턴스를 포함하고 있습니다. 해당하는 CLRegion 인스턴스는 getCLRegion 메소드로 접근할 수 있습니다. CLRegion 에 대한 자세한 설명은 [여기](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLRegion_class/Reference/Reference.html)를 참고하십시오.
 */
@interface RECOBeaconRegion : NSObject <NSCopying>

/**
  탐색하고자 하는 beacon 들의 unique ID. (읽기전용)
 */
@property (nonatomic, strong) NSUUID *proximityUUID;

/** 해당 region 객체의 identifier. (읽기전용)

  어플리케이션 내에서 각각의 region들을 구분하기 위해 설정하는 값입니다.
 */
@property (nonatomic, strong) NSString *identifier;

/** Beacon 의 그룹을 결정짓는 값. (읽기전용)

  major 값을 설정하지 않을 경우, 이 값은 nil 입니다. 이 값이 nil 일 경우, 매칭시에 major 값은 무시합니다.
 */
@property (nonatomic, strong) NSNumber *major;

/** Beacon 그룹 내에서 각각의 beacon을 구별하는 값. (읽기전용)

  minor 값을 설정하지 않을 경우, 이 값은 nil 입니다. 이 값이 nil 일 경우, 매칭시에 minor 값은 무시합니다.
 */
@property (nonatomic, strong) NSNumber *minor;

/** Beacon 의 근방에 가까워졌을 때 알림 전달 여부를 셋팅하는 메소드.

  @param notifyOnEntry BOOL 타입으로 YES이면 알림을 전달하고 NO이면 알림을 전달하지 않습니다.
 */
- (void)setNotifyOnEntry:(BOOL)notifyOnEntry;

/** Beacon 의 근방에서 멀어졌을 때 알림 전달 여부를 셋팅하는 메소드.

  @param notifyOnExit BOOL 타입으로 YES이면 알림을 전달하고 NO이면 알림을 전달하지 않습니다.
 */
- (void)setNotifyOnExit:(BOOL)notifyOnExit;

/** Beacon 의 근방에 가까워졌을 때 알림 전달 여부를 알려주는 메소드.

  @return 알림을 전달하면 YES, 전달하지 않으면 NO.
 */
- (BOOL)getNotifyOnEntry;

/** Beacon 의 근방에서 멀어졌을 때 알림 전달 여부를 알려주는 메소드.

  @return 알림을 전달하면 YES, 전달하지 않으면 NO.
 */
- (BOOL)getNotifyOnExit;

/** 파라미터로 지정한 proximityUUID 값의 beacon을 탐색하는 region을 초기화 한 후 리턴

  이 메소드는 지정된 proximityUUID 값을 가지는 모든 beacon 을 탐색하는 region을 정의합니다. 탐색한 beacon의 major 값과 minor 값은 무시합니다.

  @param uuid 탐색할 beacon 의 proximityUUID. 이 값이 nil 일 경우, (주)퍼플즈에서 제공하는 RECOBeacon 의 UUID 가 default값으로 설정됩니다.
  @param identifier 리턴되는 region 객체에게 할당할 unique ID. 어플리케이션 내에서 다른 region들과 구분하기 위해 이 identifier 를 사용합니다. 이 값은 nil 이 될 수 없습니다.
  @return 초기화된 RECOBeaconRegion 객체
 */
- (id)initWithProximityUUID:(NSUUID *)uuid identifier:(NSString *)identifier;

/** 파라미터로 지정한 proximityUUID 값과 major 값의 beacon을 탐색하는 region을 초기화 한 후 리턴

  이 메소드는 지정된 proximityUUID 값과 major 값을 가지는 모든 beacon 을 탐색하는 region을 정의합니다. 탐색한 beacon의 minor 값은 무시합니다.
  @param uuid 탐색할 beacon 의 proximityUUID. 이 값이 nil 일 경우, (주)퍼플즈에서 제공하는 RECOBeacon 의 UUID 가 default값으로 설정됩니다.
  @param major 특정 beacon 혹은 beacon 그룹을 구분하기 위해 사용할 major 값.
  @param identifier 리턴되는 region 객체에게 할당할 unique ID. 어플리케이션 내에서 다른 region들과 구분하기 위해 이 identifier 를 사용합니다. 이 값은 nil 이 될 수 없습니다.
  @return 초기화된 RECOBeaconRegion 객체
 */
- (id)initWithProximityUUID:(NSUUID *)uuid major:(RECOBeaconMajorValue)major identifier:(NSString *)identifier;

/** 파라미터로 지정한 proximityUUID 값, major 값, minor 값의 beacon을 탐색하는 region을 초기화 한 후 리턴

  이 메소드는 지정된 proximityUUID 값, major 값, minor 값을 가지는 모든 beacon 을 탐색하는 region을 정의합니다. 
  @param uuid 탐색할 beacon 의 proximityUUID. 이 값이 nil 일 경우, (주)퍼플즈에서 제공하는 RECOBeacon 의 UUID 가 default값으로 설정됩니다.
  @param major 특정 beacon 혹은 beacon 그룹을 구분하기 위해 사용할 major 값.
  @param minor 특정 beacon 을 구분하기 위해 사용할 minor 값.
  @param identifier 리턴되는 region 객체에게 할당할 unique ID. 어플리케이션 내에서 다른 region들과 구분하기 위해 이 identifier 를 사용합니다. 이 값은 nil 이 될 수 없습니다.
  @return 초기화된 RECOBeaconRegion 객체
 */
- (id)initWithProximityUUID:(NSUUID *)uuid major:(RECOBeaconMajorValue)major minor:(RECOBeaconMinorValue)minor identifier:(NSString *)identifier;

/** 현재 instance 가 기반으로 하는 CLRegion 객체를 리턴.

  모든 RECOBeaconRegion 객체는 CLRegion 객체를 기반으로 합니다. 이 메소드는 CLRegion 객체를 리턴합니다.

  @return CLRegion 객체
 */
- (CLRegion *)getCLRegion;
@end
