const { initializeApp } = require('firebase/app');
const { getFirestore, collection, deleteDoc, doc, getDocs, limit, query, orderBy } = require('firebase/firestore');

// Configuration Firebase
const firebaseConfig = {
  apiKey: 'AIzaSyCH_NvF2Lr5rgpC4Bi33eiwn2EdOk0En4k',
  projectId: 'timeless-6cdf9',
  authDomain: 'timeless-6cdf9.firebaseapp.com',
  storageBucket: 'timeless-6cdf9.firebasestorage.app',
  messagingSenderId: '266056580802',
  appId: '1:266056580802:web:709e2eb5210e6df9e9855b'
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function deleteCollection(collectionName) {
  console.log(`🗑️ Suppression de la collection: ${collectionName}`);
  
  try {
    const querySnapshot = await getDocs(collection(db, collectionName));
    const batch = [];
    
    querySnapshot.forEach((doc) => {
      batch.push(deleteDoc(doc.ref));
    });
    
    await Promise.all(batch);
    console.log(`✅ Collection ${collectionName} supprimée`);
  } catch (error) {
    console.log(`❌ Erreur: ${error}`);
  }
}

async function keepOnly25Jobs() {
  console.log(`📋 Conservation de seulement 25 jobs dans allPost`);
  
  try {
    // Récupérer tous les documents
    const querySnapshot = await getDocs(collection(db, 'allPost'));
    const allDocs = querySnapshot.docs;
    
    console.log(`Total documents: ${allDocs.length}`);
    
    // Garder les 25 premiers, supprimer le reste
    if (allDocs.length > 25) {
      const docsToDelete = allDocs.slice(25); // Du 26ème à la fin
      
      const batch = docsToDelete.map(doc => deleteDoc(doc.ref));
      await Promise.all(batch);
      
      console.log(`✅ ${docsToDelete.length} documents supprimés, 25 conservés`);
    }
  } catch (error) {
    console.log(`❌ Erreur: ${error}`);
  }
}

// Exécution
async function cleanup() {
  // Supprimer les collections inutiles
  await deleteCollection('Apply');
  await deleteCollection('Auth'); 
  await deleteCollection('Users');
  await deleteCollection('jobs');
  await deleteCollection('category');
  await deleteCollection('emailQueue');
  await deleteCollection('employers');
  await deleteCollection('notifications');
  await deleteCollection('sentEmails');
  
  // Garder seulement 25 jobs
  await keepOnly25Jobs();
  
  console.log('🎉 Nettoyage terminé !');
}

cleanup();