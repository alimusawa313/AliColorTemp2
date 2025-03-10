//
//  OpenCVWrapper.m
//  AliColorTemp
//
//  Created by Ali Haidar on 3/9/25.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"

@interface UIImage (OpenCVWrapper)
- (void)convertToMat: (cv::Mat *)pMat: (bool) alphaExist;
@end

@implementation UIImage (OpenCVWrapper)

- (void)convertToMat:(cv::Mat *)pMat :(bool)alphaExist {
    if (self.imageOrientation == UIImageOrientationRight) {
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExist);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_CLOCKWISE);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExist);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_COUNTERCLOCKWISE);
    } else {
        UIImageToMat(self, *pMat, alphaExist);
        if (self.imageOrientation == UIImageOrientationDown) {
            cv::rotate(*pMat, *pMat, cv::ROTATE_180);
        }
    }
}

@end

@implementation OpenCVWrapper

// Function to convert cv::Mat to UIImage
UIImage* MatToUIImage(const cv::Mat& mat) {
    if (mat.empty()) {
        return nil;
    }
    
    cv::Mat matRGBA;
    if (mat.channels() == 1) {
        cv::cvtColor(mat, matRGBA, cv::COLOR_GRAY2BGRA);
    } else if (mat.channels() == 3) {
        cv::cvtColor(mat, matRGBA, cv::COLOR_BGR2BGRA);
    } else {
        matRGBA = mat;
    }

    size_t width = matRGBA.cols;
    size_t height = matRGBA.rows;
    size_t bytesPerRow = matRGBA.step;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(matRGBA.data, width, height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    if (cgImage == NULL) {
        return nil;
    }
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return image;
}

// Grayscale conversion function
+ (UIImage *)grayscaleImg:(UIImage *)image {
    cv::Mat mat;
    [image convertToMat:&mat :false];
    
    cv::Mat gray;
    
    if (mat.channels() > 1) {
        cv::cvtColor(mat, gray, cv::COLOR_RGB2GRAY);
    } else {
        mat.copyTo(gray);
    }
    
    UIImage *grayImg = MatToUIImage(gray);
    return grayImg;
}



+ (UIImage *)adjustImageTemperature:(UIImage *)image withAdjustment:(float)adjustment {
    cv::Mat mat;
    [image convertToMat: &mat :false];
    
    // Split the image into the 3 color channels (BGR)
    std::vector<cv::Mat> channels(3);
    cv::split(mat, channels);
    
    // Adjust the temperature by modifying the red, green, and blue channels
    float factor = adjustment / 100.0;  // Factor to scale the temperature adjustment
    
    // Apply temperature adjustments: positive = warmer, negative = cooler
    if (factor > 0) {
        // Warmer: Increase red, slightly increase green, decrease blue
        channels[2] += factor * channels[2];  // Increase red
        channels[1] += factor * 0.5 * channels[1];  // Slightly increase green
        channels[0] -= factor * 0.5 * channels[0];  // Slightly decrease blue
    } else {
        // Cooler: Increase blue, slightly decrease red and green
        channels[0] += factor * -channels[0];  // Increase blue
        channels[1] += factor * 0.5 * -channels[1];  // Slightly decrease green
        channels[2] -= factor * 0.5 * channels[2];  // Slightly decrease red
    }
    
    // Merge the channels back
    cv::Mat result;
    cv::merge(channels, result);
    
    // Convert back to UIImage
    UIImage *resultImage = MatToUIImage(result);
    return resultImage;
}


+ (UIImage *)adjustBrightnessAndContrast:(UIImage *)image brightness:(float)brightness contrast:(float)contrast {
    // Ensure the input image is not nil
    if (!image) {
        return nil;
    }
    
    // Convert UIImage to cv::Mat
    cv::Mat mat;
    [image convertToMat:&mat :false];
    
    if (mat.empty()) {
        return nil;
    }

    // Prepare the result Mat
    cv::Mat result;
    
    // Adjust brightness and contrast using cv::convertTo
    mat.convertTo(result, -1, contrast, brightness);
    
    // Convert the resulting Mat back to UIImage
    UIImage *resultImage = MatToUIImage(result);
    
    return resultImage;
}



@end
