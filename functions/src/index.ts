import * as functions from "firebase-functions";
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

export const applyPromoCode = functions.https.onCall(async (data, context) => {
  try {
    const uid = data.uid;
    const promo_code = data.promo_code;
    // Get promo's data from firebase
    var promoRef = await admin
      .firestore().collection("promos").doc(promo_code).get();
    if (promoRef.exists) {
      // Check if reference exists in firebase
      var promo = promoRef.data(); // Get the Object
      // Get user's data and update credits with
      var userRef = await admin.firestore().collection("users").doc(uid).get();
      var user = userRef.data();
      console.log(promo.credits);
      console.log(promo.message);
      if (promo.expiration.toDate() > new Date()) {
        // Compare expiration date
        if (!promo.redeemed_users.includes(uid)) {
          admin
            .firestore().collection("users").doc(uid)
            .update({
              credits: user.credits + promo.credits
            });
          // Update Promo's object with the user's id
          await admin
            .firestore().collection("promos").doc(promo_code)
            .update({
              redeemed_users: admin.firestore.FieldValue.arrayUnion(uid)
            });
          return {
            result: true,
            message: promo.message
          };
        } else {
          return {
            result: false,
            message: "You have already redeemed this code"
          };
        }
      } else {
        return {
          result: false,
          message: "Promo Code has expired"
        };
      }
    } else {
      return {
        result: false,
        message: "Invalid Promo Code"
      };
    }
  } catch (error) {
    console.log(error);
    return {
      result: false,
      message: "Server Error: Please try again later."
    };
  }
});
