import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class Post {
  final int? codi;
  final String? titol;
  final int? primer;
  final String? text1;
  final int? segon;
  final String? text2;

  Post({this.codi, this.titol, this.primer, this.text1, this.segon, this.text2});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      codi: json['codi'],
      titol: json['titol'],
      primer: json['primer'],
      text1: json['text1'],
      segon: json['segon'],
      text2: json['text2'],
    );
  }
}

class Album {
  final int? id;
  final String? titol;

  Album({this.id, this.titol});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      titol: json['titol'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectDrawerItem = 0;

  _onSelectItem(int pos) {
    setState(() {
      _selectDrawerItem = pos;
    });
  }

  String barcode = "";
  int primer = 0;
  String txt1 = "";
  int segon = 0;
  String txt2 = "";
  String tit = "";

  Future scanCode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() => this.barcode = result.rawContent);
      setState(() {
        if (tit != "") {
          createAlbum(tit);
        }
      });
    } catch (e) {
      if (e.toString().contains('CameraAccessDenied')) {
        setState(() {
          this.barcode = 'No ha donat permís de càmera!';
        });
      } else {
        setState(() => this.barcode = 'Error desconegut: $e');
      }
    }
  }

  Future<Post> fetchPost(String barcode) async {
    final response = await http.get(Uri.parse('http://192.168.1.89:3030/productes/$barcode'));
    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body)[0]);
    } else {
      throw Exception('No s’ha pogut carregar la publicació');
    }
  }

  Future<Album> createAlbum(String titol) async {
    final http.Response response = await http.post(
      Uri.parse('http://192.168.1.89:3030/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': '1',
        'titol': titol,
      }),
    );
    if (response.statusCode == 201) {
      return Album.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load album');
    }
  }

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;

  bool isDisconnecting = false;

  bool get isConnected => connection != null && connection!.isConnected;

  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    enableBluetooth();

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  Future<bool> enableBluetooth() async {
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _devicesList = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Image.asset('assets/dibuix_logo.png', width: 50)),
          backgroundColor: Colors.green,
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text('Marta Grandia'),
                accountEmail: Text('marta.grandia01@estudiant.upf.edu'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text('M', style: TextStyle(fontSize: 40.0)),
                ),
              ),
              ListTile(
                title: Text('Escaneig'),
                leading: Icon(Icons.camera_alt),
                selected: (0 == _selectDrawerItem),
                onTap: () {
                  _onSelectItem(0);
                },
              ),
              ListTile(
                title: Text('Historial'),
                leading: Icon(Icons.photo),
                selected: (1 == _selectDrawerItem),
                onTap: () {
                  _onSelectItem(1);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondRoute()),
                  );
                },
              ),
              ListTile(
                title: Text('Afegir Producte'),
                leading: Icon(Icons.add),
                selected: (2 == _selectDrawerItem),
                onTap: () {
                  _onSelectItem(2);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AfegirItem()),
                  );
                },
              ),
            ],
          ),
        ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Visibility(
                visible: _isButtonUnavailable &&
                    _bluetoothState == BluetoothState.STATE_ON,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.green[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[500]!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Activar Bluetooth',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          } else {
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                          }

                          await getPairedDevices();
                          _isButtonUnavailable = false;

                          if (_connected) {
                            _disconnect();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    )
                  ],
                ),
              ),
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Dispositiu:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<BluetoothDevice>(
                              items: _getDeviceItems(),
                              onChanged: (value) =>
                                  setState(() => _device = value),
                              value: _devicesList.isNotEmpty ? _device : null,
                            ),
                            ElevatedButton(
                              onPressed: _isButtonUnavailable
                                  ? null
                                  : _connected ? _disconnect : _connect,
                              child:
                                  Text(_connected ? 'Disconnect' : 'Connect'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<Post>(
                          future: fetchPost(barcode),
                          builder: (context, snapshot) {
                            if (barcode == "") {
                              return Text("escanejeu un codi de barres");
                            }
                            if (snapshot.hasData) {
                              txt1 = snapshot.data!.text1 ?? "";
                              txt2 = snapshot.data!.text2 ?? "";
                              primer = snapshot.data!.primer ?? 0;
                              segon = snapshot.data!.segon ?? 0;
                              tit = snapshot.data!.titol ?? "";

                              if (txt2 == "res") {
                                _sendMessageToBluetooth(primer, segon);
                                return Text("$txt1");
                              } else {
                                _sendMessageToBluetooth(primer, segon);
                                return Text("$txt1 i a continuació $txt2");
                              }
                            } else if (snapshot.hasError) {
                              return ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AfegirItem()),
                                  );
                                },
                                child: Text('Afegir producte'),
                              );
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: scanCode,
          tooltip: 'Scan',
          backgroundColor: Colors.green,
          child: Icon(Icons.scanner),
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      for (var device in _devicesList) {
        items.add(DropdownMenuItem(
          child: Text(device.name ?? "Dispositiu sense nom"),
          value: device,
        ));
      }
    }
    return items;
  }

  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device!.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection!.input?.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        show('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
    });

    await connection?.close();
    show('Device disconnected');
    if (connection != null && !connection!.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  void _sendMessageToBluetooth(int primer, int segon) async {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(utf8.encode("$primer\r\n$segon\r\n"));
      await connection!.output.allSent;
      show('enviada informació a EcoBross');
    }
  }

  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(Duration(milliseconds: 100));
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  Future<List<Album>> fetchDate(String id) async {
    final response = await http.get(Uri.parse('http://192.168.1.89:3030/historial/$id'));
    if (response.statusCode == 200) {
      var jsonList = json.decode(response.body) as List;
      return jsonList.map((element) => Album.fromJson(element)).toList();
    } else {
      throw Exception('No s’ha pogut carregar la publicació');
    }
  }

  @override
  Widget build(BuildContext context) {
    int num = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text("Historial d'escaneig"),
      ),
      body: FutureBuilder<List<Album>>(
        future: fetchDate('1'),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                var prod = snapshot.data![index];
                num = index + 1;
                return ListTile(
                  title: Text(prod.titol ?? ""),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Encara no ha escanejat cap producte"),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text("$num/30"),
              );
            },
          );
        },
        tooltip: 'Aconseguit!',
        backgroundColor: Colors.green,
        child: Icon(Icons.equalizer),
      ),
    );
  }
}

class AfegirItem extends StatelessWidget {
  final _claveFormulario = GlobalKey<FormState>();
  final TextEditingController _barcode = TextEditingController();
  final TextEditingController _titolProd = TextEditingController();
  final TextEditingController _primer = TextEditingController();
  final TextEditingController _txt1 = TextEditingController();
  final TextEditingController _segon = TextEditingController();
  final TextEditingController _txt2 = TextEditingController();

  Future<Post> createproducte(
      String codi, String titol, String primer, String text1, String segon, String text2) async {
    final http.Response response = await http.post(
      Uri.parse('http://192.168.1.89:3030/afegir'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'codi': codi,
        'titol': titol,
        'primer': primer,
        'text1': text1,
        'segon': segon,
        'text2': text2,
      }),
    );
    if (response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Afegir producte"),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introdueix el codi de barres del producte';
                  }
                  return null;
                },
                controller: _barcode,
                decoration: InputDecoration(
                  hintText: 'Introdueix el codi de barres del producte',
                  labelText: "Codi de barres",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Escriu el títol del producte';
                  }
                  return null;
                },
                controller: _titolProd,
                decoration: InputDecoration(
                  hintText: 'Escriu el títol',
                  labelText: "Títol",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'On és llençar la primera part? (1=plàstic, 2=paper i 3=vidre)';
                  }
                  return null;
                },
                controller: _primer,
                decoration: InputDecoration(
                  hintText: 'On és llençar la primera part? (1=plàstic, 2=paper i 3=vidre)',
                  labelText: "On llençar la primera part",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Primera descripció que veuran els usuaris';
                  }
                  return null;
                },
                controller: _txt1,
                decoration: InputDecoration(
                  hintText: 'Primera descripció que veuran els usuaris',
                  labelText: "Descripció 1",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'On és llençar la segona part? (1=plàstic, 2=paper i 3=vidre)';
                  }
                  return null;
                },
                controller: _segon,
                decoration: InputDecoration(
                  hintText: 'On és llençar la segona part? (1=plàstic, 2=paper i 3=vidre)',
                  labelText: "On llençar la segona part",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Segona descripció que veuran els usuaris';
                  }
                  return null;
                },
                controller: _txt2,
                decoration: InputDecoration(
                  hintText: 'Segona descripció que veuran els usuaris',
                  labelText: "Descripció 2",
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              createproducte(
                  _barcode.text, _titolProd.text, _primer.text, _txt1.text, _segon.text, _txt2.text);
              return AlertDialog(
                content: Text("producte afegit"),
              );
            },
          );
        },
        tooltip: 'Aconseguit!',
        backgroundColor: Colors.green,
        child: Icon(Icons.check),
      ),
    );
  }
}
