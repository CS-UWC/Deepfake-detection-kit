
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deepfake detection kit',
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

Future<bool> verifyUser(useremail, password) async {
  Socket socket;
  bool verify = false;
  final completer = Completer<bool>(); // Create a Completer

  try {
    socket = await Socket.connect('127.0.0.1', 12345); // Use the server IP and port
    print('Connected to server');

    String message = "verify " + useremail + " " + password;
    socket.write(message);

    socket.listen(
      (data) {
        String response = String.fromCharCodes(data).trim();
        print('Received: $response');
        if (response == "t") {
          verify = true;
        }
      },
      onError: (error) {
        print('Error: $error');
        socket.close();
        completer.complete(false); // Set the completer value to false on error
      },
      onDone: () {
        print('Connection closed by server');
        socket.close();
        completer.complete(verify); // Set the completer value to verify when done
      },
    );
  } catch (e) {
    print('Error: $e');
    completer.complete(false); // Set the completer value to false on exception
  }

  return completer.future; // Return the future from the completer
}


Future<String> sendImageToServer(File image) async {
  List<int> bytes = await image.readAsBytes();

  final socket = await Socket.connect('127.0.0.1', 12345);
  String base64Image = base64Encode(bytes);
  String response = ' ';

  socket.add(utf8.encode(base64Image));
  socket.flush();
socket.listen(
      (data) {
        response = String.fromCharCodes(data).trim();
      }
       
        
);


  // socket.close();
  return response;
}


 





// Stucking at the upload button
//Home page
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
      final File selectedFile = File(result.files.single.path!);
      sendImageToServer(selectedFile);
Navigator.push(context, MaterialPageRoute(builder: (context) {
        return LoadingScreen(file: selectedFile,);
      }));    } else {
      print("niks");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Welcome user'),
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



//Login page
class LoginPage extends StatefulWidget{
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String useremail = '';
  String pword = '';
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();

    
  }@override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
       
        title: Text('Log-in or Sign-up:'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
         
         mainAxisAlignment: MainAxisAlignment.center,
         children: 
         <Widget>[
           const Text(
             'Log-in or Sign-up:',
           ),
      
           SizedBox(height: 20,),
           const Text('Enter your username:'),
           
      
          Padding(
         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
         child: 
         
         TextField(
          decoration: InputDecoration(
             border: OutlineInputBorder(), 
             hintText: 'Enter username',
           ),
           onChanged: (value) {
             setState(() {
               useremail = value;
             });
           },

         ),
          ),
          SizedBox(height: 20,),
           const Text('Enter your password:'),
           
      
          Padding(
         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
         child: 
         
         TextField(
           obscureText: true,
           decoration: InputDecoration(
             border: OutlineInputBorder(),
             hintText: 'Enter password',
           ),
           onChanged: (value) {
             setState(() {
               pword = value;
             });
           },
         ),
          ),
          SizedBox(height: 20,),
           
           Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               ElevatedButton(
  onPressed: () async {
    bool success = await verifyUser(useremail, pword);
    
    if (success) {
      print('logged in!');
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const MyHomePage(title: 'Welcome User');
      }));
    } else {
      print('Login failed');
      // Show a snackbar with the error message
      final snackBar = SnackBar(
        content: Text('Login details are incorrect.'),
        duration: Duration(seconds: 3), // Adjust the duration as needed
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  },
  child: Text('Login'),
),
             
           
           ElevatedButton(onPressed: (){
             print('Signing up...');
             Navigator.push(context, MaterialPageRoute(builder: (context) {
                 return const SignupPage();
                  }));
           }, child: Text('Signup'),
           ),],
         
         ),
         TextButton(onPressed: (){
           Navigator.push(context, MaterialPageRoute(builder: (context) {
                 return const ForgotPasswordPage();
                  }));
         }, child: Text('Forgot Password?'))
         
          ],
        ),
      ));
  
  }


}  
//Loading page - figuring out


class LoadingScreen extends StatefulWidget {
  final File file; // Assuming you need to pass the selected file to the loading screen
  
  const LoadingScreen({Key? key, required this.file}) : super(key: key);
  
  
  



  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    waitingtogo();
  }
  

  
  void waitingtogo() async {
  // Simulate a loading delay
  await Future.delayed(Duration(seconds: 2));

  Future<void> sendImageToFlask(File imageFile) async {
  var request = http.MultipartRequest('POST', Uri.parse('http://localhost:5000/detect_deepfake'));
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  try {
    final response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
      final jsonResponse = json.decode(await response.stream.bytesToString());
      // Access the JSON data
      bool isDeepfake = jsonResponse['is_deepfake'];
      print('Is Deepfake: $isDeepfake');

    } else {
      print('Failed to upload image. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error uploading image: $e');
  }
}

  File image = widget.file;
  sendImageToFlask(image);



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

//View Database page
class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});
  
  @override
  State<StatefulWidget> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage>{
  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        title: Text('Database: '),
        
      ),
      body: GridView.count( // edit to use database
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: 2,
          // Generate 100 widgets that display their index in the List.
          children: List.generate(100, (index) {
            return Center(
              child: Text(
                'Item $index',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
    );
  })));
  }
}


  //Sign-in page
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignupPageState(); 

  
}

class _SignupPageState extends State<SignupPage> 
{
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
appBar: AppBar(
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        title: Text('Sign-up'),
    ));
  }
}

  //Forgot Password page
class ForgotPasswordPage extends StatefulWidget{
  const ForgotPasswordPage({super.key});
  
  @override
  State<StatefulWidget> createState() => _ForgotPasswordPageState();


}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>{
  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
appBar: AppBar(
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        title: Text('Enter new details:'),
    ));
  }

}

  //Results page
  class ResultsPage extends StatefulWidget{
  const ResultsPage({super.key});

  @override
  State<StatefulWidget> createState() => _ResultsPage();

  }
  
  class _ResultsPage extends State<ResultsPage>{
  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        title: Text('Results:'),
    ));
  }

  }
