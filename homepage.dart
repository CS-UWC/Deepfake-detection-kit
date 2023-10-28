
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'loadingpage.dart';




class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> filePickerAndNavigate() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    

    if (result != null) {
      // User selected a file, navigate to the next page.
      final String? selectedFile = result.files.single.path;
      
Navigator.push(context, MaterialPageRoute(builder: (context) {
        return LoadingScreen(file: selectedFile.toString());
       
        
      }));    
} 
  else {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('No image selected'),
      duration: Duration(seconds: 5), 
    ),
  );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Upload video or image below:',
            ),
            ElevatedButton(
              onPressed: filePickerAndNavigate,
              child: Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}



