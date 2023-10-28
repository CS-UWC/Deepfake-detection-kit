import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'forgotpassword.dart';
import 'homepage.dart';
import 'signinpage.dart';


class LoginPage extends StatefulWidget{
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String useremail = '';
  String pword = '';
  String title = "Welcome ";
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
      title += useremail;
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MyHomePage(title: title);
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