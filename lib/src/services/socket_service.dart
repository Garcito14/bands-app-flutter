import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;
  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;
  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    this._socket = IO.io('http://192.168.100.11:3000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    this._socket.on('connect', (_) {
      /* socket.emit('msg', 'test'); */
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    // socket.on('event', (data) => print(data));
    this._socket.on('disconnect', (_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
/*     socket.on('nuevo-mensaje', (payload) {
      print('nuevo-mensaje:');
      print('nombre: ' + payload['nombre']);
      print('mensaje: ' + payload['mensaje']);
      //print('mensaje: ' + payload['mensaje2']);
      print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'no hay');
    }); */
    // socket.on('fromServer', (_) => print(_));
  }
}
