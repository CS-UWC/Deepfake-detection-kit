import socket
import mysql.connector
import tensorflow as tf
# from PIL import Image
import numpy as np
import cv2
from mtcnn import MTCNN



useremail = ['']
model = tf.keras.models.load_model("serverside\deepfake_detector.h5")

# Function to establish a database connection
def connect_to_database():
    try:
        db_connection = mysql.connector.connect(
            host="localhost",
            user="root",
            password="tolladatabase",
            database="userdata"
        )
        cursor = db_connection.cursor()
        return db_connection, cursor
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return None, None



# Function to check if data is in the database
def check_user_in_database(username, password):
    
    db_connection, cursor = connect_to_database()
    if db_connection and cursor:
        try:
            query = "SELECT * FROM users WHERE email = %s"
            cursor.execute(query, (username,))
            result = cursor.fetchone()
           
            if result:
                return result[3]==password
        except mysql.connector.Error as err:
            print(f"Error: {err}")
        finally:
            cursor.close()
            db_connection.close()
    return False



#function to add new user
def add_user(username, f_name, l_name, password):
    
    db_connection, cursor = connect_to_database()
    if db_connection and cursor:
        try:
            query = "INSERT INTO users (email, first_name, last_name, passwd) VALUES (%s, %s, %s, %s);"
            cursor.execute(query, (username, f_name, l_name, password))
            db_connection.commit()
    
        except mysql.connector.Error as err:
            if err.errno == 1602:
                print("Error: Duplicate entry. This record already exists.")
            else:
                print(f"Error: {err}")
        finally:
            cursor.close()
            db_connection.close()
    return False


#function to change existing users password
def change_pwd(username , new_password):
    
    db_connection, cursor = connect_to_database()
    if db_connection and cursor:
        try:
        
            query = "UPDATE users SET passwd = %s WHERE email=%s"
            cursor.execute(query, (new_password, username))
            db_connection.commit()
            return True

           
        except mysql.connector.Error as err:
            print(f"Error: {err}")
        finally:
            cursor.close()
            db_connection.close()
    return False



#function to upload image to database   
def upload(image): #might have to have user data here also
    db_connection, cursor = connect_to_database()
    if db_connection and cursor:
        try:
            query = "INSERT INTO media (media_data, email) VALUES (%s, %s)"
            cursor.execute(query, (str(image), useremail[0]))
            db_connection.commit()
          
            if cursor.rowcount == 1:
             last_inserted_id = cursor.lastrowid
             print(f"Inserted successfully with media_id: {last_inserted_id}")
            else:
             print("Insert failed")
        except mysql.connector.Error as err:
            print(f"Error: {err}")
        finally:
            cursor.close()
            db_connection.close()
    






#process image for gan
def preprocess_image(image_path):
    try:
        # Load the MTCNN model
        detector = MTCNN()

        # Load the image using OpenCV
        image = cv2.imread(image_path)

        # Detect faces in the image
        faces = detector.detect_faces(image)

        if len(faces) == 0:
            return False

        # Get the first detected face coordinates
        x, y, w, h = faces[0]['box']

        # Crop the image around the detected face
        cropped_image = image[y:y+h, x:x+w]

        # Resize the cropped image to 250x250 pixels
        resized_image = cv2.resize(cropped_image, (250, 250))

        return resized_image

    except Exception as e:
        raise e


#function to detect deepfake using model
def detect_deepfake(resized_image):
    try:
     
        image = np.array(resized_image)  # Convert to NumPy array
        
        # Make a prediction using your GAN model
        prediction = model.predict(np.expand_dims(image, axis=0))[0][0]


        return prediction
    except Exception as e:
        return e




#socket setup
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_address = ('127.0.0.1', 12345)
server_socket.bind(server_address)

server_socket.listen(1)
print("Server is listening...")

while True:
    client_socket, client_address = server_socket.accept()
    print("Connected by:", client_address)

    data = client_socket.recv(1024)
    if data:
        

        if(data.decode("utf-8")[0]=="v"):
            message = data.decode("utf-8")
            delimiter = " "
            result_list = message.split(delimiter)
        
            print("Received:", result_list[0] + " " +  result_list[1]) 
        
            # Check if the data is in the database
            if len(result_list) == 3 and check_user_in_database(result_list[1], result_list[2]):
                useremail[0] = result_list[1]
                response = "t"
            else:
                response = "f"
        



        elif(data.decode("utf-8")[0]=="n"):
            message = data.decode("utf-8")
            delimiter = ","
            result_list = message.split(delimiter)
            print(message)
            print("Received:", result_list[0] + " " +  result_list[1])
        
            # Check if the data is in the database
            if (len(result_list) == 5 and check_user_in_database(result_list[1], result_list[4])!=True):
                add_user(result_list[1], result_list[2], result_list[3], result_list[4])
                response = "user added"
            else:
                response = "failed to add user"




        elif(data.decode("utf-8")[0]=="p"):
            message = data.decode("utf-8")
            delimiter = ","
            result_list = message.split(delimiter)

            print(message)
            print("Received change password request") 
           
        
            # Check if the data is in the database
            if (len(result_list) == 4 and check_user_in_database(result_list[1], result_list[2]) and change_pwd(result_list[1], result_list[3])):
                response = "password changed"
            else:
                response = "failed to change password"
       
       
       
       
        else:
            print("Image received")
            print(useremail[0])
            message = data.decode("utf-8")
            print(message)
            print(type(message))
            processed_image = preprocess_image(message)
            if (type(processed_image)!=bool):
                result = detect_deepfake(processed_image)            
                if(result==1):
                    upload(message)
                    response = "1Image uploaded " + "This image is a deepfake"
                    
                elif(result==0):
                    upload(message)
                    response = "0Image uploaded " + "This image is not a deepfake"
            else:
                response = "No face detected"
            print(response)



        
        client_socket.sendall(response.encode('utf-8'))

    client_socket.close()
