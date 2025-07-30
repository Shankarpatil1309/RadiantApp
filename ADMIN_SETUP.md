# Admin Access Setup Guide

## 🔐 Setting up Admin Access

To enable admin access for your B.K.I.T College app, you need to create the `allowedAdmins` collection in Firestore.

### Option 1: Using Firebase Console (Recommended)

1. **Open Firebase Console**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select your project

2. **Navigate to Firestore Database**
   - Click on "Firestore Database" in the left sidebar
   - Go to the "Data" tab

3. **Create allowedAdmins Collection**
   - Click "Start Collection"
   - Collection ID: `allowedAdmins`
   - Document ID: `admins`

4. **Add Admin Emails**
   ```json
   {
     "emails": [
       "principal@bkit.edu.in",
       "admin@bkit.edu.in",
       "dean@bkit.edu.in",
       "uapatil614@gmail.com"
     ],
     "createdAt": "2025-01-30T10:00:00Z",
     "updatedAt": "2025-01-30T10:00:00Z"
   }
   ```

### Option 2: Using Flutter Admin Panel

Once you have one admin setup, you can use the app to add more admins:

1. Sign in as an existing admin
2. Navigate to Admin Dashboard
3. Use "User Management" to add new admin emails

### 🔑 Testing the Setup

1. **Test Admin Access**
   - Open the app
   - Select "Administrator" role
   - Sign in with an email from the `allowedAdmins` list
   - Should successfully access Admin Dashboard

2. **Test Student/Faculty Access**
   - Students must be added through Admin Dashboard → "Add Student"
   - Faculty must be added through Admin Dashboard → "Add Faculty"
   - Only users in these collections can access the app with their respective roles

### 🚨 Security Notes

- **Admin emails** are checked against the `allowedAdmins` collection
- **Faculty access** requires entry in the `faculty` collection (added by admin)
- **Student access** requires entry in the `students` collection (added by admin)
- Users not in any collection will be denied access with a clear error message

### 📱 User Flow

1. **Login Screen**: User selects role (Student/Faculty/Administrator)
2. **Google Sign-In**: User signs in with Google
3. **Validation**: App checks if user exists in selected role collection
4. **Access Granted/Denied**: User either gets access or sees error message

### 🛠️ Error Messages

Users will see specific error messages:

- **Invalid Role**: "You don't have access to the app as [ROLE]. Please contact the college administration..."
- **Invalid Email Domain**: "Please use your B.K.I.T college email address to sign in."
- **No Access**: Clear message with admin contact information

### 📞 Support Contact

If users face issues, they should contact:
- **Email**: admin@bkit.edu.in
- **Phone**: +91 80-12345678

---

## 🔄 Firebase Collections Structure

### allowedAdmins
```
allowedAdmins/
└── admins/
    ├── emails: ["admin@bkit.edu.in", ...]
    ├── createdAt: timestamp
    └── updatedAt: timestamp
```

### students (managed by admin)
```
students/
└── [auto-id]/
    ├── name: "Student Name"
    ├── email: "student@bkit.edu.in"
    ├── usn: "1BK21CS001"
    ├── department: "CSE"
    ├── isActive: true
    └── ...
```

### faculty (managed by admin)
```
faculty/
└── [auto-id]/
    ├── name: "Faculty Name"
    ├── email: "faculty@bkit.edu.in"
    ├── employeeId: "EMP2024001"
    ├── department: "CSE"
    ├── isActive: true
    └── ...
```