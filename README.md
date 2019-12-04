### Installation

To install the plugin in your Cordova application, add the plugin using cordova CLI and add the required parameters:

    cordova plugin add https://github.com/TwinPush/twinpush-cordova-plugin.git --variable APP_ID="YOUR_APP_ID" --variable API_KEY="YOUR_API_KEY"

This is the list of the allowed parameters, all of them must follow the format `--variable VARIABLE_NAME="VARIABLE_VALUE"` and can be later modified in the `config.xml` file as preferences:

- `APP_ID` is the Application Identifier in the TwinPush platform. It can be obtained from the TwinPush web console in the Application settings section. This parameter is required. It can be later modified as `TwinPush_AppId` in the project _config.xml_ file.

- `API_KEY` is the API Authentication Key required to connect to the TwinPush API. It can be obtained from the TwinPush web console in the Application settings section. This parameter is required. It can be later modified as `TwinPush_ApiKey` in the project _config.xml_ file.

- `SUBDOMAIN` variable is optional and defaults to `app`. It only has to be set if you are using a custom subdomain. It can be later modified as `TwinPush_Subdomain` in the project _config.xml_ file.


#### FCM configuration for Android

Make sure you've correctly [setup Firebase Cloud Messaging](http://developers.twinpush.com/developers/android#setup-firebase-cloud-messaging) and [created your Application in TwinPush](http://developers.twinpush.com/developers/android#register-your-application-in-twinpush) before continuing.

Access to the [Firebase console](https://console.firebase.google.com) and [download `google-services.json`](https://support.google.com/firebase/answer/7015592) for your current project and place it in your project root folder.

Then use `<resource-file>` in your `config.xml` to copy the file into appropriate folder:

    <platform name="android">
        <resource-file src="google-services.json" target="app/google-services.json" />
        ...
    </platform>

This step may ocasionally cause compilation errors due to gradle daemons locking the file. In that case, make sure to stop all gradle daemons before compiling with `gradle --stop`.

#### Location privacy configuration for iOS

TwinPush makes use of the Location API for iOS and Apple requires that all applications that use Location API must include a usage description in the plist file. The easiest way to achieve it is by adding a `edit-config` entry inside your platform configuration for iOS in your `config.xml`:

    <platform name="ios">
        <edit-config target="NSLocationAlwaysAndWhenInUseUsageDescription" file="*-Info.plist" mode="merge">
            <string>your custom text here</string>
        </edit-config>
        <edit-config target="NSLocationAlwaysUsageDescription" file="*-Info.plist" mode="merge">
            <string>your custom text here</string>
        </edit-config>
    </platform>

The text will be shown to the user when asked for permission.

AppStore submissions requires that applications that references the Location API must include this description even when they're not acively using this functionality.

### Ionic

TwinPush Plugin for Cordova also provides type definition for TypeScript to provide out-of-the-box compatibility with Ionic. To access the TwinPush plugin, simply add `import 'twinpush';` sentence in your component. You'll have access to the global `twinpush` variable and your IDE will provide auto-completion and type safety.

![](https://i.imgur.com/n9Ijquz.png)


### Basic TwinPush integration

Once installed, the plugin will automatically register for push notifications and track activity events. You can extend the default integration by calling the exposed TwinPush methods.

#### Alias

You can set the device alias by calling the `setAlias` method of the `twinpush` module:

    var success = function(message) {
        alert(message); // This is only for testing purposes
    };

    var failure = function() {
        alert("Error calling setAlias method");
    };

    twinpush.setAlias("email@company.com", success, failure);


#### Device ID

You can obtain the TwinPush identifier for the current device by calling the `getDeviceId` method of the `twinpush` module:

    var success = function(deviceId) {
        alert("Device ID: " + deviceId);
    };

    twinpush.getDeviceId(success);

If the device hasn't registered yet, `deviceId` will be `null`.


#### Register callback

To perform some action when the registration against the TwinPush platform has been successful, you can register using `setRegisterCallback` method:

    var success = function(deviceId) {
        alert("Registered with Device ID: " + deviceId);
    };

    var failure = function() {
        alert("Error registering device in TwinPush");
    };

    twinpush.setRegisterCallback(success, failure);

The callback will be called for every successfully register. Calling `setAlias` also triggers a register, so the callback will also be invoked when `setAlias` method is called.

#### Custom properties

Custom properties can be set using the exposed methods of the TwinPush SDK. These properties will be sent to the server, and can be used for statistics generation and notification segmentation.

Use the aproppiate method depending of the value type:

    twinpush.setIntegerProperty("age", 23, function(value) {
        alert("Age set to " + value);
    });
    twinpush.setFloatProperty("rating", 6.7, function(value) {
        alert("Rating set to " + value);
    });
    twinpush.setBooleanProperty("single", false, function(value) {
        alert("Single set to " + value);
    });
    twinpush.setStringProperty("fullName", "Bruce Wayne", function(value) {
        alert("Full Name set to " + value);
    });

#### Updating location

User location can be sent to TwinPush in order to perform geo-located segments. Two methods are provided to send the location either explicitly or automatically:

    twinpush.setLocation(40.416616, -3.704415, function(value) {
        alert("Location explicitly set");
    });
    twinpush.updateLocation(twinpush.LocationPrecision.HIGH, function(value) {
        alert("Location automatically set");
    });

Precision for `updateLocation` method can be one of these values:
- `FINE`
- `HIGH`
- `MEDIUM`
- `LOW`
- `COARSE`

Higher precisions may take longer to obtain and will drain more battery.

