#!/bin/bash

echo "Deploying Firestore security rules..."
echo

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "Firebase CLI is not installed. Please install it first:"
    echo "npm install -g firebase-tools"
    echo
    echo "Then login with: firebase login"
    exit 1
fi

# Deploy Firestore rules
echo "Deploying Firestore rules..."
firebase deploy --only firestore:rules

if [ $? -eq 0 ]; then
    echo
    echo "✅ Firestore rules deployed successfully!"
    echo "Your app should now work without permission errors."
else
    echo
    echo "❌ Failed to deploy Firestore rules."
    echo "Please check your Firebase project configuration."
fi

echo
