import 'package:flutter/material.dart';
import 'package:sosapp/models/Kullanici.dart';
import 'package:sosapp/pages/profile.dart';
import 'package:sosapp/services/firestoresevice.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  Future<List<Kullanici>> _searchResult;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(),
      body: _searchResult != null ? getResults() : noSearch(),
    );
  }

  AppBar _createAppBar() {
    return AppBar(
      titleSpacing: 0.0,
      backgroundColor: Colors.grey[100],
      title: TextFormField(
        onFieldSubmitted: (input) {
          setState(() {
            _searchResult = FireStoreService().searchUser(input);
          });
        },
        controller: _searchController,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, size: 30.0),
            suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchResult = null;
                  });
                }),
            border: InputBorder.none,
            fillColor: Colors.white,
            filled: true,
            hintText: "Search...",
            contentPadding: EdgeInsets.only(top: 16.0)),
      ),
    );
  }

  noSearch() {
    return Center(child: Text("Search for a User!"));
  }

  getResults() {
    return FutureBuilder<List<Kullanici>>(
      future: _searchResult,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        if (snapshot.data.length == 0) return Center(child: Text("No result!"));
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            Kullanici user = snapshot.data[index];
            return userLine(user);
          },
        );
      },
    );
  }

  userLine(Kullanici user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Profile(
                      profilId: user.id,
                    )));
      },
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: user.fotoUrl.isNotEmpty
                ? NetworkImage(user.fotoUrl)
                : AssetImage("assets/images/defaultProfilePic.png")),
        title: Text(
          user.kullaniciAdi,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
