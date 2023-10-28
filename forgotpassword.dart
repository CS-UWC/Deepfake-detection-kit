import 'dart:async';
import 'dart:io';
import 'package:deepfake_detection_kit/presentation/screens/loginpage.dart';
import 'package:flutter/material.dart';



class ForgotPasswordPage extends StatefulWidget{
  const ForgotPasswordPage({super.key});
 
  
  @override
  State<StatefulWidget> createState() => _ForgotPasswordPageState();


}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String useremail = '';
  String pword = '';
  String new_pword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Change Password:'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter new details:',
            ),
            const SizedBox(height: 20),
            const Text('Enter your username:'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
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
            const SizedBox(height: 20),
            const Text('Enter your old password:'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
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
            const SizedBox(height: 20),
            const Text('Enter your new password:'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter password',
                ),
                onChanged: (value) {
                  setState(() {
                    new_pword = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () async {
                    bool success = await changePassword(useremail, pword, new_pword);
                    if (success) {
                    
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const LoginPage();
                      }));
                    } else {
                      print('User details incorrect');
                      final snackBar = SnackBar(
                        content: Text('Details are incorrect.'),
                        duration: Duration(seconds: 3),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: Text('Change Password'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



Future<bool> changePassword(useremail, password, new_password) async {
  Socket socket;
  bool changed = false;
  final completer = Completer<bool>(); // Create a Completer

  try {
    socket = await Socket.connect('127.0.0.1', 12345); // Use the server IP and port
  

    String message = "passwordChange," + useremail + "," + password + "," + new_password;
    socket.write(message);

    socket.listen(
      (data) {
        String response = String.fromCharCodes(data).trim();
        print('Received: $response');
        if (response == "password changed") {
          changed = true;
        }
      },
      onError: (error) {
        print('Error: $error');
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
}  