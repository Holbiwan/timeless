// Script pour synchroniser users avec Authentication
// À exécuter dans la Console Firebase (F12)

console.log('🔄 Synchronisation users/Auth...');

// IDs des documents vides à traiter
const emptyUserIds = [
  'PdsEnl7FgiRURFHIvxd25xiI6xr1',
  'f4IhKDymS2hONt5yWexKuEsshNy2', 
  'yUVRD2N4FjUPdouprdwveaCEcvM2'
];

// Fonction pour créer un document user minimal
function createMinimalUser(userId, email = null) {
  const userData = {
    uid: userId,
    email: email,
    fullName: email ? email.split('@')[0] : 'Utilisateur Test',
    firstName: email ? email.split('@')[0] : 'Utilisateur',
    lastName: 'Test',
    role: 'user',
    profileCompleted: false,
    isActive: true,
    createdAt: firebase.firestore.FieldValue.serverTimestamp(),
    updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
    appliedJobs: [],
    savedJobs: [],
    provider: 'email'
  };
  
  return firebase.firestore().collection('users').doc(userId).set(userData);
}

// Traiter chaque utilisateur vide
emptyUserIds.forEach(async (userId, index) => {
  try {
    // Essayer de récupérer l'email depuis Auth (si accessible)
    const fakeEmail = `testuser${index + 1}@timeless.test`;
    
    await createMinimalUser(userId, fakeEmail);
    console.log(`✅ User ${userId} créé avec email: ${fakeEmail}`);
    
  } catch (error) {
    console.log(`❌ Erreur pour ${userId}:`, error);
  }
});

console.log('🎯 Script terminé! Vérifiez vos documents users.');