import 'dart:convert';
import 'dart:io';
import 'package:deepfake_detection_kit/presentation/screens/resultspage.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';


class LoadingScreen extends StatefulWidget {
  final String file; 
  
  const LoadingScreen({Key? key, required this.file}) : super(key: key);
  
  
  



  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    waitingtogo(widget.file);
  }
  

  
  Future<void> waitingtogo(String image) async {
  

  
  final socket = await Socket.connect('127.0.0.1', 12345);
  
  String response = ' ';

  socket.add(utf8.encode(image));
  socket.flush();
socket.listen(
      (data) {
        response = String.fromCharCodes(data).trim();
        if (response.startsWith("1")) {
    
      
     
    Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ResultsPage(result: "1", file: widget.file);
       
        
      }));    
      } 
else if(response.startsWith("0")){
 Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ResultsPage(result: "0", file: widget.file);
       
        
      }));

}      

else { 
Navigator.push(context, MaterialPageRoute(builder: (context) {
                 return const MyHomePage(title: 'Welcome back, the image you gave had no face');
                  }));
    }
      }
       
        
);

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}