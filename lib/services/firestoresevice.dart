import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sosapp/models/Kullanici.dart';
import 'package:sosapp/models/notificationn.dart';
import 'package:sosapp/models/post.dart';
import 'package:sosapp/pages/search.dart';
import 'package:sosapp/services/storageservice.dart';

class FireStoreService {
  final Firestore _firestore = Firestore.instance;
  final DateTime time = DateTime.now();

  Future<void> createUser({id, email, username, fotoUrl = ""}) async {
    await _firestore.collection("users").document(id).setData({
      "username": username,
      "email": email,
      "fotoUrl": fotoUrl,
      "about": "",
      "creationTime": time,
    });
  }

  Future<Kullanici> getUser(id) async {
    DocumentSnapshot doc = await _firestore
        .collection("users")
        .document(id.toString().trim())
        .get();
    if (doc.exists) {
      print("deneme");
      Kullanici user = Kullanici.dokumandanUret(doc);
      return user;
    }
    return null;
  }

  void updateUser(
      {String userId, String username, String photoUrl = "", String about}) {
    _firestore
        .collection("users")
        .document(userId.toString().trim())
        .updateData({
      "username": username,
      "about": about,
      "fotoUrl": photoUrl,
    });
  }

  Future<List<Kullanici>> searchUser(String word) async {
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .where("username", isGreaterThanOrEqualTo: word) //tekrar bak!
        .getDocuments();
    List<Kullanici> users =
        snapshot.documents.map((doc) => Kullanici.dokumandanUret(doc)).toList();
    return users;
  }

  void follow({String activeUserId, String profileOwnerId}) {
    _firestore
        .collection("followers")
        .document(profileOwnerId)
        .collection("usersFollowers")
        .document(activeUserId)
        .setData({});
    _firestore
        .collection("followed")
        .document(activeUserId)
        .collection("usersFollowed")
        .document(profileOwnerId)
        .setData({});

    //takip edilen kullanıcıya duyuru göster
    addNotification(
        activateType: "follow",
        activatorId: activeUserId,
        profileOwnerId: profileOwnerId);
  }

  void unfollow({String activeUserId, String profileOwnerId}) {
    _firestore
        .collection("followers")
        .document(profileOwnerId)
        .collection("usersFollowers")
        .document(activeUserId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    _firestore
        .collection("followed")
        .document(activeUserId)
        .collection("usersFollowed")
        .document(profileOwnerId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> followCheck({String activeUserId, String profileOwnerId}) async {
    DocumentSnapshot doc = await _firestore
        .collection("followed")
        .document(activeUserId)
        .collection("usersFollowed")
        .document(profileOwnerId)
        .get();
    if (doc.exists) {
      return true;
    }
    return false;
  }

  Future<int> followerNumber(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("followers")
        .document(userId)
        .collection("usersFollowers")
        .getDocuments();
    return snapshot.documents.length; // kullanıcının takipçi sayısını döndürür
  }

  Future<int> followedNumber(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("followed")
        .document(userId)
        .collection("usersFollowed")
        .getDocuments();
    return snapshot
        .documents.length; // kullanıcının takip ettiklerinin sayısını döndürür
  }

  void addNotification(
      {String activatorId,
      String profileOwnerId,
      String activateType,
      String comment,
      Post post}) {
    if (activatorId == profileOwnerId) {
      return;
    }
    _firestore
        .collection("notification")
        .document(profileOwnerId)
        .collection("usersNotification")
        .add({
      "activatorId": activatorId,
      "activateType": activateType,
      "postId": post?.id, // "?" check if null or not
      "postPic": post?.postPicUrl, // "?" check if null or not
      "comment": comment,
      "creationTime": time
    });
  }

  Future<List<Notificationn>> getNotification({String profileUserId}) async {
    QuerySnapshot snapshot = await _firestore
        .collection("notification")
        .document(profileUserId)
        .collection("usersNotification")
        .orderBy("creationTime", descending: true)
        .limit(20)
        .getDocuments();
    List<Notificationn> notifications = [];
    snapshot.documents.forEach((DocumentSnapshot doc) {
      Notificationn notification = Notificationn.dokumandanUret(doc);
      notifications.add(notification);
    });
    return notifications;
  }

  Future<void> createPost({picUrl, description, publisherId, location}) async {
    await _firestore
        .collection("posts")
        .document(publisherId)
        .collection("usersPosts")
        .add({
      "postPicUrl": picUrl,
      "description": description,
      "publisherId": publisherId,
      "likeNumber": 0,
      "location": location,
      "creationTime": time
    });
  }

  Future<List<Post>> getPosts(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("posts")
        .document(userId)
        .collection("usersPosts")
        .orderBy("creationTime",
            descending: true) // En yeni gönderi en başta gösterilir
        .getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.dokumandanUret(doc)).toList();
    return posts;
  }

  Future<List<Post>> getFlowPosts(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("flows")
        .document(userId)
        .collection("userFlowPosts")
        .orderBy("creationTime",
            descending: true) // En yeni gönderi en başta gösterilir
        .getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.dokumandanUret(doc)).toList();

    return posts;
  }

  Future<void> deletePost({String activeUserId, Post post}) async {
    _firestore
        .collection("posts")
        .document(activeUserId)
        .collection("usersPosts")
        .document(post.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //delete comments of deleted post
    QuerySnapshot commentSnapshot = await _firestore
        .collection("comments")
        .document(post.id)
        .collection("postComments")
        .getDocuments();
    commentSnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //delete notifications
    QuerySnapshot notificationSnapshot = await _firestore
        .collection("notification")
        .document(post.publisherId)
        .collection("usersNotification")
        .where("postId", isEqualTo: post.id)
        .getDocuments();
    notificationSnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //delete from storage
    StorageService().deletePostPic(post.postPicUrl);
  }

  Future<Post> getSinglePost(String postId, String postOwnerId) async {
    DocumentSnapshot doc = await _firestore
        .collection("posts")
        .document(postOwnerId)
        .collection("usersPosts")
        .document(postId)
        .get();
    Post post = Post.dokumandanUret(doc);
    return post;
  }

  Future<void> likePost(Post post, String activeUserId) async {
    DocumentReference docRef = _firestore
        .collection("posts")
        .document(post.publisherId)
        .collection("usersPosts")
        .document(post.id);
    DocumentSnapshot doc = await docRef.get();
    if (doc.exists) {
      Post post = Post.dokumandanUret(doc);
      int newLikeNumber = post.likeNumber + 1;
      docRef.updateData({"likeNumber": newLikeNumber});
      _firestore
          .collection("likes")
          .document(post.id)
          .collection("postLikes")
          .document(activeUserId)
          .setData({});
      addNotification(
          activateType: "like",
          activatorId: activeUserId,
          post: post,
          profileOwnerId: post.publisherId);
    }
  }

  Future<void> unlikePost(Post post, String activeUserId) async {
    DocumentReference docRef = _firestore
        .collection("posts")
        .document(post.publisherId)
        .collection("usersPosts")
        .document(post.id);
    DocumentSnapshot doc = await docRef.get();
    if (doc.exists) {
      Post post = Post.dokumandanUret(doc);
      int newLikeNumber = post.likeNumber - 1;
      docRef.updateData({"likeNumber": newLikeNumber});
      DocumentSnapshot docLike = await _firestore
          .collection("likes")
          .document(post.id)
          .collection("postLikes")
          .document(activeUserId)
          .get();
      if (docLike.exists) {
        docLike.reference.delete();
      }
    }
  }

  Future<bool> isLikeExists(Post post, String activeUserId) async {
    DocumentSnapshot docLike = await _firestore
        .collection("likes")
        .document(post.id)
        .collection("postLikes")
        .document(activeUserId)
        .get();
    if (docLike.exists) {
      return true;
    } else {
      return false;
    }
  }

  Stream<QuerySnapshot> getComments(String postId) {
    return _firestore
        .collection("comments")
        .document(postId)
        .collection("postComments")
        .orderBy("creationTime", descending: false)
        .snapshots();
  }

  void addComment({String activeUserId, Post post, String content}) {
    _firestore
        .collection("comments")
        .document(post.id)
        .collection("postComments")
        .add({
      "content": content,
      "publisherId": activeUserId,
      "creationTime": time,
    });
    addNotification(
        activateType: "comment",
        activatorId: activeUserId,
        post: post,
        profileOwnerId: post.publisherId,
        comment: content);
  }

  Stream<QuerySnapshot> getMessages(
    String activeUserId,
    String profileOwnerId,
  ) {
    return _firestore
        .collection("chat")
        .document(activeUserId)
        .collection("chatWith")
        .document(profileOwnerId)
        .collection("message")
        //.orderBy("creationTime", descending: false)
        .snapshots();
  }

  void sendMessage(
      {String activeUserId, String profileOwnerId, String content}) {
    _firestore
        .collection("chat")
        .document(activeUserId)
        .collection("chatWith")
        .document(profileOwnerId)
        .collection("message")
        .add({
      "content": content,
      "creationTime": time,
    });

    _firestore
        .collection("chat")
        .document(profileOwnerId)
        .collection("chatWith")
        .document(activeUserId)
        .collection("message")
        .add({
      "content": content,
      "creationTime": time,
    });
  }
}
