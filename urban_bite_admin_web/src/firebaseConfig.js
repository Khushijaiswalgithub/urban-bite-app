import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyAxV9VuLNdJN0p8dH82RBg5QMWgUAu1bsE",
  authDomain: "zomato-clone-98044.firebaseapp.com",
  projectId: "zomato-clone-98044",
  storageBucket: "zomato-clone-98044.firebasestorage.app",
  messagingSenderId: "872523215931",
  appId: "1:872523215931:web:f5dc6c92698ae2f031d81e",
  measurementId: "G-64BNRZB93B"
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
export const auth = getAuth(app);
