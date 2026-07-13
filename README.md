# XpertCodeTest

## Description
An agenda app to showcase, Swift-Objective-C integration, local storage using CoreData, API call [randomuser](https://randomuser.me/api/) to get an image for the contact, and functionals and UI tests. The app does not use external dependencies.

## Instructions
1. Clone the repo 
2. Run test
3. Compile and run
4. Optional - To test the app with a clean data base, comment line 24 and uncomment line 23 in **/XpertCodeTest/persistence/CoreDataManager.m**.

## Known Issues  
1. The UI functional tests fail, pending completion.
2. While running the app in the simulator, the API call to [randomuser](https://randomuser.me/api/), may not return an image neither an error, however when running on physical device the call works. Possible root cause a network issue in local device.      