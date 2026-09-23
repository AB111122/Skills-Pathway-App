🚀Skills Pathway App⭐📈
AI-Assisted Career Guidance & Opportunity Platform

Skills Pathway is a Flutter-based application designed to help students explore career paths, understand the skills they need, discover opportunities, and connect with universities through one platform.

The application provides separate experiences for Students and Universities, along with AI-assisted career guidance, opportunity management, applications, community features, and notifications.

Problem Statement

Students often find career guidance, internships, scholarships, and other opportunities through different websites, social media platforms, university pages, and informal sources. This makes it difficult to find relevant information and understand which skills are needed for a particular career.

Skills Pathway brings career guidance, skill pathways, opportunities, university interaction, community features, and AI assistance together in one centralized platform.

Objectives
Help students explore different career and skill pathways.
Provide AI-assisted career guidance.
Allow students to discover and apply for opportunities.
Allow universities to publish and manage opportunities.
Allow universities to manage student applications.
Provide application status updates and notifications.
Provide a community for students to interact and share information.
Keep user and application data secure.
Main Features
Student Portal

Students can:

Create an account and manage their profile.
Add their education, skills, interests, and career goals.
Explore career and skill pathways.
Ask questions through the AI Career Assistant.
Browse available opportunities.
Apply for opportunities.
Track application status.
Create and interact with community posts.
Receive notifications.
University Portal

Universities have a separate portal where they can:

Manage their university profile.
Create and publish opportunities.
View student applications.
Manage applicants.
Update application statuses.
Publish official posts.
AI Career Assistant

The application includes an AI-powered career assistant that provides conversational guidance about topics such as:

Career options
Required skills
Learning paths
Career-related questions
Opportunities & Applications

Students can discover opportunities published by universities and submit applications directly through the application.

The system also handles application status updates and prevents duplicate applications.

Community

Users can:

Create posts
Like posts
Comment on posts
Follow other users
View community content
Notifications

The application supports both in-app notifications and Android push notifications using Firebase Cloud Messaging.

User Roles
Student	University
Manage profile	Manage university profile
Explore career pathways	Publish opportunities
Use AI assistant	Manage opportunities
Browse opportunities	View applications
Apply for opportunities	Update application status
Track applications	Publish official posts
Participate in community	—
Receive notifications	—
Application Workflow
Student
Register / Login
       ↓
Complete Profile
       ↓
Explore Careers & Skills
       ↓
Use AI Assistant
       ↓
Discover Opportunities
       ↓
Apply
       ↓
Track Application
       ↓
Receive Notifications
University
Register / Login
       ↓
Complete Profile
       ↓
Create Opportunity
       ↓
Students Apply
       ↓
Review Applications
       ↓
Update Application Status
       ↓
Student Receives Update
Technology Stack
Frontend
Flutter
Dart
Riverpod – State Management
GoRouter – Navigation
Backend
Firebase Authentication – User authentication
Cloud Firestore – Database
Firebase Cloud Messaging – Push notifications
Firestore Security Rules – Database security
AI
Generative AI
OpenAI-compatible API
HTTP
Project Structure
Skills-Pathway-App/
│
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
│
├── assets/
│   └── images/
│
├── lib/
│   ├── core/
│   ├── models/
│   ├── providers/
│   ├── repositories/
│   ├── services/
│   ├── presentation/
│   └── main.dart
│
├── test/
│
├── firebase.json
├── firestore.rules
├── pubspec.yaml
└── README.md
Firebase

Firebase is used as the backend of the application.

Authentication

Firebase Authentication manages:

Student registration and login
University registration and login
Authentication state
Firestore

Cloud Firestore stores application data such as:

Users
Opportunities
Applications
Community Posts
Comments
Notifications
Security

Firestore Security Rules are used to control access to application data based on user roles and ownership.
