import 'dart:io';

import 'package:bandsocket/models/band.dart';
import 'package:bandsocket/src/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> band = [
/*     Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Iron Maiden', votes: 5),
    Band(id: '3', name: 'A7x', votes: 5),
    Band(id: '4', name: '21 Pilots', votes: 5),
    Band(id: '5', name: 'Dream theater', votes: 5) */
  ];
  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('bandas-activas', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.band = (payload as List).map((banda) => Band.fromMap(banda)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: [
          Container(
              margin: EdgeInsets.only(right: 10),
              child: (socketService.serverStatus == ServerStatus.Online)
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                    )
                  : Icon(
                      Icons.offline_bolt,
                      color: Colors.red,
                    ))
        ],
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
                itemCount: band.length,
                itemBuilder: (context, i) {
                  return bandTile(band[i]);
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addNewBand,
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      onDismissed: (direction) {
        // print('id: ${band.id}');
        socketService.socket.emit('delete-band', {'id': band.id});
      },
      direction: DismissDirection.startToEnd,
      background: Container(
          padding: EdgeInsets.only(left: 8),
          color: Colors.red,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Delete Band', style: TextStyle(color: Colors.white)),
          )),
      key: Key(band.id),
      child: ListTile(
        title: Text(band.name),
        leading: CircleAvatar(
          child: Text(
            band.name.substring(0, 2),
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.purple,
        ),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        onTap: () {
          socketService.socket.emit('vote-band', {'id': band.id});
          print(band.id);
        },
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              actions: [
                MaterialButton(
                  child: Text('add'),
                  elevation: 5,
                  textColor: Colors.blue,
                  onPressed: () {
                    addBandToList(textController.text);
                  },
                )
              ],
              title: Text('New band name'),
              content: TextField(
                controller: textController,
              ),
            );
          });
    }
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text('new band name:'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('add'),
                onPressed: () {
                  addBandToList(textController.text);
                },
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    //   "Flutter": 5,
    band.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return Container(
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: false,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
          ),
        ));
  }
}
