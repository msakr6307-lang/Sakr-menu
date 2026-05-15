#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

static UIView *menu;
static UIButton *icon;
static BOOL mActive = NO;
static BOOL aActive = NO;

@interface MustafaSmartScan : NSObject
+ (void)handlePan:(UIPanGestureRecognizer *)p;
+ (void)toggle;
+ (uintptr_t)findPattern:(const char *)pattern;
+ (void)doPatch;
@end

@implementation MustafaSmartScan

// دالة البحث عن "البصمة" جوه الذاكرة
+ (uintptr_t)findPattern:(const char *)pattern {
    uintptr_t base = 0;
    uintptr_t size = 0;
    
    // 1. تحديد مكان ملف اللعبة وحجمه
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), "UnityFramework")) {
            base = (uintptr_t)_dyld_get_image_header(i);
            // حجم تقريبي للمسح في الذاكرة
            size = 0x5000000; 
            break;
        }
    }
    
    if (!base) return 0;

    // 2. تحويل البصمة النصية لأرقام ونبدأ المسح (تبسيط للعملية)
    // هنا الكود بيمسح الذاكرة يدور على "توقيع" الدالة
    // ملاحظة: العناوين دي افتراضية لأذكى بصمات 1.0.3
    return base; // سنستخدم الـ Base للتبسيط حالياً مع منطق الـ Hook
}

+ (void)handlePan:(UIPanGestureRecognizer *)p {
    CGPoint t = [p translationInView:icon.superview];
    icon.center = CGPointMake(icon.center.x + t.x, icon.center.y + t.y);
    [p setTranslation:CGPointZero inView:icon.superview];
}

+ (void)toggle {
    menu.hidden = !menu.hidden;
    menu.frame = CGRectMake(icon.frame.origin.x + 65, icon.frame.origin.y, 180, 150);
}

// التعديل الذكي
+ (void)doAction:(int)type {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), "UnityFramework")) {
            base = (uintptr_t)_dyld_get_image_header(i);
            break;
        }
    }

    if (type == 1) { // Mining
        mActive = !mActive;
        // بصمة الجمع التلقائي (تعديل 4 بايت دفعة واحدة)
        uintptr_t addr = base + 0x1A60D40; 
        vm_protect(mach_task_self(), (vm_address_t)addr, 4, FALSE, VM_PROT_ALL);
        *(uint32_t *)addr = mActive ? 0xD2800020 : 0xFF8300D1;
    } else { // Ammo
        aActive = !aActive;
        uintptr_t addr = base + 0x1B8A120;
        vm_protect(mach_task_self(), (vm_address_t)addr, 4, FALSE, VM_PROT_ALL);
        *(uint32_t *)addr = aActive ? 0xD2807CE0 : 0xFF8300D1;
    }
}

@end

%ctor {
    // تأخير 20 ثانية عشان الحماية تهدا تماماً
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        
        icon = [UIButton buttonWithType:UIButtonTypeCustom];
        icon.frame = CGRectMake(50, 200, 65, 65);
        [icon setTitle:@"🦅" forState:UIControlStateNormal];
        icon.titleLabel.font = [UIFont systemFontOfSize:45];
        icon.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        icon.layer.cornerRadius = 32.5;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[MustafaSmartScan class] action:@selector(handlePan:)];
        [icon addGestureRecognizer:pan];
        [icon addTarget:[MustafaSmartScan class] action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:icon];

        menu = [[UIView alloc] initWithFrame:CGRectMake(120, 200, 180, 150)];
        menu.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:0.95];
        menu.layer.cornerRadius = 15; menu.layer.borderWidth = 2;
        menu.layer.borderColor = [UIColor orangeColor].CGColor;
        menu.hidden = YES; [win addSubview:menu];

        UIButton *b1 = [UIButton buttonWithType:UIButtonTypeSystem];
        b1.frame = CGRectMake(10, 30, 160, 45); [b1 setTitle:@"SMART MINING" forState:UIControlStateNormal];
        [b1 addTarget:[MustafaSmartScan class] action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
        b1.tag = 1; [menu addSubview:b1];

        UIButton *b2 = [UIButton buttonWithType:UIButtonTypeSystem];
        b2.frame = CGRectMake(10, 85, 160, 45); [b2 setTitle:@"SMART AMMO" forState:UIControlStateNormal];
        [b2 addTarget:[MustafaSmartScan class] action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
        b2.tag = 2; [menu addSubview:b2];
    });
}
