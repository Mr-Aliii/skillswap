"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onMessageSent = exports.onNotificationCreated = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
/**
 * Send FCM push notification when an in-app notification is created.
 */
exports.onNotificationCreated = functions.firestore
    .document('notifications/{notificationId}')
    .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data)
        return;
    const userId = data.userId;
    if (!userId)
        return;
    const title = data.title;
    const body = data.body;
    const type = data.type || 'general';
    const notificationData = data.data;
    const token = await getFcmToken(userId);
    if (!token)
        return;
    const message = {
        token,
        notification: { title, body },
        data: {
            type,
            ...(notificationData || {}),
            notificationId: context.params.notificationId,
        },
        android: { priority: 'high' },
        apns: { payload: { aps: { sound: 'default' } } },
    };
    try {
        await admin.messaging().send(message);
        functions.logger.info(`FCM sent to ${userId}: ${title}`);
    }
    catch (err) {
        functions.logger.warn(`FCM failed for ${userId}:`, err);
    }
});
/**
 * Send FCM push notification when a new chat message is sent.
 */
exports.onMessageSent = functions.firestore
    .document('chats/{chatId}/messages/{messageId}')
    .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data)
        return;
    const senderId = data.senderId;
    const text = data.text;
    const chatId = context.params.chatId;
    if (!senderId || !text || !chatId)
        return;
    // Get chat doc to find the other participant
    const chatSnap = await db.collection('chats').doc(chatId).get();
    if (!chatSnap.exists)
        return;
    const chatData = chatSnap.data();
    const participantIds = chatData.participantIds;
    const names = chatData.names || {};
    const senderName = names[senderId] || 'Someone';
    const receiverId = participantIds.find((id) => id !== senderId);
    if (!receiverId)
        return;
    const token = await getFcmToken(receiverId);
    if (!token)
        return;
    const message = {
        token,
        notification: {
            title: senderName,
            body: text,
        },
        data: {
            type: 'chat_message',
            chatId,
            senderId,
        },
        android: { priority: 'high' },
        apns: { payload: { aps: { sound: 'default' } } },
    };
    try {
        await admin.messaging().send(message);
        functions.logger.info(`FCM message sent to ${receiverId} for chat ${chatId}`);
    }
    catch (err) {
        functions.logger.warn(`FCM message failed for ${receiverId}:`, err);
    }
});
/**
 * Get the FCM token stored in the user's document.
 */
async function getFcmToken(uid) {
    var _a;
    try {
        const userSnap = await db.collection('users').doc(uid).get();
        if (!userSnap.exists)
            return null;
        const token = (_a = userSnap.data()) === null || _a === void 0 ? void 0 : _a.fcmToken;
        return token || null;
    }
    catch (_b) {
        return null;
    }
}
//# sourceMappingURL=index.js.map