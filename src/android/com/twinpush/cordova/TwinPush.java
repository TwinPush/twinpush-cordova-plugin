package com.twinpush.cordova;

import android.content.Intent;
import android.util.Log;

import com.twincoders.twinpush.sdk.TwinPushSDK;
import com.twincoders.twinpush.sdk.activities.RichNotificationActivity;
import com.twincoders.twinpush.sdk.entities.LocationPrecision;
import com.twincoders.twinpush.sdk.entities.TwinPushOptions;
import com.twincoders.twinpush.sdk.notifications.PushNotification;
import com.twincoders.twinpush.sdk.services.NotificationIntentService;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Locale;

public class TwinPush extends CordovaPlugin {
    private static final String LOG_TAG = "TwinPush";

    private static final int FINE = 0;
    private static final int HIGH = 1;
    private static final int MEDIUM = 2;
    private static final int LOW = 3;
    private static final int COARSE = 4;

    private TwinPushSDK twinpush() {
        return TwinPushSDK.getInstance(cordova.getActivity());
    }

    private CallbackContext registerCallback;
    private CallbackContext notificationOpenCallback;

    private PushNotification lastNotification;

    private String alias;
    private boolean registerEnabled = false;

    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();

        TwinPushOptions options = new TwinPushOptions();
        options.twinPushAppId = preferences.getString("TwinPush_AppId", "");
        options.twinPushApiKey = preferences.getString("TwinPush_ApiKey", "");
        options.subdomain = preferences.getString("TwinPush_Subdomain", "app");

        boolean manualRegister = preferences.getString("TwinPush_ManualRegister", "").equals("true");
        this.registerEnabled = !manualRegister;

        twinpush().setup(options);

        if (this.registerEnabled) {
            register(null);
        }

        checkPushNotification(cordova.getActivity().getIntent());
    }

    @Override
    public boolean execute(final String action, final JSONArray data, final CallbackContext callbackContext) {
        try {
            Log.v(LOG_TAG, action);
            switch (action) {
                case "setAlias":
                    this.alias = data.getString(0);
                    if (this.registerEnabled) {
                        register(callbackContext);
                    }
                    return true;
                case "setRegisterCallback":
                    registerCallback = callbackContext;
                    return true;
                case "setNotificationOpenCallback":
                    notificationOpenCallback = callbackContext;

                    // Send saved notification if any
                    if (lastNotification != null) {
                        sendNotificationToCallback(lastNotification);
                        lastNotification = null;
                    }
                    return true;
                case "getDeviceId":
                    callbackContext.success(twinpush().getDeviceId());
                    return true;
                case "setIntegerProperty": {
                    String key = data.getString(0);
                    int value = data.getInt(1);
                    twinpush().setProperty(key, value);
                    callbackContext.success(value);
                    return true;
                }
                case "setFloatProperty": {
                    String key = data.getString(0);
                    Double value = data.getDouble(1);
                    twinpush().setProperty(key, value);
                    PluginResult result = new PluginResult(PluginResult.Status.OK, value.floatValue());
                    callbackContext.sendPluginResult(result);
                    return true;
                }
                case "setBooleanProperty": {
                    String key = data.getString(0);
                    boolean value = data.getBoolean(1);
                    twinpush().setProperty(key, value);
                    PluginResult result = new PluginResult(PluginResult.Status.OK, value);
                    callbackContext.sendPluginResult(result);
                    return true;
                }
                case "setStringProperty": {
                    String key = data.getString(0);
                    String value = data.getString(1);
                    twinpush().setProperty(key, value);
                    callbackContext.success(value);
                    return true;
                }
                case "setLocation":
                    double latitude = data.getDouble(0);
                    double longitude = data.getDouble(1);
                    twinpush().setLocation(latitude, longitude);
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, true));
                    return true;
                case "updateLocation":
                    int accuracy = data.getInt(0);
                    LocationPrecision precision;
                    switch (accuracy) {
                        case FINE:
                            precision = LocationPrecision.FINE;
                            break;
                        case HIGH:
                            precision = LocationPrecision.HIGH;
                            break;
                        case LOW:
                            precision = LocationPrecision.LOW;
                            break;
                        case COARSE:
                            precision = LocationPrecision.COARSE;
                            break;
                        default:
                            precision = LocationPrecision.MEDIUM;
                            break;
                    }
                    twinpush().updateLocation(precision);
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, true));
                    return true;
                case "registerDevice":
                    this.registerEnabled = true;
                    register(callbackContext);
                    return true;
            }

        } catch (JSONException e) {
            callbackContext.error(e.getMessage());
        }
        return false;
    }

    @Override
    public void onStart() {
        super.onStart();
        twinpush().activityStart(cordova.getActivity());
    }

    @Override
    public void onStop() {
        super.onStop();
        twinpush().activityStop(cordova.getActivity());
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        checkPushNotification(intent);
    }

    // Checks if the intent contains a Push notification and displays rich content when appropriated
    private void checkPushNotification(Intent intent) {
        if (intent != null && intent.getAction() != null && intent.getAction().equals(NotificationIntentService.ON_NOTIFICATION_OPENED_ACTION)) {
            PushNotification notification = (PushNotification) intent.getSerializableExtra(NotificationIntentService.EXTRA_NOTIFICATION);
            if (notification == null) {
                return;
            }

            twinpush().onNotificationOpen(notification);

            Log.v(LOG_TAG, "Received push notification");
            if (notificationOpenCallback != null) {
                sendNotificationToCallback(notification);
            }
            else {
                // No listener registered, save notification for later use
                lastNotification = notification;
            }

            if (notification.isRichNotification()) {
                Intent richIntent = new Intent(cordova.getActivity(), RichNotificationActivity.class);
                richIntent.putExtra(NotificationIntentService.EXTRA_NOTIFICATION, notification);
                cordova.getActivity().startActivity(richIntent);
            }
        }
    }

    private void sendNotificationToCallback(PushNotification notification) {
        try {

            // Send notification serialized as JSON, Javascript plugin will deserialize it
            JSONObject json = new JSONObject();
            json.put("notificationId", notification.getId());
            json.put("message", notification.getMessage());
            json.put("title", notification.getTitle());
            json.put("contentUrl", notification.getRichURL());
            json.put("tags", notification.getTags());
            if (notification.getCustomProperties() != null) {
                json.put("customProperties", new JSONObject(notification.getCustomProperties()));
            }
            if (notification.getDate() != null) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault());
                json.put("date", sdf.format(notification.getDate()));
            }
            PluginResult result = new PluginResult(PluginResult.Status.OK, json.toString());

            Log.v(LOG_TAG, "Sending push notification to callback listener: " + json);

            notificationOpenCallback.sendPluginResult(result);
        }
        catch (JSONException e) {
            PluginResult result = new PluginResult(PluginResult.Status.ERROR, e.getMessage());
            notificationOpenCallback.sendPluginResult(result);
        }
    }

    private void register(CallbackContext callback) {
        twinpush().register(this.alias, new TwinPushSDK.OnRegistrationListener() {
            @Override
            public void onRegistrationSuccess(String currentAlias) {
                String deviceId = twinpush().getDeviceId();
                if (registerCallback != null) {
                    PluginResult result = new PluginResult(PluginResult.Status.OK, deviceId);
                    result.setKeepCallback(true);
                    registerCallback.sendPluginResult(result);
                }
                if (callback != null) {
                    callback.success(deviceId);
                }
            }

            @Override
            public void onRegistrationError(Exception exception) {
                if (registerCallback != null) {
                    PluginResult result = new PluginResult(PluginResult.Status.ERROR, exception.getMessage());
                    result.setKeepCallback(true);
                    registerCallback.sendPluginResult(result);
                }
                if (callback != null) {
                    callback.error(exception.getMessage());
                }
            }
        });
    }
}
