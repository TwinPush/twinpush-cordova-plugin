var exec = require('cordova/exec');

module.exports = {
	setAlias: function(alias, successCallback, errorCallback = () => {}) {
		cordova.exec(successCallback, errorCallback, 'TwinPush', 'setAlias', [alias]);
	}
}