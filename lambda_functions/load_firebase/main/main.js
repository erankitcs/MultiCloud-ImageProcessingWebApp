'use strict';

const admin = require('firebase-admin');
const serviceAccount = require('serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

exports.handler = function(event, context, callback) {
        console.log(event)
        var message = event.Records[0].Sns.Message;
        console.log('Message received from SNS:', message);
        var message_json = JSON.parse(message);
        const data = {
                dominantColorForeground: message_json['color']['dominantColorForeground'],
                dominantColorBackground: message_json['color']['dominantColorBackground'],
                categories: message_json['categories'],
                tags: message_json['description']['tags'],
                captions: message_json['description']['captions'],
                brands: message_json['brands'],
                url: message_json['imageUrl']
              };
        const doc_id = message_json['imageId']
        const docRef = db.collection('image_lense').doc(doc_id);
        const res = docRef.set(data);
        callback(null, "Success");
    };