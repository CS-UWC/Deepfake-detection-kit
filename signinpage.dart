import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'loginpage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignupPageState(); 

  
}

class _SignupPageState extends State<SignupPage> 
{  var useremail="";
       var firstname="";
       var lastname="";
     var pword="";
  @override
  Widget build(BuildContext context) {
     
     
    
    return Scaffold(
appBar: AppBar(
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
       
        title: Text('Sign-up:'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
         
         mainAxisAlignment: MainAxisAlignment.center,
         children: 
         <Widget>[
           const Text(
             'Enter new details:',
           ),
      
           SizedBox(height: 20,),
           const Text('Enter your email:'),
           
      
          Padding(
         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
         child: 
         
         TextField(
          decoration: InputDecoration(
             border: OutlineInputBorder(), 
             hintText: 'Enter email',
           ),
           onChanged: (value) {
             setState(() {
               useremail = value;
             });
           },

         ),
          ),
          SizedBox(height: 20,),const Text('Enter your first name:'),
           
      
          Padding(
         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
         child: 
         
         TextField(
          decoration: InputDecoration(
             border: OutlineInputBorder(), 
             hintText: 'Enter first name',
           ),
           onChanged: (value) {
             setState(() {
               firstname = value;
             });
           },

         ),
          ),
          SizedBox(height: 20,),const Text('Enter your last name:'),
           
      
          Padding(
         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
         child: 
         
         TextField(
          decoration: InputDecoration(
             border: OutlineInputBorder(), 
             hintText: 'Enter last name',
           ),
           onChanged: (value) {
             setState(() {
               lastname = value;
             });
           },

         ),
          ),
          SizedBox(height: 20,),
           const Text('Enter a password:'),
           
      
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
               TextButton( onPressed: () async {
              bool success = await addUser(useremail, firstname, lastname, pword);
               if (success) {
                 
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const LoginPage();
                }));
            } else {

                final snackBar = SnackBar(
                  content: Text('Email already in use, please try a different one!'),
                  duration: Duration(seconds: 3), // Adjust the duration as needed
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
  
         }, child: Text('Sign-Up'))
         
          ], ),],
      ),),
      );
  }
  


//Might need to change this to return a string so I can specify to user if server is down or if username is taken
 Future<bool> addUser(useremail, fName, lName, password) async {
  Socket socket;
  bool changed = false;
  final completer = Completer<bool>(); // Create a Completer

  try {
    socket = await Socket.connect('127.0.0.1', 12345); // Use the server IP and port
  

    String message = "newUser," + useremail + "," + fName + "," + lName + "," + password;
  
    socket.write(message);

    socket.listen(
      (data) {
        String response = String.fromCharCodes(data).trim();
        
        if (response == "user added") {
          changed = true;
        }
      },
      onError: (error) {
   
        socket.close();
        completer.complete(false); // Set the completer value to false on error
      },
      onDone: () {
      
        socket.close();
        completer.complete(changed); // Set the completer value to verify when done
      },
    );
  } catch (e) {
  
    completer.complete(false); // Set the completer value to false on exception
  }

  return completer.future; // Return the future from the completer
}  }