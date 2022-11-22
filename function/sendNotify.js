var admin = require("firebase-admin");

var serviceAccount = require("./serviceAccountKey.json");



admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});




var regToken = "eggcm9gYS--lsG1YvghDDK:APA91bF0kpH_q6iqdp8CRtLI2aKPWk0N2IAMs8NNWWWB3xXWsJfD2CI_kCQA5Eyhc_HHJrifvMEpWndxZnGvGe5pXV_hYn4weGwg7HjzQiptaOCncEOZRzAyRgVqi29MAA8ThniL9g5c";


var message = {
    data: {
        title: "8.50",
        body: "2:45"
    },
    // token: regToken
    
};

admin.messaging().sendToTopic("Nokia",message).then((response) => {
    console.log("successfully sent message", response);
}).catch((error) => {
    console.log("Error Sending Message", error);
});