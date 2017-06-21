### Installation

To install the plugin in your Cordova application, add the plugin using cordova CLI and add the required parameters:

    cordova plugin add https://github.com/TwinPush/twinpush-cordova-plugin.git --variable APP_ID="YOUR_APP_ID" --variable API_KEY="YOUR_API_KEY" --variable SUBDOMAIN="app"
    
`SUBDOMAIN` variable is optional and defaults to `app`. `APP_ID` and `API_KEY` are required. The plugin will fail to install if they are not specified.

### Basic TwinPush integration
    
Once installed, the plugin will automatically register for push notifications and track activity events. You can extend the default integration by calling the exposed TwinPush methods.

#### Alias

You can set the device alias by calling the `setAlias` method of the `twinpush` module:

    var success = function(message) {
        alert(message); // This is only for testing purposes
    }

    var failure = function() {
        alert("Error calling setAlias method");
    }

    twinPush.setAlias("email@company.com", success, failure);
    
