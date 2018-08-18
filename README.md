# Book-Finder-with-CoreML

This is the implementation of Image Recognition using Custom model (Book cover images) on Apple's CoreML-2.0 Framework. And uses Google Books API to get similar books according to your searched book.

The app fetches frames from your camera at ~30 FPS and perform object recognition in almost real-time. And allow the user to read, download and buy that book.

## Requirements

- Xcode 9
- iOS 11

## Creating CoreML Model

I have used an online Microsoft tool to generate CoreMl model (https://www.customvision.ai/)

## Usage

To use this app, open **BookFinderCoreML.xcworkspace** in Xcode 9 and run it on a device with iOS 11. (Don't use simulator as it don't have access to camera).

## Results

These are the results of the app when tested on iPhone 7. 

![image of scene with Book recognition](demo.gif)

## Pods used 

1. SDWebImage
2. Alamofire
