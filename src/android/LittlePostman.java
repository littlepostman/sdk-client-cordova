package com.littlepostman.cordova.plugin;

import java.util.ArrayList;
import java.util.List;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

import com.littlepostman.LPPushClient;
import com.littlepostman.LPPushClientListener;
import com.littlepostman.rpc.model.LPDevice;
import com.littlepostman.rpc.model.LPMessage;
import com.littlepostman.rpc.model.LPPreviousMessage;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class LittlePostman extends CordovaPlugin implements LPPushClientListener {

    private static final String TAG = "LittlePostman";

    private static final String ACTION_CONFIGURE = "configure";
    private static final String ACTION_IS_REGISTERED = "isRegistered";
    private static final String ACTION_REGISTER = "register";
    private static final String ACTION_UNREGISTER = "unregister";
    private static final String ACTION_SETDATA = "setData";
    private static final String ACTION_ESTABLISH_PUSH_MESSAGE_RECEIVED_CHANNEL = "establishPushMessageReceivedChannel";

    private static final String NOTIFICATIONCENTER_INTENT_DATA = "com.littlepostman.cordova.plugin.message_data";

    private static final String PREF_LAST_PROCESSED_MESSAGE_ID = "com.littlepostman.cordova.plugin.last_processed_message_id";

    private static LittlePostman instance;

    private LPPushClient pushClient;

    private CallbackContext onPushMessageReceivedChannelCallbackContext;
    private CallbackContext pendingRegisterCallbackContext;
    private CallbackContext pendingUnregisterCallbackContext;

    private boolean isInForeground;


    public static LittlePostman getInstance() {
        return instance;
    }


    public LittlePostman() {
        instance = this;
    }


    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        processPushFromIntentIfNecessary(intent);
    }

    @Override
    public void onStart() {
        super.onStart();

        isInForeground = true;
    }

    @Override
    public void onStop() {
        super.onStop();

        isInForeground = false;
    }


    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals(ACTION_CONFIGURE)) {
            configure(callbackContext);
            return true;
        } else if (action.equals(ACTION_IS_REGISTERED)) {
            isRegistered(callbackContext);
            return true;
        } else if (action.equals(ACTION_REGISTER)) {
            register(callbackContext);
            return true;
        } else if (action.equals(ACTION_UNREGISTER)) {
            unregister(callbackContext);
            return true;
        } else if (action.equals(ACTION_SETDATA)) {
            setData(args.getJSONObject(0), callbackContext);
            return true;
        } else if (action.equals(ACTION_ESTABLISH_PUSH_MESSAGE_RECEIVED_CHANNEL)) {
            establishPushMessageReceivedChannel(callbackContext);
            return true;
        }

        return false;
    }

    private void configure(CallbackContext callbackContext) {
        pushClient = LPPushClient.getInstance();
        pushClient.initWithConfiguration(getContext(), "littlepostman.xml");
        pushClient.addListener(this);

        PluginResult result = new PluginResult(PluginResult.Status.OK, pushClient.toString());
        callbackContext.sendPluginResult(result);

        // Once the app has configured push, it is also ready to receive push
        // notifications via the channel.
        processPushFromIntentIfNecessary(cordova.getActivity().getIntent());
    }

    private void isRegistered(CallbackContext callbackContext) {
        PluginResult result = null;

        if (pushClient != null) {
            boolean isDeviceRegistered = pushClient.isDeviceRegistered(getContext());
            result = new PluginResult(PluginResult.Status.OK, isDeviceRegistered);
        } else {
            result = new PluginResult(PluginResult.Status.ERROR);
        }

        callbackContext.sendPluginResult(result);
    }

    private void register(CallbackContext callbackContext) {
        if (pushClient != null && pendingRegisterCallbackContext == null) {
            pendingRegisterCallbackContext = callbackContext;
            pushClient.registerDevice(getContext());
        } else {
            PluginResult result = new PluginResult(PluginResult.Status.ERROR);
            callbackContext.sendPluginResult(result);
        }
    }

    private void unregister(CallbackContext callbackContext) {
        if (pushClient != null && pendingUnregisterCallbackContext == null) {
            pendingUnregisterCallbackContext = callbackContext;
            pushClient.unregisterDevice(getContext());
        } else {
            PluginResult result = new PluginResult(PluginResult.Status.ERROR);
            callbackContext.sendPluginResult(result);
        }
    }

    private void setData(JSONObject data, CallbackContext callbackContext) {
        if (pushClient != null && pushClient.isDeviceRegistered(getContext())) {
            pushClient.setData(getContext(), data);

            PluginResult result = new PluginResult(PluginResult.Status.OK, true);
            callbackContext.sendPluginResult(result);
        } else {
            PluginResult result = new PluginResult(PluginResult.Status.ERROR);
            callbackContext.sendPluginResult(result);
        }
    }


    public void onPushMessage(LPMessage message) {
        Log.v(TAG, "notification received. isInForeground?" + isInForeground);

        try {
            JSONObject jsonMessage = new JSONObject();
            jsonMessage.put("messageId", message.getMessageId());
            jsonMessage.put("message", message.getMessage());
            jsonMessage.put("data", message.getData());

            JSONObject jsonResult = new JSONObject();
            jsonResult.put("message", jsonMessage);
            jsonResult.put("isInForeground", isInForeground);

            if (isInForeground) {
                sendPushMessageToApp(jsonResult);
            } else {
                sendPushMessageToNotificationCenter(getContext(), message, jsonResult);
            }
        } catch (JSONException ex) {
            Log.e(TAG, "JSONException while creating push message data for app", ex);
        }
    }

    private void establishPushMessageReceivedChannel(CallbackContext callbackContext) {
        onPushMessageReceivedChannelCallbackContext = callbackContext;

        PluginResult dataResult = new PluginResult(PluginResult.Status.OK);
        dataResult.setKeepCallback(true);

        onPushMessageReceivedChannelCallbackContext.sendPluginResult(dataResult);
    }

    private void sendPushMessageToApp(JSONObject data) {
        Log.v(TAG, "trying to send push to app");

        if (onPushMessageReceivedChannelCallbackContext != null) {
            // onPushMessageReceivedChannelCallbackContext is kept open once the plugin
            // has been initialized. We are now sending data across that channel whenever
            // a push message has been received
            PluginResult dataResult = new PluginResult(PluginResult.Status.OK, data);
            dataResult.setKeepCallback(true);

            onPushMessageReceivedChannelCallbackContext.sendPluginResult(dataResult);
        } else {
            Log.e(TAG, "cannot send push message to app as the communication channel is null");
        }
    }

    private void sendPushMessageToNotificationCenter(Context context, LPMessage message, JSONObject data) {
        Log.v(TAG, "trying to post notification to notification center. context: " + context);

        Intent notificationIntent = new Intent(context, getCordovaMainActivityClass());
        notificationIntent.putExtra(NOTIFICATIONCENTER_INTENT_DATA, data.toString());

        PendingIntent contentIntent = PendingIntent.getActivity(context, message.getMessageId(), notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        String displayMessage = message.getMessage();

        Notification.Builder builder = new Notification.Builder(context);
        builder
        	.setDefaults(Notification.DEFAULT_ALL)
        	.setSmallIcon(getDrawableResourceId("icon"))
        	.setTicker(displayMessage)
        	.setWhen(System.currentTimeMillis())
        	.setAutoCancel(true)
        	.setContentTitle(getStringResource("app_name"))
        	.setContentText(displayMessage)
        	.setContentIntent(contentIntent);

        Log.v(TAG, "show in notification center");

        NotificationManager manager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        manager.notify(0, builder.build());
    }

    private void processPushFromIntentIfNecessary(Intent intent) {
        if (intent.hasExtra(NOTIFICATIONCENTER_INTENT_DATA)) {
            try {
                JSONObject data = new JSONObject(intent.getStringExtra(NOTIFICATIONCENTER_INTENT_DATA));

                Log.v(TAG, "processing click on push with data: " + data.toString());

                JSONObject messageData = data.getJSONObject("message");
                int messageId = messageData.getInt("messageId");
                if (messageId > getLastProcessedMessageId()) {
                    setLastProcessedMessageId(messageId);

                    sendPushMessageToApp(data);
                }
            } catch (JSONException ex) {
                Log.e(TAG, "cannot parse push message data from incoming intent", ex);
            }
        }
    }


    @Override
    public void deviceRegisteredSuccessfully(LPDevice device) {
    	if (pendingRegisterCallbackContext != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, true);
            pendingRegisterCallbackContext.sendPluginResult(result);
            pendingRegisterCallbackContext = null;
        }
    }

    @Override
    public void deviceRegistrationFailed(LPDevice device, final String error) {
        if (pendingRegisterCallbackContext != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, false);
            pendingRegisterCallbackContext.sendPluginResult(result);
            pendingRegisterCallbackContext = null;
        }
    }

    @Override
    public void deviceUnregisteredSuccessfully(LPDevice device) {
        if (pendingUnregisterCallbackContext != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, true);
            pendingUnregisterCallbackContext.sendPluginResult(result);
            pendingUnregisterCallbackContext = null;
        }
    }

    @Override
    public void deviceUnregistrationFailed(LPDevice device, final String error) {
        if (pendingUnregisterCallbackContext != null) {
            PluginResult result = new PluginResult(PluginResult.Status.OK, false);
            pendingUnregisterCallbackContext.sendPluginResult(result);
            pendingUnregisterCallbackContext = null;
        }
    }

    @Override
    public void messageInboxReceived(List<LPPreviousMessage> messages) {
    	// not needed
    }

    @Override
    public void messageInboxRetrievalFailed(final String error) {
    	// not needed
    }

    @Override
    public void gcmErrorOccurred(final String errorId) {
    	//showErrorMessageAsToast(errorId);
    }


    private Context getContext() {
        return cordova.getActivity();
    }

    private int getLastProcessedMessageId() {
        SharedPreferences prefs = cordova.getActivity().getPreferences(Context.MODE_PRIVATE);
        return prefs.getInt(PREF_LAST_PROCESSED_MESSAGE_ID, -1);
    }

    private void setLastProcessedMessageId(int messageId) {
        SharedPreferences prefs = cordova.getActivity().getPreferences(Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putInt(PREF_LAST_PROCESSED_MESSAGE_ID, messageId);
        editor.commit();
    }

    private Class getCordovaMainActivityClass() {
        return cordova.getActivity().getClass();
    }

    private int getDrawableResourceId(String resourceName) {
        return cordova.getActivity().getResources().getIdentifier(resourceName, "drawable", cordova.getActivity().getPackageName());
    }

    private String getStringResource(String resourceName) {
        int resourceId = cordova.getActivity().getResources().getIdentifier(resourceName, "string", cordova.getActivity().getPackageName());
        return cordova.getActivity().getResources().getString(resourceId);
    }
}
