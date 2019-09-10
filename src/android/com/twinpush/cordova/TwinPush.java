package com.twinpush.cordova;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import com.twincoders.twinpush.sdk.TwinPushSDK;
import com.twincoders.twinpush.sdk.activities.RichNotificationActivity;
import com.twincoders.twinpush.sdk.entities.TwinPushOptions;
import com.twincoders.twinpush.sdk.entities.LocationPrecision;
import com.twincoders.twinpush.sdk.notifications.PushNotification;
import com.twincoders.twinpush.sdk.services.NotificationIntentService;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

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

    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();

        TwinPushOptions options = new TwinPushOptions();
        options.twinPushAppId = preferences.getString("TwinPush_AppId", "");
        options.twinPushApiKey = preferences.getString("TwinPush_ApiKey", "");
        options.subdomain = preferences.getString("TwinPush_Subdomain", "app");

        twinpush().setup(options);
        twinpush().register(null, new TwinPushSDK.OnRegistrationListener() {
            @Override
            public void onRegistrationSuccess(String currentAlias) {
                if (registerCallback != null) {
                    String deviceId = twinpush().getDeviceId();
                    PluginResult result = new PluginResult(PluginResult.Status.OK, deviceId);
                    result.setKeepCallback(true);
                    registerCallback.sendPluginResult(result);
                }
            }

            @Override
            public void onRegistrationError(Exception exception) {
                if (registerCallback != null) {
                    PluginResult result = new PluginResult(PluginResult.Status.ERROR, exception.getMessage());
                    result.setKeepCallback(true);
                    registerCallback.sendPluginResult(result);
                }
            }
        });
        checkPushNotification(cordova.getActivity().getIntent());
    }

    @Override
    public boolean execute(final String action, final JSONArray data, final CallbackContext callbackContext) {
        try {
            Log.v(LOG_TAG, action);
            if ("setAlias".equals(action)) {
                String alias = data.getString(0);
                twinpush().register(alias, new TwinPushSDK.OnRegistrationListener() {
                    @Override
                    public void onRegistrationSuccess(String currentAlias) {
                        callbackContext.success("Successfully registered");
                        if (registerCallback != null) {
                            String deviceId = twinpush().getDeviceId();
                            PluginResult result = new PluginResult(PluginResult.Status.OK, deviceId);
                            result.setKeepCallback(true);
                            registerCallback.sendPluginResult(result);
                        }
                    }

                    @Override
                    public void onRegistrationError(Exception exception) {
                        callbackContext.error(exception.getMessage());
                        if (registerCallback != null) {
                            PluginResult result = new PluginResult(PluginResult.Status.ERROR, exception.getMessage());
                            result.setKeepCallback(true);
                            registerCallback.sendPluginResult(result);
                        }
                    }
                });
                return true;
            }
            else if ("setRegisterCallback".equals(action)) {
                registerCallback = callbackContext;
                return true;
            }
            else if ("getDeviceId".equals(action)) {
                callbackContext.success(twinpush().getDeviceId());
                return true;
            }
            else if ("setIntegerProperty".equals(action)) {
                String key = data.getString(0);
                Integer value = data.getInt(1);
                twinpush().setProperty(key, value);
                callbackContext.success(value);
                return true;
            }
            else if ("setFloatProperty".equals(action)) {
                String key = data.getString(0);
                Double value = data.getDouble(1);
                twinpush().setProperty(key, value);
                PluginResult result = new PluginResult(PluginResult.Status.OK, value.floatValue());
                callbackContext.sendPluginResult(result);
                return true;
            }
            else if ("setBooleanProperty".equals(action)) {
                String key = data.getString(0);
                Boolean value = data.getBoolean(1);
                twinpush().setProperty(key, value);
                PluginResult result = new PluginResult(PluginResult.Status.OK, value);
                callbackContext.sendPluginResult(result);
                return true;
            }
            else if ("setStringProperty".equals(action)) {
                String key = data.getString(0);
                String value = data.getString(1);
                twinpush().setProperty(key, value);
                callbackContext.success(value);
                return true;
            }
            else if ("setLocation".equals(action)) {
                Double latitude = data.getDouble(0);
                Double longitude = data.getDouble(1);
                twinpush().setLocation(latitude, longitude);
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, true));
                return true;
            }
            else if ("updateLocation".equals(action)) {
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
            twinpush().onNotificationOpen(notification);

            if (notification != null && notification.isRichNotification()) {
                Intent richIntent = new Intent(cordova.getActivity(), RichNotificationActivity.class);
                richIntent.putExtra(NotificationIntentService.EXTRA_NOTIFICATION, notification);
                cordova.getActivity().startActivity(richIntent);
            }
        }
    }
}
