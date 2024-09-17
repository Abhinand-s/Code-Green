from tensorflow.keras.applications.mobilenet_v2 import MobileNetV2, preprocess_input, decode_predictions
from tensorflow.keras.preprocessing import image
import numpy as np
import pandas as pd

# Load the pre-trained model
model = MobileNetV2(weights='imagenet')

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

# Example usage
new_image_path = 'image2.png'
extract_data_from_image(new_image_path)
