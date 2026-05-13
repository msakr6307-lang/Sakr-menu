#import <UIKit/UIKit.h>
#import "ArchitectMenu.h"

// متغيرات السرعة
float pSpeed = 1.0f;
float cSpeed = 1.0f;

// هوك التحكم في سرعة اللاعب (One State)
%hook PlayerController
- (float)movementSpeed {
    return %orig * pSpeed; 
}
%end

// هوك التحكم في سرعة السيارة
%hook VehicleController
- (float)maxVehicleSpeed {
    return %orig * cSpeed;
}
%end

void setup() {
    [Menu setTitle:@"SAKR" color:[UIColor cyanColor]];
    
    [Menu addTabBar:@"Speed"];
    [Menu addSlider:@"Player Speed" min:1 max:10 default:1 ✅:^void(float val) {
        pSpeed = val;
    }];
    
    [Menu addSlider:@"Car Speed" min:1 max:20 default:1 ✅:^void(float val) {
        cSpeed = val;
    }];
}
