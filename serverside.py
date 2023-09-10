import socket
import mysql.connector



useremail = ['']

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
            print(result)
            if result:
                return result[3]==password
        except mysql.connector.Error as err:
            print(f"Error: {err}")
        finally:
            cursor.close()
            db_connection.close()
    return False

def add_user(username, f_name, l_name, password):
    
    db_connection, cursor = connect_to_database()
    if db_connection and cursor:
        try:
            query = "INSERT INTO users (email, first_name, last_name, passwd) VALUES (%s, %s, %s, %s);"
            cursor.execute(query, (username, f_name, l_name, password))
            result = cursor.fetchone()
            print(result)
        except mysql.connector.Error as err:
            print(f"Error: {err}")
        finally:
            cursor.close()
            db_connection.close()
    return False

def change_pwd(username, old_password, new_password):
    
    db_connection, cursor = connect_to_database()
    if db_connection and cursor:
        try:
            query = "SELECT * FROM users WHERE email = %s"
            cursor.execute(query, (username))
            result = cursor.fetchone()
            if (result[3] == old_password):
                query = "UPDATE users SET passwd = %s WHERE email=username;"
                cursor.execute(query, (new_password))
                result = cursor.fetchone()
                print(result)

            else:
                return False
        except mysql.connector.Error as err:
            print(f"Error: {err}")
        finally:
            cursor.close()
            db_connection.close()
    return False

   
def upload(image): #might have to have user data here also
    db_connection, cursor = connect_to_database()
    if db_connection and cursor:
        try:
            query = "INSERT INTO media (media_data, email) VALUES (%s,%s)"
            cursor.execute(query, (image, useremail[0]))
        except mysql.connector.Error as err:
            print(f"Error: {err}")
        finally:
            cursor.close()
            db_connection.close()
    

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
            delimiter = " "
            result_list = message.split(delimiter)
        
            print("Received:", result_list[0] + " " +  result_list[1]) 
        
            # Check if the data is in the database
            if len(result_list) == 5:
                add_user(result_list[1], result_list[2], result_list[3], result_list[4])
                response = "user added"
            else:
                response = "failed to add user"

        elif(data.decode("utf-8")[0]=="p"):
            message = data.decode("utf-8")
            delimiter = " "
            result_list = message.split(delimiter)
        
            print("Received change password request") 
        
            # Check if the data is in the database
            if len(result_list) == 4:
                change_pwd(result_list[1], result_list[2], result_list[3])
                response = "password changed"
            else:
                response = "failed to change password"
        else:
            print("Image received")
            print(useremail[0])
            upload(data)
            print("Uploaded")
            response = "Image uploaded"
        
        
        
        client_socket.sendall(response.encode('utf-8'))

    client_socket.close()
