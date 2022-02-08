import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wifi_connector/wifi_connector.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _ssidController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  var _isSucceed = false;
  var _loading = false;
  var _hasPermission = false;
  var _securityType = SecurityType.WPA2;
  var _internetRequired = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Wifi connector example app'),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: ElevatedButton(
                child: Text(
                  'Has Permission',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _onHasPermissionClicked,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: ElevatedButton(
                child: Text(
                  'Open Permission screen',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _onRequestPermissionClicked,
              ),
            ),
            Text(
              'Has permission?: $_hasPermission',
              textAlign: TextAlign.center,
            ),
            if (_hasPermission) ...[
              _buildTextInput(
                'ssid',
                _ssidController,
              ),
              _buildTextInput(
                'password',
                _passwordController,
              ),
              if (Platform.isAndroid)
                SwitchListTile(
                  title: Text('Internet Required'),
                  value: _internetRequired,
                  onChanged: (value) {
                    setState(() {
                      _internetRequired = value;
                    });
                  },
                ),
              for (final item in SecurityType.values)
                ListTile(
                  title: Text(item.toString()),
                  onTap: () => _onSecurityTypeChanged(item),
                  leading: Radio<SecurityType>(
                    value: item,
                    groupValue: _securityType,
                    onChanged: (value) => _onSecurityTypeChanged(item),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: ElevatedButton(
                  child: Text(
                    'connect',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _onConnectPressed,
                ),
              ),
              Text(
                'Is wifi connected?: ${_loading ? '...' : _isSucceed}',
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(String title, TextEditingController controller) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Container(width: 80.0, child: Text(title)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: TextField(
              controller: controller,
              onChanged: (value) => setState(
                () {},
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _onConnectPressed() async {
    final ssid = _ssidController.text;
    final password = _passwordController.text;
    setState(() {
      _isSucceed = false;
      _loading = true;
    });
    try {
      final isSucceed = await WifiConnector.connectToWifi(
        ssid: ssid,
        password: password,
        internetRequired: _internetRequired,
        securityType: _securityType,
      );
      _isSucceed = isSucceed;
    } catch (e, stack) {
      print('Error: $e\n$stack');
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _onHasPermissionClicked() => _checkPermission();

  Future<void> _onRequestPermissionClicked() => WifiConnector.openPermissionsScreen();

  Future<void> _checkPermission() async {
    final hasPermission = await WifiConnector.hasPermission();
    setState(() => _hasPermission = hasPermission);
  }

  void _onSecurityTypeChanged(SecurityType item) {
    setState(() {
      _securityType = item;
    });
  }
}
