//
//  RECOBeaconManager.h
//  Copyright (c) 2014 Perples. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "RECOBeacon.h"
#import "RECOBeaconRegion.h"
#import "RECOBeaconRegionState.h"

@class RECOBeaconManager;

/** RECOBeaconManagerDelegate 은 RECOBeaconManager 로부터 관련된 이벤트의 알림을 받기 위한 메소드를 정의하고 있습니다. delegate 객체의 메소드는 상응하는 RECOBeaconManager 메소드를 호출한 쓰레드와 동일한 쓰레드에서 호출됩니다.
 */
@protocol RECOBeaconManagerDelegate <NSObject>
@optional
/** 사용자가 해당하는 region에 들어갔음을 알립니다. 

  region은 어플리케이션의 공유자원 (shared resource)이기 때문에 각각의 RECOBeaconManager 객체는 자신과 관계된 delegate 에게 이 메세지를 전달합니다. 어떤 RECOBeaconManager 객체가 해당 region을 등록했는지는 상관이 없고, 만약 여러개의 RECOBeaconManager 가 하나의 delegate을 공유한다면 해당 delegate은 여러번의 메세지를 받게 됩니다.

 전달되는 region은 등록했던 region과 같은 객체가 아닐 수 있기 때문에 객체의 비교시에 pointer를 이용하는 대신 region의 identifier를 이용해야 합니다.
 @param manager 이 메세지를 전달하는 RECOBeaconManager.
 @param region 진입한 region의 정보를 담고 있는 RECOBeaconRegion 객체.
 */
- (void)recoManager:(RECOBeaconManager *)manager didEnterRegion:(RECOBeaconRegion *)region;

/** 사용자가 해당하는 region에서 떠났음을 알립니다. 

  region은 어플리케이션의 공유자원 (shared resource)이기 때문에 각각의 RECOBeaconManager 객체는 자신과 관계된 delegate 에게 이 메세지를 전달합니다. 어떤 RECOBeaconManager 객체가 해당 region을 등록했는지는 상관이 없고, 만약 여러개의 RECOBeaconManager 가 하나의 delegate을 공유한다면 해당 delegate은 여러번의 메세지를 받게 됩니다.

 전달되는 region은 등록했던 region과 같은 객체가 아닐 수 있기 때문에 객체의 비교시에 pointer를 이용하는 대신 region의 identifier를 이용해야 합니다.
 @param manager 이 메세지를 전달하는 RECOBeaconManager.
 @param region 떠난 region의 정보를 담고 있는 RECOBeaconRegion 객체.
 */
- (void)recoManager:(RECOBeaconManager *)manager didExitRegion:(RECOBeaconRegion *)region;

/** 새로운 region에 대한 모니터링이 시작됐음을 알립니다.

 @param manager 이 메세지를 전달하는 RECOBeaconManager.
 @param region 모니터링을 시작한 region.
 */
- (void)recoManager:(RECOBeaconManager *)manager didStartMonitoringForRegion:(RECOBeaconRegion *)region;

/** 모니터링 하려는 region에 대해 error가 발생했음을 알립니다.

 해당 region에 대한 모니터링을 시도하다가 error가 발생할 경우 manager 가 delegate 에게 이 메세지를 전달합니다. 모니터링 할 수 없는 region일 경우나 모니터링 서비스를 준비할 때 발생하는 일반적인 에러에도 이 메소드가 호출됩니다.
 @param manager 이 메세지를 전달하는 RECOBeaconManager.
 @param region 모니터링을 실패한 region.
 @param error region 모니터링이 실패한 이유를 나타내는 error code를 포함하는 error객체. 
 */
- (void)recoManager:(RECOBeaconManager *)manager monitoringDidFailForRegion:(RECOBeaconRegion *)region withError:(NSError *)error;

/** 하나 이상의 beacon이 ranging 되었음을 알립니다.

  RECOBeaconManager 는 beacon이 range내에 들어오거나 나갈 때마다 이 메소드를 호출합니다. 또한 beacon의 range가 바뀔 때에도 이 메소드를 호출합니다. (예: beacon이 가까워 졌을 때)

 전달되는 region은 등록했던 region과 같은 객체가 아닐 수 있기 때문에 객체의 비교시에 pointer를 이용하는 대신 region의 identifier를 이용해야 합니다.
 @param manager 이 메세지를 전달하는 RECOBeaconManager.
 @param beacons 현재 range 내의 beacon정보를 담고있는 RECOBeacon 객체 배열. 이 객체들이 담고 있는 정보를 통해 각 beacon의 range와 identifier를 알 수 있습니다.
 @param region beacons 를 찾기 위해 사용된 파라미터 정보를 포함하는 RECOBeaconRegion 객체.
 */
- (void)recoManager:(RECOBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(RECOBeaconRegion *)region;

/** 주위의 beacon들에 대한 ranging 정보를 모으던 중 error가 발생했음을 delegate에 알립니다.

 대부분의 경우 RECOBeaconRegion 객체의 등록이 실패하는 경우에 error가 발생합니다. region 객체 자체가 유효하지 않은 경우나 유효하지 않은 정보를 포함하고 있는 경우에도 이 메소드가 호출됩니다.
 @param manager 이 메세지를 전달하는 RECOBeaconManager.
 @param region Ranging을 실패한 region.
 @param error Ranging이 실패한 이유를 나타내는 error code를 포함하는 error객체. 
 */
- (void)recoManager:(RECOBeaconManager *)manager rangingBeaconsDidFailForRegion:(RECOBeaconRegion *)region withError:(NSError *)error;

/** 해당 region에 대한 상태를 알립니다.

 RECOBeaconManager 는 모니터링중인 region의 state (RECOBeaconRegionState) 변화가 있을 때마다 본 메소드를 호출합니다. 또한 requestStateForRegion: 메소드가 불린 후에도 이 메소드를 호출합니다. State에 변화가 생기는 몇몇 경우는 아래와 같습니다.
 region의 경계를 통과할 때마다 recoManager:didEnterRegion: 메소드나 recoManager:didExitRegion: 메소드와 함께 이 메소드를 호출합니다.
 @param manager 이 메세지를 전달하는 RECOBeaconManager.
 @param state 해당 region의 상태. RECOBeaconRegionState 의 값 중 하나를 갖습니다.
 @param region 현재 상태를 알리는 region. 
 */
- (void)recoManager:(RECOBeaconManager *)manager didDetermineState:(RECOBeaconRegionState)state forRegion:(RECOBeaconRegion *)region;

/** 어플리케이션의 위치 서비스 권한이 변경되었음을 알립니다.
 
 RECOBeaconManager는 위치 서비스 권한이 변경되었을 때 마다 이 메소드를 호출합니다. 권한 변경은 사용자가 위치 서비스의 권한을 허용하거나 거절하였을 때 발생합니다.
 사용자가 requestWhenInUseAuthorization 메소드나 requestAlwaysAuthorization 메소드를 호출하였을 때, 위치 서비스 권한이 변경될 경우에만 이 메소드가 호출됩니다.
 이미 요청한 같은 권한을 갖고 있을 경우 이 메소드는 호출되지않습니다.
 @param manager 이 메세지를 전달하는 RECOBeaconManager
 @param status 권한 상태. CLAuthorizationStatus 의 값 중 하나를 갖습니다.
 */
- (void)recoManager:(RECOBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;
@end

/**
 RECOBeaconManager 클래스는 RECOBeacon 과 관련된 이벤트의 알람 설정에 대한 인터페이스를 제공합니다. 이 클래스의 인스턴스를 통해 RECOBeacon 의 이벤트 알람을 보낼 것인지 안 보낼 것인지를 설정하는 파라미터 값을 설정합니다. 

 RECOBeaconManager 는 아래 기능들을 지원합니다.

 - 지정한 region에 대해 모니터링을 수행하고 region 진입 여부에 따라 관련 이벤트를 발생.
 - 근처의 beacon들에 대해 ranging 을 수행

 RECOBeaconManager 객체는 CLLocationManager 객체의 인스턴스를 포함하고 있습니다. CLLocationManager 에 대한 자세한 설명은 [여기](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/CLLocationManager/CLLocationManager.html)를 참고하십시오.

 */

@interface RECOBeaconManager : NSObject;

/** 발생하는 이벤트에 대한 알림을 받을 delegate 객체.
 */
@property (nonatomic, assign) id <RECOBeaconManagerDelegate> delegate;

/** 이 기기가 region에 대한 모니터링을 지원하는지에 대한 Boolean 값을 리턴.
 
 모니터링의 지원여부는 기기의 하드웨어 지원 여부에만 영향을 받습니다. 즉, 위치서비스의 on/off 상태와는 별개입니다. 위치서비스의 사용가능 여부는 RECOBeaconManager 클래스의 locationServiceEnabled 메소드를 통해 알 수 있습니다.
  
  @return 모니터링이 가능하면 YES, 불가능하면 NO.
 */
+ (BOOL)isMonitoringAvailable; 

/** 이 기기가 bluetooth beacon에 대한 ranging을 지원하는지에 대한 Boolean 값을 리턴.  

  @return Ranging을 지원하면 YES, 지원하지 않으면 NO.
 */
+ (BOOL)isRangingAvailable;

/** 어플리케이션의 현재 위치서비스 권한.
 
 @return 어플리케이션의 현재 위치서비스 권한.
 */
+ (CLAuthorizationStatus)authorizationStatus;

/** 위치서비스가 활성화 되어있는지에 대한 Boolean 값을 리턴.

  @return 위치서비스가 활성화 상태이면 YES, 비활성화 상태이면 NO.
 */
+ (BOOL)locationServicesEnabled; //The user can enable or disable location services from the Settings application by toggling the Location Services switch in General.

/** RECO SDK Version.
 
 @return RECO SDK Version.
 */

- (NSString *)getVersion;

/** 모든 RECOBeaconManager 객체에 의해 공유되고 모니터링 되고 있는 region의 Set (읽기전용).
  
 이 속성에 직접 region을 추가할 수 없습니다. 대신 startMonitoringForRegion: 메소드를 호출하여 등록해야 합니다. 이 속성에 속한 모든 region은 어플리케이션 내의 모든 RECOBeaconManager 가 공유합니다. 
 이 set 에 속한 region은 iOS system에 의해 관리되기 때문에 등록한 region과 같은 객체가 아닐 수도 있습니다. 따라서 등록한 region과 같은 region인지 판별할 때에는 region의 identifier속성을 통해 비교해야 합니다.
 이 set은 어플리케이션의 실행/종료와 관계없이 유지됩니다. 따라서 기존에 등록한 region이 존재할 경우, 어플리케이션을 종료한 후 다시 실행하여도 이 set 은 기존에 등록된 region을 포함하도록 다시 생성됩니다.

 @return 현재 모니터링 되고 있는 RECOBeaconRegion 들의 set.
 */
- (NSSet *)getMonitoredRegions;

/** 현재 ranging 되고 있는 모든 region의 set (읽기전용).

  이 set 에 담겨있는 객체의 타입은 RECOBeaconRegion 입니다.

 @return 현재 ranging 되고 있는 RECOBeaconRegion 들의 set.
 */
- (NSSet *)getRangedRegions;


/** 해당 region에 대한 모니터링을 시작.

 모니터링 하고자 하는 모든 region에 대해 이 메소드를 각각 호출해야 합니다. 같은 identifier를 가지는 region이 이미 모니터링 중일 때에는 기존의 region이 신규 region과 교체됩니다. 이 메소드를 이용해 등록한 region은 어플리케이션 내의 모든 RECOBeaconManager 객체들이 공유하게 되며 현재 모니터링 중인 region들은 getMonitoredRegions: 메소드를 이용해 접근할 수 있습니다.

 Region 에 관한 이벤트는 recoManager:didEnterRegion 메소드와 recoManager:didExitRegion 메소드를 통해 전달되며 만약 error가 발생할 경우, recoManager:monitoringDidFailForRegion: 메소드가 호출됩니다.

 하나의 어플리케이션은 한 번에 20개의 region까지만 등록할 수 있습니다. 어플리케이션은 region에 진입 여부에 대한 이벤트 알림을 즉각 받지 못하면 평균 3분~5분사이에 받을 수 있습니다.

 이벤트 알람을 받기까지 걸리는 시간은 iOS에서 직접 컨트롤하는 사항입니다.
 @param recoRegion 모니터링 할 RECOBeaconRegion 객체. 본 파라미터는 nil이 될 수 없습니다.
 */
- (void)startMonitoringForRegion:(RECOBeaconRegion *)recoRegion;

/** 해당 region에 대한 모니터링을 멈춥니다.

  @param recoRegion 모니터링을 멈출 RECOBeaconRegion.
 */
- (void)stopMonitoringForRegion:(RECOBeaconRegion *)recoRegion;

/** 해당 region내의 beacon들에 대한 알림을 전달하기 시작합니다.

  region이 등록되면 발견하는 모든 beacon에 대해 recoManager:didRangeBeacons:inRegion: 메소드를 호출하여 알림을 보냅니다. 만약 해당 region을 등록하는 중 error가 발생하면 recoManager:rangingBeaconsDidFailForRegion:withError: 메소드를 호출하여 error정보를 알립니다.
  @param recoRegion 타겟 beacon을 정의하는 정보를 포함하는 region객체. 어떤 identifier값을 사용하여 RECOBeaconRegion 객체를 초기화했느냐에 따라 매칭되는 beacon의 수가 결정됩니다. 사용된 모든 identifier정보와 매칭되는 beacon만을 찾습니다. 
 */
- (void)startRangingBeaconsInRegion:(RECOBeaconRegion *)recoRegion;

/** 해당 region내의 beacon들에 대한 알림 전달을 멈춥니다.

  @param recoRegion 알림 전달을 멈출 RECOBeaconRegion.
 */
- (void)stopRangingBeaconsInRegion:(RECOBeaconRegion *)recoRegion;

/** 해당 region의 상태를 비동기적으로 가져옵니다. 

  이 메소드를 통한 요청은 비동기식으로 처리되며 그 결과는 RECOBeaconManager 객체의 delegate 으로 전달됩니다. 결과를 전달받기 위해서는 recoManager:didDetermineState:forRegion: 메소드를 구현해야 합니다. 
  @param recoRegion 상태를 알고자 하는 region.
 */
- (void)requestStateForRegion:(RECOBeaconRegion *)recoRegion;

/** Foreground 상태에서 어플리케이션의 위치 서비스 권한을 요청합니다.
 iOS 8 이상의 버전부터, foreground 상태에서 위치 서비스 활성화를 위해 이 권한을 요청해야 합니다. 이 메소드를 통한 요청은 비동기식으로 처리되며, 그 결과는 RECOBeaconManager 객체의 delegate 으로 전달됩니다. 결과를 전달받기 위해서는 recoManager:didChangeAuthorizationStatus: 메소드를 구현해야 합니다.
 권한 요청 시에 어플리케이션의 Info.plist 안의 NSLocationWhenInUseUsageDescription 키의 텍스트가 출력됩니다. 
 
 이 권한을 요청한 뒤에 Region Ranging을 수행할 수 있지만, Region Monitoring은 수행할 수 없습니다.
 */
- (void)requestWhenInUseAuthorization;

/** Foreground 및 background 상태에서 어플리케이션의 위치 서비스 권한을 요청합니다.
 iOS 8 이상의 버전부터, foreground 및 background 상태에서 위치 서비스 활성화를 위해 이 권한을 요청해야 합니다. 이 메소드를 통한 요청은 비동기식으로 처리되며, 그 결과는 RECOBeaconManager 객체의 delegate 으로 전달됩니다. 결과를 전달받기 위해서는 recoManager:didChangeAuthorizationStatus: 메소드를 구현해야 합니다.
 권한 요청 시에 어플리케이션의 Info.plist 안의 NSLocationAlwaysUsageDescription 키의 텍스트가 출력됩니다.
 
 이 권한을 요청한 뒤에 Region Monitoring 및 Region Ranging을 모두 수행할 수 있습니다.
 */
- (void)requestAlwaysAuthorization;

@end
