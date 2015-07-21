

//--------------- Constants

var USE_DUMMY_IMPLEMENTATIONS = false;

var SERVICE_NAME = "LittlePostman";

var ACTION_CONFIGURE = "configure";
var ACTION_IS_REGISTERED = "isRegistered";
var ACTION_REGISTER = "register";
var ACTION_UNREGISTER = "unregister";
var ACTION_SETDATA = "setData";

var ACTION_ESTABLISH_PUSH_MESSAGE_RECEIVED_CHANNEL = 'establishPushMessageReceivedChannel';

var PARAM_ENV_PROD = "PROD";
var PARAM_ENV_DEV = "DEV";



//--------------- Setup

var LittlePostman = function() {
};

require('cordova/channel').onCordovaReady.subscribe(function() {
  require('cordova/exec')(onPushMessageReceivedChannelMessage, null, SERVICE_NAME, ACTION_ESTABLISH_PUSH_MESSAGE_RECEIVED_CHANNEL, []);
  function onPushMessageReceivedChannelMessage(message) {
    cordova.plugins.LittlePostman.onMessageReceived(message.message, message.isInForeground);
  }
});


// Configures the Little Postman plugin so that it can properly communicate with the
// Little Postman backend. This method needs to be called as early as possible so that
// push notifications which caused the app to launch are received in onMessageReceivedCallback
// as soon as possible.
//
// - clientAuthKey              String; The client auth key for your app from the Little Postman
//                              frontend's settings page
// - environment                String; Either 'DEV' or 'PROD' depending on whether you're
//                              building your app for development or release
//                              (ie. App Store / Google Play) purposes
// - onMessageReceivedCallback  function(object, bool); The function to invoke when the app receives a message.
//                              The object contains the keys 'messageId', 'message' and 'data' where data contains
//                              the JSON data as input in the push dialog.
// - successCallback            The function to invoke when the configuration finished successfully
// - errorCallback              The function to invoke when the configuration finished with an error
LittlePostman.prototype.configure = function(clientAuthKey, environment, onMessageReceivedCallback, successCallback, errorCallback) {
  if (!isNonEmptyString(clientAuthKey)) {
    console.log("LittlePostman.configure failure: clientAuthKey must be set");
    errorCallback ("LittlePostman.configure failure: clientAuthKey must be set");
    return;
  }

  if (environment !== PARAM_ENV_DEV && environment !== PARAM_ENV_PROD) {
    console.log("LittlePostman.configure failure: environment must be set to either " + PARAM_ENV_DEV + " or " + PARAM_ENV_PROD);
    errorCallback("LittlePostman.configure failure: environment must be set to either " + PARAM_ENV_DEV + " or " + PARAM_ENV_PROD);
    return;
  }

  if (!USE_DUMMY_IMPLEMENTATIONS) {
    this.onMessageReceived = onMessageReceivedCallback;

    cordova.exec (function(result) {
      // on success
      successCallback(result);
    }, function(error) {
      // on error
      errorCallback();
    }, SERVICE_NAME, ACTION_CONFIGURE, [ clientAuthKey, environment ]);
  } else {
    alert('Configuring');

    successCallback();

    var numberOfMessages = 0;
    var intervalId = 0;

    intervalId = setInterval(function() {
      if (numberOfMessages == 2) {
        clearInterval(intervalId);
        console.log("Clearing interval");
      } else {
        onMessageReceivedCallback();
        numberOfMessages++;
      }
    }, 2000);
  }
};



//--------------- Device Registration

// Indicates whether the device is registered for receiving push notifications from the
// Little Postman backend.
LittlePostman.prototype.isRegistered = function(successCallback, errorCallback) {
  if (!USE_DUMMY_IMPLEMENTATIONS) {
    cordova.exec (function(result) {
      // on success
      successCallback(result);
    }, function(error) {
      // on error
      errorCallback();
    }, SERVICE_NAME, ACTION_IS_REGISTERED, [ ]);
  } else {
    successCallback(true);
  }
};

// Registers the device with the Little Postman backend.
LittlePostman.prototype.register = function(successCallback, errorCallback) {
  if (!USE_DUMMY_IMPLEMENTATIONS) {
    cordova.exec (function(didRegisterSuccessfully) {
      // on success
      successCallback(didRegisterSuccessfully);
    }, function() {
      // on error
      errorCallback();
    }, SERVICE_NAME, ACTION_REGISTER, [ ]);
  } else {
    errorCallback();
  }
};

// Unregisters the device from the Little Postman backend so that the Little Postman backend
// will no longer send any push notifications to the device.
LittlePostman.prototype.unregister = function(successCallback, errorCallback, options) {
  if (!USE_DUMMY_IMPLEMENTATIONS) {
    cordova.exec (function(didUnregisterSuccessfully) {
      // on success
      successCallback(didUnregisterSuccessfully);
    }, function() {
      // on error
      errorCallback();
    }, SERVICE_NAME, ACTION_UNREGISTER, [ ]);
  } else {
    errorCallback();
  }
};



//--------------- Associating data with a device

// Associates additional data with a registered device in the Little Postman backend.
//
// - data   A JavaScript object with strings or identifiers as keys and strings or
//          arrays of strings as values.
// - successCallback    Function that is invoked when the setData command was
//                      successfully passed to the underlying platform-specific SDK.
// - errorCallback      Function that is invoked when a system error occurred. Reasons
//                      could be: SDK has not yet been configured using the configure()
//                      function or the device is not yet registered with LP.
LittlePostman.prototype.setData = function(data, successCallback, errorCallback) {
  if (!USE_DUMMY_IMPLEMENTATIONS) {
    cordova.exec (function(didSetDataSuccessfully) {
      // on success
      successCallback(didSetDataSuccessfully);
    }, function() {
      errorCallback();
    }, SERVICE_NAME, ACTION_SETDATA, [ data ]);
  } else {
    successCallback();
  }
};



//--------------- Utility functions

var isNonEmptyString = function(str) {
  return (str !== '');
};



//--------------- Plugin Handling

module.exports = new LittlePostman();
