import cv2
import numpy as np
import imagehash
from PIL import Image
from tensorflow.keras.applications.mobilenet_v2 import MobileNetV2, preprocess_input, decode_predictions
from tensorflow.keras.preprocessing import image
import pandas as pd

# Load the pre-trained model for extraction
model = MobileNetV2(weights='imagenet')

# Function to calculate hash of an image
def calculate_hash(image_path):
    image = Image.open(image_path)
    return imagehash.phash(image)

# Check for duplicates
def is_duplicate(new_image_hash, existing_images_hashes):
    for img_hash in existing_images_hashes:
        if new_image_hash == img_hash:
            return True
    return False

# Function to run extraction on an image
def extract_data_from_image(image_path):
    img = image.load_img(image_path, target_size=(224, 224))
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array = preprocess_input(img_array)

    # Predict the content of the image
    predictions = model.predict(img_array)
    results = decode_predictions(predictions, top=10)[0]  # Get top 10 predictions
    
    # Prepare data for table, assuming each is a distinct item with a count of 1
    data = []
    for i, (imagenet_id, label, score) in enumerate(results):
        data.append([label, 1])  # Since MobileNetV2 can't count, assume count as 1 for each prediction
    
    # Group by label and count occurrences (count will always be 1 for this example)
    df = pd.DataFrame(data, columns=['Item', 'Count'])
    df_grouped = df.groupby('Item').sum().reset_index()

    print(df_grouped)

# Real-time capture and processing
def capture_and_process():
    # Initialize webcam
    cap = cv2.VideoCapture(0)
    existing_hashes = []

    while True:
        # Capture frame-by-frame
        ret, frame = cap.read()
        
        # Display the frame to the user
        cv2.imshow('Press Space to Capture Image', frame)

        # Wait for the user to press space to capture the image
        key = cv2.waitKey(1)
        if key == 32:  # ASCII for space bar
            # Save the captured image
            image_path = 'captured_image.png'
            cv2.imwrite(image_path, frame)

            # Calculate hash of the captured image
            new_image_hash = calculate_hash(image_path)

            # Check if the captured image is a duplicate
            if is_duplicate(new_image_hash, existing_hashes):
                print("Duplicate image detected.")
            else:
                print("New image detected.")
                existing_hashes.append(new_image_hash)

                # Run extraction on the new image
                extract_data_from_image(image_path)

        # Press 'q' to quit the loop
        if key == ord('q'):
            break

    # When everything done, release the capture
    cap.release()
    cv2.destroyAllWindows()

# Start the real-time capture and processing
capture_and_process()
