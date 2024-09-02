// Firebase configuration
const firebaseConfig = {
    apiKey: "AIzaSyAJadH1eAj7_XPAXwBv4bSDfUlrePJbxco",
    authDomain: "code-green-92796.firebaseapp.com",
    projectId: "code-green-92796",
    storageBucket: "code-green-92796.appspot.com",
    messagingSenderId: "186043428118",
    appId: "1:186043428118:web:46916cb083df902b1f3437",
    measurementId: "G-4462YKF9R9"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();
const realtimeDb = firebase.database();

// Fetch places from Firestore and populate dropdown
function fetchPlaces() {
    const placeSelect = document.getElementById('place');
    placeSelect.innerHTML = '<option value="">Select or Add a place</option>'; // Reset dropdown

    db.collection('places').get()
        .then((querySnapshot) => {
            querySnapshot.forEach((doc) => {
                placeSelect.innerHTML += `<option value="${doc.id}">${doc.id}</option>`;
            });
        })
        .catch((error) => {
            console.error("Error fetching places: ", error);
        });
}

// Function to add a new place
function addNewPlace() {
    const newPlace = prompt("Enter the new place name:");
    if (newPlace) {
        // Add new place to Firestore
        db.collection('places').doc(newPlace).set({})
            .then(() => {
                console.log(`New place '${newPlace}' added to Firestore.`);
                fetchPlaces(); // Refresh dropdown with updated places
            })
            .catch((error) => {
                console.error("Error adding new place to Firestore: ", error);
            });
    }
}

// Function to create data entry fields based on selected bin count
function createDataEntryFields() {
    const binCount = document.getElementById('binCount').value;
    const container = document.getElementById('dataEntryContainer');
    container.innerHTML = ''; // Clear previous entries

    for (let i = 1; i <= binCount; i++) {
        const binEntryDiv = document.createElement('div');
        binEntryDiv.classList.add('bin-entry');

        const locationLabel = document.createElement('label');
        locationLabel.innerText = `Waste bin ${i} location (e.g., 2,3):`;
        const locationInput = document.createElement('input');
        locationInput.type = 'text';
        locationInput.placeholder = 'x,y';
        locationInput.name = `location${i}`;

        const nearbyPointLabel = document.createElement('label');
        nearbyPointLabel.innerText = `Waste bin ${i} nearby point (e.g., near tree):`;
        const nearbyPointInput = document.createElement('input');
        nearbyPointInput.type = 'text';
        nearbyPointInput.placeholder = 'Nearby point';
        nearbyPointInput.name = `nearbyPoint${i}`;

        const fillLabel = document.createElement('label');
        fillLabel.innerText = `Waste bin ${i} fill status (1 for filled, 0 for not filled):`;
        const fillSelect = document.createElement('select');
        fillSelect.name = `fillStatus${i}`;
        const optionFilled = document.createElement('option');
        optionFilled.value = '1';
        optionFilled.innerText = '1 (Filled)';
        const optionNotFilled = document.createElement('option');
        optionNotFilled.value = '0';
        optionNotFilled.innerText = '0 (Not Filled)';
        fillSelect.appendChild(optionFilled);
        fillSelect.appendChild(optionNotFilled);

        binEntryDiv.appendChild(locationLabel);
        binEntryDiv.appendChild(locationInput);
        binEntryDiv.appendChild(nearbyPointLabel);
        binEntryDiv.appendChild(nearbyPointInput);
        binEntryDiv.appendChild(fillLabel);
        binEntryDiv.appendChild(fillSelect);

        container.appendChild(binEntryDiv);
    }
}

// Handle form submission to add new bins
function handleSubmit(event) {
    event.preventDefault();

    const place = document.getElementById('place').value;
    const binCount = document.getElementById('binCount').value;

    for (let i = 1; i <= binCount; i++) {
        const location = document.querySelector(`input[name='location${i}']`).value;
        const formattedLocation = `(${location})`;
        const nearbyPoint = document.querySelector(`input[name='nearbyPoint${i}']`).value;
        const fillStatus = document.querySelector(`select[name='fillStatus${i}']`).value;

        // Add bin details to Firestore
        db.collection('places').doc(place).collection('bins').doc(`bin${i}`).set({
            location: formattedLocation,
            nearbyPoint: nearbyPoint,
            fillStatus: fillStatus // Include fill status in Firestore
        }).then(() => {
            console.log(`Bin ${i} details added to Firestore.`);
        }).catch((error) => {
            console.error("Error writing document: ", error);
        });

        // Update fill status in Realtime Database
        realtimeDb.ref(`places/${place}/bins/bin${i}/fillStatus`).set(fillStatus)
            .then(() => {
                console.log(`Fill status of bin ${i} updated in Realtime Database.`);
            })
            .catch((error) => {
                console.error("Error writing to Realtime Database: ", error);
            });
    }

    displayResult(place);
}

// Display results after submitting data
function displayResult(place) {
    const resultContainer = document.getElementById('resultContainer');
    resultContainer.innerHTML = '<h2>Submitted Data:</h2>';

    db.collection('places').doc(place).collection('bins').get()
        .then((querySnapshot) => {
            if (!querySnapshot.empty) {
                const placeDiv = document.createElement('div');
                placeDiv.classList.add('place-result');
                placeDiv.innerHTML = `<p><strong>Place:</strong> ${place}</p>`;
                resultContainer.appendChild(placeDiv);

                querySnapshot.forEach((doc) => {
                    const binData = doc.data();
                    const binId = doc.id.split('bin')[1];

                    // Fetch fill status from Realtime Database
                    realtimeDb.ref(`places/${place}/bins/bin${binId}/fillStatus`).once('value', (snapshot) => {
                        const fillStatus = snapshot.val();

                        const resultDiv = document.createElement('div');
                        resultDiv.classList.add('bin-result');
                        resultDiv.innerHTML = `
                            <p><strong>Waste bin ${binId}:</strong></p>
                            <p>Location: ${binData.location}</p>
                            <p>Nearby point: ${binData.nearbyPoint}</p>
                            <p>Fill status: ${fillStatus === '1' ? 'Filled' : 'Not Filled'}</p>
                            <button onclick="editBinFillStatus('${place}', ${binId})">Edit Fill Status</button>
                            <button onclick="deleteBin('${place}', ${binId})">Delete Bin ${binId}</button>
                        `;

                        resultContainer.appendChild(resultDiv);
                    });
                });
            } else {
                resultContainer.innerHTML = `<p>No bins found for place: ${place}</p>`;
            }
        })
        .catch((error) => {
            console.error("Error getting documents: ", error);
        });
}

// Function to edit fill status of a bin
function editBinFillStatus(place, binIndex) {
    const newFillStatus = prompt(`Enter new fill status for bin ${binIndex} (1 for filled, 0 for not filled):`);
    if (newFillStatus !== null) {
        // Update fill status in Firestore
        db.collection('places').doc(place).collection('bins').doc(`bin${binIndex}`).update({
            fillStatus: newFillStatus
        })
        .then(() => {
            console.log(`Fill status of bin ${binIndex} updated in Firestore.`);
            displayResult(place); // Refresh displayed results
        })
        .catch((error) => {
            console.error("Error updating fill status in Firestore: ", error);
        });

        // Update fill status in Realtime Database
        realtimeDb.ref(`places/${place}/bins/bin${binIndex}/fillStatus`).set(newFillStatus)
            .then(() => {
                console.log(`Fill status of bin ${binIndex} updated in Realtime Database.`);
            })
            .catch((error) => {
                console.error("Error updating fill status in Realtime Database: ", error);
            });
    }
}

// Function to delete a bin and manage place deletion if no bins are left
function deleteBin(place, binIndex) {
    // Delete bin from Firestore
    db.collection('places').doc(place).collection('bins').doc(`bin${binIndex}`).delete()
        .then(() => {
            console.log(`Bin ${binIndex} deleted from Firestore.`);

            // Check if there are any bins left for this place
            db.collection('places').doc(place).collection('bins').get()
                .then((querySnapshot) => {
                    if (querySnapshot.empty) {
                        // If no bins are left, delete the place document
                        db.collection('places').doc(place).delete()
                            .then(() => {
                                console.log(`Place ${place} deleted from Firestore as no bins are left.`);
                                document.getElementById('resultContainer').innerHTML = '';
                                fetchPlaces(); // Refresh dropdown with updated places
                            })
                            .catch((error) => {
                                console.error("Error deleting place from Firestore: ", error);
                            });
                    } else {
                        displayResult(place);
                    }
                })
                .catch((error) => {
                    console.error("Error fetching bins: ", error);
                });
        })
        .catch((error) => {
            console.error("Error deleting bin from Firestore: ", error);
        });

    // Delete bin from Realtime Database
    realtimeDb.ref(`places/${place}/bins/bin${binIndex}`).remove()
        .then(() => {
            console.log(`Bin ${binIndex} deleted from Realtime Database.`);

            // Check if there are any bins left for this place
            realtimeDb.ref(`places/${place}/bins`).once('value', (snapshot) => {
                if (!snapshot.exists()) {
                    // If no bins are left, delete the place node
                    realtimeDb.ref(`places/${place}`).remove()
                        .then(() => {
                            console.log(`Place ${place} deleted from Realtime Database as no bins are left.`);
                        });
                }
            });
        })
        .catch((error) => {
            console.error("Error deleting bin from Realtime Database: ", error);
        });
}

// Fetch and display place data on dropdown change
function fetchPlaceData() {
    const place = document.getElementById('place').value;
    if (place) {
        displayResult(place);
    }
}

// Initialize page
fetchPlaces();

// Listen for changes in Realtime Database and update Firestore accordingly
realtimeDb.ref('places').on('child_changed', (snapshot) => {
    const place = snapshot.key;
    snapshot.child('bins').forEach((binSnapshot) => {
        const binId = binSnapshot.key;
        const fillStatus = binSnapshot.child('fillStatus').val();

        // Update Firestore
        db.collection('places').doc(place).collection('bins').doc(binId).update({
            fillStatus: fillStatus
        })
        .then(() => {
            console.log(`Fill status of ${binId} updated in Firestore for place ${place}.`);
        })
        .catch((error) => {
            console.error("Error updating fill status in Firestore: ", error);
        });
    });
});
