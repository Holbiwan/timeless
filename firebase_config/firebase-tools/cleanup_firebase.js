// Script pour nettoyer Firebase et garder 25 jobs
// À exécuter dans la console Firebase

console.log("🧹 Nettoyage Firebase - Garder 25 jobs");

// 1. Supprimer les collections inutiles
const collectionsToDelete = ['Apply', 'Auth', 'Users', 'jobs', 'category', 'emailQueue', 'employers', 'notifications', 'sentEmails'];

collectionsToDelete.forEach(collectionName => {
  console.log(`❌ Suppression de la collection: ${collectionName}`);
  // Dans la console Firebase, supprimer manuellement ces collections
});

// 2. Garder seulement 25 documents dans allPost
console.log("📋 Garder seulement 25 jobs dans allPost");

// Script à adapter - garder les 25 premiers et supprimer le reste
firebase.firestore().collection('allPost').limit(25).get().then(snapshot => {
  console.log(`✅ Garder ces ${snapshot.size} jobs:`);
  snapshot.forEach(doc => {
    console.log(`- ${doc.id}: ${doc.data().Position || 'Sans titre'}`);
  });
});

// 3. Collections à conserver :
console.log("✅ Collections à conserver:");
console.log("- allPost (25 jobs max)");
console.log("- applications"); 
console.log("- users");
console.log("- mail (pour les emails)");
console.log("- applicationEmails (logs emails)");