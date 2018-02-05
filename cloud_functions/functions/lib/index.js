"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);
// Start writing Firebase Functions
// https://firebase.google.com/functions/write-firebase-functions
exports.helloWorld = functions.https.onRequest((request, response) => {
    response.send("Hello from Firebase!");
});
exports.applyCode = functions.database.ref("applied_codes/{code}").onCreate(event => {
    console.log("Applying a code");
    const codeData = event.data.val();
    const creatorUid = codeData['creatorUid'];
    const acceptorUid = codeData['acceptorUid'];
    return admin.database().ref(`applied_codes/${event.params['code']}`).remove().then((_) => {
        return Promise.all([admin.database().ref(`users/${acceptorUid}/info`).once('value'),
            admin.database().ref(`users/${creatorUid}/info`).once('value')]);
    }).then(result => {
        let [acceptor, creator] = result;
        acceptor = acceptor.val();
        creator = creator.val();
        const now = Date.now();
        const acceptorDescriptor = {
            'uid': acceptorUid,
            'displayName': acceptor['displayName'],
            'photoUrl': acceptor['photoUrl'],
        };
        const creatorDescriptor = {
            'uid': creatorUid,
            'displayName': creator['displayName'],
            'photoUrl': creator['photoUrl'],
        };
        return Promise.all([setUpChat(creatorUid, acceptorDescriptor, now), setUpChat(acceptorUid, creatorDescriptor, now)]);
    }).then(_ => {
        return setUpChatContent(creatorUid, acceptorUid);
    });
});
function setUpChat(userUid, participant, now) {
    // TODO: check if such chat already exists
    // TODO: check if userUid != participantUid
    return admin.database().ref(`users/${userUid}/chats`).push().set({
        'participantUid': participant['uid'],
        'participantName': participant['displayName'],
        'participantPhotoUrl': participant['photoUrl'] ? participant['photoUrl'] : null,
        'lastInteraction': now
    });
}
function setUpChatContent(firstUid, secondUid) {
    const chatName = firstUid > secondUid ? firstUid + secondUid : secondUid + firstUid;
    const chatRef = admin.database().ref(`chats/${chatName}`);
    return Promise.all([chatRef.child(firstUid).set(false), chatRef.child(secondUid).set(false)]);
}
//# sourceMappingURL=index.js.map