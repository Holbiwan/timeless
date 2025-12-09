// Script pour identifier les utilisateurs
// À exécuter dans la Console Firebase (F12)

const userIds = [
  'EUpZ0aL6dKY0deJdH81PstymbiW2',
  'PdsEnl7FgiRURFHIvxd25xiI6xr1', 
  'f4IhKDymS2hONt5yWexKuEsshNy2',
  'yUVRD2N4FjUPdouprdwveaCEcvM2'
];

userIds.forEach(userId => {
  firebase.firestore().collection('users').doc(userId).get().then(doc => {
    if (doc.exists) {
      const data = doc.data();
      console.log(`${userId}: ${data.email || data.fullName || 'Nom inconnu'} (${data.userType || data.accountType || 'Type inconnu'})`);
    }
  });
});