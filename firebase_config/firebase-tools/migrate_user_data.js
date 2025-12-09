// Script de migration pour harmoniser les données utilisateur
// À exécuter dans la Console Firebase (F12)

console.log('🔄 Migration des données utilisateur...');

// Document utilisateur actuel à migrer
const userId = 'Yta2ThYNzKecOmlFWoj1uyQ7Ta72';

firebase.firestore().collection('users').doc(userId).get().then(doc => {
  if (!doc.exists) {
    console.log('❌ Document utilisateur non trouvé');
    return;
  }

  const currentData = doc.data();
  console.log('📊 Données actuelles:', currentData);

  // Structure unifiée compatible avec ProfileCompletionController
  const unifiedData = {
    // IDs et base (conservés)
    uid: currentData.uid || userId,
    email: currentData.email || 'bryanomane@gmail.com',

    // Noms (normalisés)
    firstName: currentData.firstName || 'Sabrina',
    lastName: currentData.lastName || 'HOLBIWAN', 
    fullName: currentData.fullName || 'Sabrina HOLBIWAN',
    
    // Contact (conservés)
    phoneNumber: currentData.phoneNumber || '0616898985',
    photoURL: currentData.photoURL || null,
    
    // Professionnel (normalisés)
    title: currentData.title || 'Dev',
    bio: currentData.bio || 'junior en recherche',
    experience: currentData.experience || 'junior',
    city: currentData.city || 'Paris',
    
    // Préférences (structure unifiée)
    jobPreferences: {
      categories: currentData.jobPreferences?.categories || [],
      workType: currentData.jobPreferences?.workType || ['remote', 'hybrid', 'onsite'],
      contractType: currentData.jobPreferences?.contractType || ['fulltime'],
      salaryRange: {
        min: currentData.jobPreferences?.salaryRange?.min || null,
        max: currentData.jobPreferences?.salaryRange?.max || null,
        currency: currentData.jobPreferences?.salaryRange?.currency || 'EUR'
      }
    },
    
    // Activité (conservés)
    savedJobs: currentData.savedJobs || [],
    appliedJobs: currentData.appliedJobs || [],
    
    // Métadonnées (conservées/normalisées)
    provider: currentData.provider || 'google',
    role: currentData.role || 'user',
    profileCompleted: currentData.profileCompleted || true,
    isActive: currentData.isActive !== undefined ? currentData.isActive : true,
    createdAt: currentData.createdAt || firebase.firestore.FieldValue.serverTimestamp(),
    updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
    lastLogin: currentData.lastLogin || firebase.firestore.FieldValue.serverTimestamp()
  };

  console.log('✅ Données unifiées:', unifiedData);

  // Appliquer la migration
  return firebase.firestore().collection('users').doc(userId).set(unifiedData, { merge: false });
}).then(() => {
  console.log('🎉 Migration réussie ! Le profil utilisateur est maintenant unifié.');
  console.log('📋 Structure standardisée appliquée');
  console.log('🔄 Redémarrez votre app Flutter pour voir les changements');
}).catch(error => {
  console.error('❌ Erreur de migration:', error);
});