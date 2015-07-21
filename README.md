# Little Postman Cordova Plugin

## Introduction

The plugin provides an easy way to integrate the Little Postman push notifications service
into a Cordova-based app.

## Platforms

The plugin provides a single JavaScript interface which is implemented on iOS and on
Android.

## Installation

Navigate to your project directory and run the following terminal command to install the
plugin:

`cordova plugin add <path-to-plugin-directory>`

Once the plugin is installed, additional steps are required to adjust the plugin to your
app.

### iOS

On iOS, Apple requires you to configure your provisioning profile to support push notifications.
Follow the steps described on http://push.littlepostman.com to create/update your code-signing
information accordingly.

Once the code-signing information is in place, update the Xcode project in your Cordova app
to make use of the new/updated code-signing information.

### Android

On Android, the Google Cloud Messaging service (GCM) must be configured before your app can
start receiving push notifications. Follow the steps described on http://push.littlepostman.com
to configure the service appropriately.

Once done, add the required information to the `littlepostman.xml` file which was added by the
plugin to your Android project's `assets` folder.

Afterwards, one file has to be moved / updated manually as we currently don't know of any way
to automate this during plugin installation:

1. In your Android project's `src` directory, find the `GCMIntentService.java` file that is stored
   in the `com/littlepostman/cordova/plugin` folder.
2. Move the file to the folder where the `MainActivity.java` file is stored. (Note: The folder
   matches the ID of your Cordova app. As an example, if your app's ID is `com.example.app`, the
   `MainActivity.java` file can be found at `src/com/example/app/MainActivity.java`)
3. Once the file has been moved, open the file in an editor and replace the first line (which
   originally reads `package com.littlepostman.cordova.plugin;`) by the line
   `package <your-cordova-app-id>;`. (In our example, the line must be replaced by the line
   `package com.example.app;`).

## Usage

Once you have properly installed the plugin, the following JavaScript methods can be used by your
Cordova app. You can find more detailed information about their parameters and their usage in the
`www/LittlePostman.js` file.

As a general note:

Each method has a successCallback and an errorCallback parameter. The errorCallback is invoked whenever
there was a system error that prevented the method from completing successfully. If the errorCallback
is invoked, you most likely invoked a method before calling the `configure` method.

If no system error has occurred, the successCallback is invoked. It will - depending on the method -
receive a parameter indicating its result.


### Configure

`cordova.plugins.LittlePostman.configure (clientAuthKey, environment, onMessageReceivedCallback, successCallback, errorCallback)`

This method must be called as early in your app's lifecycle as possible to initialize the plugin. Only after
initialization, your app will start to receive push notifications via the function passed as the `onMessageReceivedCallback`
parameter.

### IsRegistered

`cordova.plugins.LittlePostman.isRegistered (successCallback, errorCallback)`

This method can be used to determine, whether the device has already been registered for push
notifications on the Little Postman servers. A device will only start to receive push notifications
once it has been registered with the Little Postman servers.

The successCallback will receive a single bool parameter to indicate whether the device is / is not registered.

### Register

`cordova.plugins.LittlePostman.register (successCallback, errorCallback)`

Registers the device with the Little Postman servers. The implementation of this method first enables
push notifications in a platform-specific manner (if necessary). Once the platform has successfully
enabled push notifications, the device will be registered automatically with the Little Postman servers.

The successCallback will receive a single bool parameter to indicate whether the device has correctly been / not been
registered.

### Unregister

`cordova.plugins.LittlePostman.unregister (successCallback, errorCallback)`

Unregisters the device from the Little Postman servers. Once the method completes successfully,
the device will no longer receive any push notifications.

The successCallback will receive a single bool parameter to indicate whether the device has correctly been / not been
unregistered.

### SetData

`cordova.plugins.LittlePostman.setData (data, successCallback, errorCallback)`

Associates additional information with a device that has previously been registered on the Little Postman
servers. Pass a JavaScript object as the data parameter where the keys in the object must
match field names configured in your app on Little Postman. Depending on whether the field has been
created as a tag-based field or not, the value of the key must either be an array of strings or a single
string.
