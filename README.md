# Cordova Local Devices Plugin

Plugin for scanning and recognizing devices in local network for Android.

### Intallation

`cordova plugin add https://github.com/arys/cordova-plugin-local-devices.git`

### Usage

```
LocalDevices.scan({
  onProgress: (devices) => console.log(devices), // Progress callback
  timeout: 1000, // Timeout between requests in ms, default: 500 ms
  deviceTypesToRecognize: [LocalDevices.DEVICE_TYPES.ESC_POS],
})
  .then((devices) => {
    console.log(devices);
  })
  .catch(console.error);
```

```
For IOS:
const localDevice = cordova.require('cordova-plugin-local-devices.local-device');

localDevice.scan({
  timeout: 5000, // 5 seconds in milliseconds
  deviceTypesToRecognize: [], // Currently not filtered in native code
  onProgress: ({ pinged, total }) => {
    console.log(`Scanned ${pinged} of ${total} hosts`);
  }
})
.then(results => {
  console.log('Found devices:', results.devices);
})
.catch(err => {
  console.error('Scan failed:', err);
});
```

Response example

```
[
  {
    ip: "192.168.1.100",
    name: "ESC/POS",
    type: "printer-escpos"
  },
  {
    ip: "192.168.1.212",
    name: "Urecognized",
    type: "urecognized"
  }
]
```

### Supported Platforms

- Android 5.1+
