document.addEventListener('DOMContentLoaded', function() {
  getCurrentLocation();

  setTimeout(function() {
    var errorAlert = document.querySelector('#error-alert');
    if (errorAlert) {
      errorAlert.remove();
    }
  }, 5000);
});

function getCurrentLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(showPosition, showError);
  } else {
    alert("Geolocation is not supported by this browser.");
  }
}

function showPosition(position) {
  var latitude = position.coords.latitude;
  var longitude = position.coords.longitude;

  // Set the values of the hidden fields
  document.getElementById("latitude").value = latitude;
  document.getElementById("longitude").value = longitude;

  const form = document.getElementById("weather-form");
  if (form) {
    form.submit();
  }
  console.log("Latitude: " + latitude);
  console.log("Longitude: " + longitude);
}

function showError(error) {
  switch (error.code) {
    case error.PERMISSION_DENIED:
      alert("User denied the request for Geolocation.");
      break;
    case error.POSITION_UNAVAILABLE:
      alert("Location information is unavailable.");
      break;
    case error.TIMEOUT:
      alert("The request to get user location timed out.");
      break;
    case error.UNKNOWN_ERROR:
      alert("An unknown error occurred.");
      break;
  }
}
