//
//  OpenCVWrapper.h
//  AliColorTemp
//
//  Created by Ali Haidar on 3/9/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (UIImage *)grayscaleImg:(UIImage *)image;
+ (UIImage *)adjustImageTemperature:(UIImage *)image withAdjustment:(float)temperatureAdjustment;
+ (UIImage *)adjustBrightnessAndContrast:(UIImage *)image brightness:(float)brightness contrast:(float)contrast;

@end

NS_ASSUME_NONNULL_END
