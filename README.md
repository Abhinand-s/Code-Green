# 🌿 **Code-Green**

## 🚮 **Problem:**
Excessive waste overflow leads to environmental hazards, public health concerns, and an increase in stray animal activity.

## 🌍 **Solution:**
A smart waste management system that:
1. **Notifies** when a bin exceeds its capacity.
2. **Guides** waste collectors through the most efficient route to these bins using real-time data.

## 💡 **Innovation:**
Our solution uniquely integrates **real-time bin threshold sensors** with an **intelligent route optimization app**, ensuring:
- Efficient waste collection.
- Prevention of overflow.
- Reduction of operational costs.

## 🛠️ **Components Used - Hardware:**

### 1. Ai Thinker ESP32 CAM Development Board:
- **Integration:** Combines a powerful ESP32 microcontroller with WiFi/Bluetooth and a camera.
- **Effectiveness:** Simplifies motion detection, image capture, and wireless communication in one compact, cost-effective board, reducing system complexity and size.

### 2. Portable 6V 2W Solar Panel:
- **Power Output:** Delivers sufficient power for the CN3065 battery charger.
- **Effectiveness:** Ensures reliable battery recharging, maintaining continuous operation even in varying sunlight conditions.

### 3. CN3065 Mini Solar LiPo Battery Charger Module:
- **Efficiency:** Efficiently charges 3.7V LiPo batteries from a 6V solar panel.
- **Effectiveness:** Provides safe and reliable charging with built-in protection, ideal for maintaining power in the waste bin system.

### 4. LM2596 3A Buck Converter Power Supply Module:
- **Voltage Regulation:** Steps down battery voltage to 3.3V for the ESP32 and sensors.
- **Effectiveness:** Ensures stable power delivery, meeting the current needs of all components.

### 5. HC-SR501 PIR Motion Detection Sensor:
- **Features:** Consumes minimal power with an adjustable detection range.
- **Functionality:** Efficiently monitors motion and activates other components only when needed, enhancing energy efficiency.

### 6. HC-SR04 Ultrasonic Sensor:
- **Range:** Offers a measurement range of 2 cm to 4 meters at low cost.
- **Accuracy:** Works with the PIR sensor to provide accurate distance measurements for waste detection, boosting system accuracy and efficiency.

### 7. Semtech SX1276 LoRa Module:
- **Communication:** Offers long-range communication with low power consumption.
- **Connectivity:** Enables efficient and reliable data transmission over long distances, enhancing the connectivity of the waste bin system.

## 💻 **Software Used:**

- **Backend and Authentication:** Firebase
- **App Development:** Flutter (Dart)
- **Model Training:** TensorFlow

## 🧮 **Algorithm Used:**
- **Traveling Salesman Problem (TSP):** Optimizes the shortest path for waste collectors between filled bins.

---

