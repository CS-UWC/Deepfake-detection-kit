from flask import Flask, request, jsonify
import tensorflow as tf
from PIL import Image
import numpy as np
import cv2
from mtcnn import MTCNN


app = Flask(__name__)

# Define the absolute path to your model

# Load your GAN model
model = tf.keras.models.load_model('serverside\deepfake_detector.h5')


@app.route('/detect_deepfake', methods=['POST'])
def detect_deepfake():
    try:
        # Get the uploaded image from the request
        image = request.files['file']
        image = Image.open(image)
        image = np.array(image)  # Convert to NumPy array
        image = preprocess_image(image)  # Preprocess the image (resize, normalize, etc.)

        # Make a prediction using your GAN model
        prediction = model.predict(np.expand_dims(image, axis=0))[0]

        # Depending on your model, you may need to interpret the prediction output
        # and return a result indicating whether it's a deepfake or not.

        return jsonify({'is_deepfake': bool(prediction)})
    except Exception as e:
        return jsonify({'error': str(e)})



def preprocess_image(image_path):
    try:
        # Load the MTCNN model
        detector = MTCNN()

        # Load the image using OpenCV
        image = cv2.imread(image_path)

        # Detect faces in the image
        faces = detector.detect_faces(image)

        if len(faces) == 0:
            raise Exception('No face detected in the image')

        # Get the first detected face coordinates
        x, y, w, h = faces[0]['box']

        # Crop the image around the detected face
        cropped_image = image[y:y+h, x:x+w]

        # Resize the cropped image to 250x250 pixels
        resized_image = cv2.resize(cropped_image, (250, 250))

        return resized_image

    except Exception as e:
        raise e



   

if __name__ == '__main__':
    app.run(debug=True)
