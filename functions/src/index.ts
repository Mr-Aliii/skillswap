import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();

/**
 * Send FCM push notification when an in-app notification is created.
 */
export const onNotificationCreated = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return;

    const userId = data.userId as string;
    if (!userId) return;

    const title = data.title as string;
    const body = data.body as string;
    const type = data.type as string || 'general';
    const notificationData = data.data as Record<string, string> | undefined;

    const token = await getFcmToken(userId);
    if (!token) return;

    const message: admin.messaging.Message = {
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
    } catch (err) {
      functions.logger.warn(`FCM failed for ${userId}:`, err);
    }
  });

/**
 * Send FCM push notification when a new chat message is sent.
 */
export const onMessageSent = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return;

    const senderId = data.senderId as string;
    const text = data.text as string;
    const chatId = context.params.chatId;

    if (!senderId || !text || !chatId) return;

    // Get chat doc to find the other participant
    const chatSnap = await db.collection('chats').doc(chatId).get();
    if (!chatSnap.exists) return;

    const chatData = chatSnap.data()!;
    const participantIds = chatData.participantIds as string[];
    const names = chatData.names as Record<string, string> || {};
    const senderName = names[senderId] || 'Someone';

    const receiverId = participantIds.find((id: string) => id !== senderId);
    if (!receiverId) return;

    const token = await getFcmToken(receiverId);
    if (!token) return;

    const message: admin.messaging.Message = {
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
    } catch (err) {
      functions.logger.warn(`FCM message failed for ${receiverId}:`, err);
    }
  });

/**
 * Get the FCM token stored in the user's document.
 */
async function getFcmToken(uid: string): Promise<string | null> {
  try {
    const userSnap = await db.collection('users').doc(uid).get();
    if (!userSnap.exists) return null;
    const token = userSnap.data()?.fcmToken as string | undefined;
    return token || null;
  } catch {
    return null;
  }
}
