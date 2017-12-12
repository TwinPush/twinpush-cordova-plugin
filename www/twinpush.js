var exec = require('cordova/exec');

module.exports = {
	setAlias: function(alias, successCallback, errorCallback = () => {}) {
		cordova.exec(successCallback, errorCallback, 'TwinPush', 'setAlias', [alias]);
	},

	setRegisterCallback: function(successCallback, errorCallback = () => {}) {
		cordova.exec(successCallback, errorCallback, 'TwinPush', 'setRegisterCallback', []);
	},

	getDeviceId: function(successCallback) {
		cordova.exec(successCallback, () => {}, 'TwinPush', 'getDeviceId', []);	
	}
}