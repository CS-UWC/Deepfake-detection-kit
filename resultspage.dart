import 'dart:io';
import 'package:deepfake_detection_kit/presentation/screens/homepage.dart';
import 'package:flutter/material.dart';

class ResultsPage extends StatefulWidget{
final String file;
final String result;

  const ResultsPage({super.key, required this.result, required this.file});

  @override
  State<StatefulWidget> createState() => _ResultsPage();

  }
  
  class _ResultsPage extends State<ResultsPage>{
  @override
  Widget build(BuildContext context) {
    String resultdeepfake;

    if (widget.result.startsWith("0")){
      resultdeepfake = "This image is not a deepfake";
    }
    
    else if (widget.result.startsWith("1")){
      resultdeepfake = "This image is a deepfake";
    }
    else{
      resultdeepfake = "Could not determine";
    }
    
    return Scaffold(
      
    body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            
              DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(widget.file)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  width: 1000, 
                  height: 600,
                  alignment: Alignment.center,
                  child: Text(resultdeepfake),
                  
                ),
              ),
              ElevatedButton(onPressed: (){
           
             Navigator.push(context, MaterialPageRoute(builder: (context) {
                 return const MyHomePage(title: 'Welcome back');
                  }));
           }, child: Text('Return to home'),
        )],
        ),
      ),
    );
  }

  }