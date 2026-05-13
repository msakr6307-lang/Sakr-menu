#import <UIKit/UIKit.h>
#import "ArchitectMenu.h"

// --- متغيرات التحكم ---
float pSpeed = 1.0f;
float cSpeed = 1.0f;
bool auto_miner = false;
bool auto_delivery = false;

// --- هوكات السرعة ---
%hook PlayerController
- (float)movementSpeed { return %orig * pSpeed; }
%end

%hook VehicleController
- (float)maxVehicleSpeed { return %orig * cSpeed; }
%end

// --- هوكات الوظائف ---
%hook JobManager
- (void)onActionTriggered {
    if (auto_miner || auto_delivery) {
        %orig;
    } else {
        %orig;
    }
}

- (float)deliveryCheckDistance {
    if (auto_delivery) {
        return 500.0f;
    }
    return %orig;
}
%end

// --- بناء المنيو ---
void setup() {
    [Menu setTitle:@"SAKR" color:[UIColor cyanColor]];
    
    // خانة السرعة
    [Menu addTabBar:@"Speed"];
    [Menu addSlider:@"Player Speed" min:1 max:10 default:1 handler:^(float val) {
        pSpeed = val;
    }];
    [Menu addSlider:@"Car Speed" min:1 max:20 default:1 handler:^(float val) {
        cSpeed = val;
    }];
    
    // خانة الوظائف
    [Menu addTabBar:@"Jobs"];
    [Menu addSwitch:@"Auto Miner" description:@"عامل منجم تلقائي" handler:^(bool val) {
        auto_miner = val;
    }];
    [Menu addSwitch:@"Auto Delivery" description:@"مندوب توصيل سريع" handler:^(bool val) {
        auto_delivery = val;
    }];
}
