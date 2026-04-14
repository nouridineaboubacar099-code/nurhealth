

Aller au contenu
Utiliser Gmail avec un lecteur d'écran
Cette version du navigateur n'est plus compatible. Veuillez installer un navigateur compatible.
1 sur 258
(aucun objet)
Boîte de réception

Ado Tinkim
18:36 (il y a 0 minute)
À moi

nom → "Admin NurHealth"
email → "ton@email.com"
role → "admin"
statut → "actif"
createdAt → (timestamp maintenant)
C) Règles Firestore — remplace par :
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /users/{userId} {
      allow read: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    match /{document=**} {
      allow read, write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
  