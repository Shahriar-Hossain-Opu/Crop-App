import 'package:flutter/material.dart';
import 'Sensorpage.dart'; // Import the SensorDataPage
import 'graph.dart'; // Import the GraphActivity

class PondPage extends StatefulWidget {
  @override
  _PondPageState createState() => _PondPageState();
}

class _PondPageState extends State<PondPage> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Info Page'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isGridView = !_isGridView;
          });
        },
        child: Icon(_isGridView ? Icons.list : Icons.grid_on),
      ),
    );
  }

  Widget _buildBody() {
    if (_isGridView) {
      return _buildGridView();
    } else {
      return _buildListView();
    }
  }

  Widget _buildListView() {
    return ListView(
      padding: EdgeInsets.all(8.0),
      children: [
        _buildPondCard('Field 1', 'assets/pond1.jpg'),
        _buildPondCard('Field 2', 'assets/pond2.jpg'),
        _buildPondCard('Field 3', 'assets/pond3.jpg'),
        _buildPondCard('Field 4', 'assets/pond4.jpg'),
      ],
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(8.0),
      children: [
        _buildPondCard('Field 1', 'assets/pond1.jpg'),
        _buildPondCard('Field 2', 'assets/pond2.jpg'),
        _buildPondCard('Field 3', 'assets/pond3.jpg'),
        _buildPondCard('Field 4', 'assets/pond4.jpg'),
      ],
    );
  }

  Widget _buildPondCard(String pondName, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SensorDataPage(),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        margin: EdgeInsets.all(8.0),
        child: SizedBox(
          height: 200.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pondName,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'See the Current Status',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GraphActivity(),
                          ),
                        );
                      },
                      child: Text('Info'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Field Info Page',
    debugShowCheckedModeBanner: false,
    home: PondPage(),
  ));
}
