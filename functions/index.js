const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendJobNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    if (notification.type !== 'new_job') {
      return null;
    }

    const message = {
      notification: {
        title: 'New Job Available!',
        body: notification.jobTitle,
      },
      data: {
        type: 'new_job',
        jobId: notification.jobId,
        jobTitle: notification.jobTitle,
        job: JSON.stringify(notification.job),
      },
      token: notification.token,
    };

    try {
      await admin.messaging().send(message);
      console.log('Successfully sent notification:', notification.jobId);
      return null;
    } catch (error) {
      console.error('Error sending notification:', error);
      return null;
    }
  }); 