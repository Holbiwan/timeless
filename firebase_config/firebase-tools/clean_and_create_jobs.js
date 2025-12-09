const { initializeApp } = require('firebase/app');
const { getFirestore, collection, deleteDoc, doc, getDocs, addDoc } = require('firebase/firestore');

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

// 1. Supprimer tous les jobs existants
async function clearAllJobs() {
  console.log('🗑️ Suppression de tous les jobs existants...');
  
  try {
    const querySnapshot = await getDocs(collection(db, 'allPost'));
    console.log(`📊 Trouvé ${querySnapshot.size} documents à supprimer`);
    
    const deletePromises = [];
    querySnapshot.forEach((docSnapshot) => {
      deletePromises.push(deleteDoc(docSnapshot.ref));
    });
    
    await Promise.all(deletePromises);
    console.log('✅ Tous les jobs supprimés');
  } catch (error) {
    console.log(`❌ Erreur lors de la suppression: ${error}`);
  }
}

// 2. Créer 12 nouveaux jobs catégorisés
async function createCategorizedJobs() {
  console.log('📝 Création de 12 nouveaux jobs catégorisés...');
  
  const jobs = [
    // 4 jobs UX/UI
    {
      Position: "UI/UX Designer Senior",
      CompanyName: "DesignCorp",
      location: "Paris",
      salary: "50000",
      category: "UX/UI",
      description: "Conception d'interfaces utilisateur innovantes pour applications mobiles et web. Expérience en Figma, Adobe XD requis.",
      requirements: "3+ ans d'expérience, Portfolio requis",
      jobType: "CDI",
      experience: "Senior"
    },
    {
      Position: "Product Designer",
      CompanyName: "TechStart",
      location: "Lyon",
      salary: "45000",
      category: "UX/UI", 
      description: "Design de produits digitaux end-to-end. Recherche utilisateur, prototypage, tests d'utilisabilité.",
      requirements: "2+ ans d'expérience en product design",
      jobType: "CDI",
      experience: "Intermédiaire"
    },
    {
      Position: "UX Researcher",
      CompanyName: "UserFirst",
      location: "Toulouse",
      salary: "42000",
      category: "UX/UI",
      description: "Recherche utilisateur qualitative et quantitative. Analyse des besoins, interviews, tests utilisateurs.",
      requirements: "Formation en psychologie ou design",
      jobType: "CDD",
      experience: "Junior"
    },
    {
      Position: "Design System Specialist",
      CompanyName: "SystemDesign",
      location: "Bordeaux",
      salary: "55000",
      category: "UX/UI",
      description: "Création et maintenance de design systems. Collaboration étroite avec les équipes de développement.",
      requirements: "Expérience en design tokens, Figma avancé",
      jobType: "CDI",
      experience: "Senior"
    },
    
    // 4 jobs Data
    {
      Position: "Data Scientist",
      CompanyName: "DataMind",
      location: "Paris",
      salary: "65000",
      category: "Data",
      description: "Analyse de données complexes, machine learning, modélisation prédictive. Python, R, SQL requis.",
      requirements: "Master en statistiques, 3+ ans d'expérience",
      jobType: "CDI",
      experience: "Senior"
    },
    {
      Position: "Data Analyst",
      CompanyName: "Analytics Pro",
      location: "Nantes",
      salary: "40000",
      category: "Data",
      description: "Analyse de données business, création de tableaux de bord, reporting. Excel, Power BI, SQL.",
      requirements: "2+ ans d'expérience en analyse de données",
      jobType: "CDI",
      experience: "Intermédiaire"
    },
    {
      Position: "Data Engineer",
      CompanyName: "BigData Solutions",
      location: "Lille",
      salary: "58000",
      category: "Data",
      description: "Construction de pipelines de données, ETL, infrastructure cloud. Python, Spark, AWS.",
      requirements: "Expérience en architecture de données",
      jobType: "CDI",
      experience: "Senior"
    },
    {
      Position: "Business Intelligence Analyst",
      CompanyName: "BI Corp",
      location: "Marseille",
      salary: "38000",
      category: "Data",
      description: "Développement de solutions BI, reporting avancé, analyse des performances business.",
      requirements: "Connaissance des outils BI (Tableau, Qlik)",
      jobType: "CDD",
      experience: "Junior"
    },
    
    // 4 jobs Security
    {
      Position: "Cybersecurity Engineer",
      CompanyName: "SecureNet",
      location: "Paris",
      salary: "70000",
      category: "Security",
      description: "Protection des systèmes d'information, audit sécurité, gestion des incidents de sécurité.",
      requirements: "Certification CISSP ou CISM, 5+ ans d'expérience",
      jobType: "CDI",
      experience: "Expert"
    },
    {
      Position: "Security Analyst",
      CompanyName: "CyberGuard",
      location: "Strasbourg",
      salary: "45000",
      category: "Security",
      description: "Surveillance des menaces, analyse des logs, réponse aux incidents de sécurité.",
      requirements: "Formation en cybersécurité, 2+ ans d'expérience",
      jobType: "CDI",
      experience: "Intermédiaire"
    },
    {
      Position: "Penetration Tester",
      CompanyName: "EthicalHack",
      location: "Nice",
      salary: "55000",
      category: "Security",
      description: "Tests de pénétration, audit de sécurité, identification des vulnérabilités.",
      requirements: "Certifications CEH ou OSCP",
      jobType: "CDI",
      experience: "Senior"
    },
    {
      Position: "Security Consultant",
      CompanyName: "SecConsult",
      location: "Montpellier",
      salary: "60000",
      category: "Security",
      description: "Conseil en sécurité informatique, mise en conformité RGPD, formation sécurité.",
      requirements: "Expérience en conseil, excellentes compétences communication",
      jobType: "Freelance",
      experience: "Senior"
    }
  ];

  try {
    for (let i = 0; i < jobs.length; i++) {
      const job = jobs[i];
      await addDoc(collection(db, 'allPost'), job);
      console.log(`✅ Job ${i + 1}/12 créé: ${job.Position} (${job.category})`);
    }
    console.log('🎉 Tous les jobs créés avec succès !');
  } catch (error) {
    console.log(`❌ Erreur lors de la création: ${error}`);
  }
}

// Exécution principale
async function main() {
  await clearAllJobs();
  await createCategorizedJobs();
  console.log('🎯 Terminé ! Vous avez maintenant 12 jobs propres et catégorisés.');
}

main();