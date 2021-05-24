const functions = require("firebase-functions");

const admin = require('firebase-admin');
admin.initializeApp();

exports.followedUp = functions.firestore.document('followers/{followedId}/usersFollowers/{followingUserId}').onCreate(async (snapshot, context) => {
    const followedId = context.params.followedId;
    const followingId = context.params.followingUserId;
    const postsSnapshot = await admin.firestore().collection("posts").doc(followedId).collection("usersPosts").get();
    postsSnapshot.forEach((doc) => {
        if (doc.exists) {
            const postId = doc.id;
            const postData = doc.data();

            admin.firestore().collection("flows").doc(followingId).collection("userFlowPosts").doc(postId).set(postData);
        }
    });
});

exports.unfollowedUp = functions.firestore.document('followers/{followedId}/usersFollowers/{followingUserId}').onDelete(async (snapshot, context) => {
    const followedId = context.params.followedId;
    const followingId = context.params.followingUserId;
    const postsSnapshot = await admin.firestore().collection("flows").doc(followingId).collection("userFlowPosts").where("publisherId", "==", followedId).get();
    postsSnapshot.forEach((doc) => {
        if (doc.exists) {
            doc.ref.delete();
        }
    });
});

exports.newPostAdded = functions.firestore.document('posts/{followingUserId}/usersPosts/{postId}').onCreate(async (snapshot, context) => {
    const followingId = context.params.followingUserId;
    const postId = context.params.postId;
    const newPostData = snapshot.data();

    const followersSnapshot = await admin.firestore().collection("followers").doc(followingId).collection("usersFollowers").get();
    followersSnapshot.forEach(doc => {
        const followerId = doc.id;
        admin.firestore().collection("flows").doc(followerId).collection("userFlowPosts").doc(postId).set(newPostData);
    });
});
exports.postUpdated = functions.firestore.document('posts/{followingUserId}/usersPosts/{postId}').onUpdate(async (snapshot, context) => {
    const followingId = context.params.followingUserId;
    const postId = context.params.postId;
    const updatedPostData = snapshot.after.data();

    const followersSnapshot = await admin.firestore().collection("followers").doc(followingId).collection("usersFollowers").get();
    followersSnapshot.forEach(doc => {
        const followerId = doc.id;
        admin.firestore().collection("flows").doc(followerId).collection("userFlowPosts").doc(postId).update(updatedPostData);
    });
});

exports.postDeleted = functions.firestore.document('posts/{followingUserId}/usersPosts/{postId}').onDelete(async (snapshot, context) => {
    const followingId = context.params.followingUserId;
    const postId = context.params.postId;

    const followersSnapshot = await admin.firestore().collection("followers").doc(followingId).collection("usersFollowers").get();
    followersSnapshot.forEach(doc => {
        const followerId = doc.id;
        admin.firestore().collection("flows").doc(followerId).collection("userFlowPosts").doc(postId).delete();
    });
});



/*
exports.recordDeleted = functions.firestore.document('deneme/{docId}').onDelete((snapshot, context) => {
    admin.firestore().collection("diary").add({
        "açıklama": "deneme koleksiyonundan kayıt silindi."
    });
});

exports.recordUpdated = functions.firestore.document('deneme/{docId}').onUpdate((change, context) => {
    admin.firestore().collection("diary").add({
        "açıklama": "deneme koleksiyonunda kayıt güncellendi."
    });
});

exports.writeDone = functions.firestore.document('deneme/{docId}').onWrite((change, context) => {
    admin.firestore().collection("diary").add({
        "açıklama": "deneme koleksiyonunda veri ekleme silme güncelleme işlemlerinden biri gerçekleşti."
    });
});

*/