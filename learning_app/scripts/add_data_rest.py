#!/usr/bin/env python3
"""
Script to add sample data to Firebase Firestore using REST API
"""

import requests
import json
import time
from datetime import datetime

# Firebase project configuration
PROJECT_ID = "interntasktracker-d127c"  # Replace with your project ID
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

def add_document(collection, doc_id, data):
    """Add a document to Firestore using REST API"""
    url = f"{BASE_URL}/{collection}/{doc_id}"
    
    # Convert data to Firestore format
    firestore_data = convert_to_firestore_format(data)
    
    response = requests.patch(url, json=firestore_data)
    
    if response.status_code == 200:
        print(f"[OK] Added {collection}/{doc_id}")
        return True
    else:
        print(f"[ERROR] Failed to add {collection}/{doc_id}: {response.text}")
        return False

def convert_to_firestore_format(data):
    """Convert Python data to Firestore format"""
    result = {"fields": {}}
    
    for key, value in data.items():
        if value is None:
            result["fields"][key] = {"nullValue": None}
        elif isinstance(value, bool):
            # Check bool BEFORE int because bool is a subclass of int in Python
            result["fields"][key] = {"booleanValue": value}
        elif isinstance(value, int):
            result["fields"][key] = {"integerValue": str(value)}
        elif isinstance(value, float):
            result["fields"][key] = {"doubleValue": value}
        elif isinstance(value, str):
            result["fields"][key] = {"stringValue": value}
        elif isinstance(value, list):
            # Handle arrays by checking the type of elements
            if not value:
                # Empty array
                result["fields"][key] = {"arrayValue": {"values": []}}
            else:
                # Convert each element based on its type
                converted_values = []
                for item in value:
                    if item is None:
                        converted_values.append({"nullValue": None})
                    elif isinstance(item, bool):
                        converted_values.append({"booleanValue": item})
                    elif isinstance(item, int):
                        converted_values.append({"integerValue": str(item)})
                    elif isinstance(item, float):
                        converted_values.append({"doubleValue": item})
                    elif isinstance(item, str):
                        converted_values.append({"stringValue": str(item)})
                    elif isinstance(item, dict):
                        # Recursively convert nested objects
                        converted_values.append({"mapValue": convert_to_firestore_format(item)})
                    elif isinstance(item, list):
                        # Handle nested arrays (rare, but possible)
                        nested_array = convert_to_firestore_format({"temp": item})
                        converted_values.append(nested_array["fields"]["temp"])
                result["fields"][key] = {"arrayValue": {"values": converted_values}}
        elif isinstance(value, dict):
            result["fields"][key] = {"mapValue": convert_to_firestore_format(value)}
        elif isinstance(value, datetime):
            result["fields"][key] = {"timestampValue": value.isoformat() + "Z"}
    
    return result

def main():
    print("Starting to seed Firebase database...")
    
    # Expanded courses data
    courses = [
        {
            "id": "flutter_basics",
            "title": "Flutter Development Fundamentals",
            "description": "Learn the basics of Flutter development from scratch. This comprehensive course covers widgets, state management, navigation, and more.",
            "instructor": "Dr. Sarah Ahmed",
            "thumbnailUrl": "https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=400",
            "category": "Mobile Development",
            "duration": 480,
            "totalLessons": 12,
            "rating": 4.8,
            "enrolledCount": 1250,
            "difficulty": "beginner",
            "tags": ["Flutter", "Dart", "Mobile", "Cross-platform"],
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "isPublished": True
        },
        {
            "id": "react_advanced",
            "title": "Advanced React Patterns",
            "description": "Master advanced React concepts including hooks, context, performance optimization, and modern development patterns.",
            "instructor": "Prof. Michael Johnson",
            "thumbnailUrl": "https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400",
            "category": "Web Development",
            "duration": 600,
            "totalLessons": 15,
            "rating": 4.9,
            "enrolledCount": 890,
            "difficulty": "intermediate",
            "tags": ["React", "JavaScript", "Hooks", "Performance"],
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "isPublished": True
        },
        {
            "id": "python_ml",
            "title": "Machine Learning with Python",
            "description": "Complete guide to machine learning using Python, covering algorithms, data preprocessing, model evaluation, and deployment.",
            "instructor": "Dr. Aisha Khan",
            "thumbnailUrl": "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=400",
            "category": "Data Science",
            "duration": 720,
            "totalLessons": 18,
            "rating": 4.7,
            "enrolledCount": 2100,
            "difficulty": "intermediate",
            "tags": ["Python", "Machine Learning", "Data Science", "AI"],
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "isPublished": True
        },
        {
            "id": "aws_cloud",
            "title": "AWS Cloud Architecture",
            "description": "Learn to design and implement scalable cloud solutions using Amazon Web Services.",
            "instructor": "Eng. David Wilson",
            "thumbnailUrl": "https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400",
            "category": "Cloud Computing",
            "duration": 540,
            "totalLessons": 14,
            "rating": 4.6,
            "enrolledCount": 750,
            "difficulty": "advanced",
            "tags": ["AWS", "Cloud", "DevOps", "Architecture"],
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "isPublished": True
        },
        {
            "id": "ui_ux_design",
            "title": "UI/UX Design Principles",
            "description": "Master the fundamentals of user interface and user experience design with practical projects.",
            "instructor": "Designer Lisa Chen",
            "thumbnailUrl": "https://images.unsplash.com/photo-1558655146-d09347e92766?w=400",
            "category": "Design",
            "duration": 360,
            "totalLessons": 10,
            "rating": 4.5,
            "enrolledCount": 980,
            "difficulty": "beginner",
            "tags": ["UI Design", "UX Design", "Figma", "Prototyping"],
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "isPublished": True
        },
        {
            "id": "nodejs_backend",
            "title": "Node.js Backend Development",
            "description": "Build scalable backend applications with Node.js, Express, and MongoDB.",
            "instructor": "Dev. Robert Brown",
            "thumbnailUrl": "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=400",
            "category": "Backend Development",
            "duration": 660,
            "totalLessons": 16,
            "rating": 4.7,
            "enrolledCount": 1150,
            "difficulty": "intermediate",
            "tags": ["Node.js", "Express", "MongoDB", "API"],
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "isPublished": True
        },
        {
            "id": "devops_cicd",
            "title": "DevOps & CI/CD Pipeline",
            "description": "Learn to automate software deployment with CI/CD pipelines using Jenkins, Docker, and Kubernetes.",
            "instructor": "DevOps Engineer James Martinez",
            "thumbnailUrl": "https://images.unsplash.com/photo-1667372393119-3d4c48d07fc9?w=400",
            "category": "DevOps",
            "duration": 540,
            "totalLessons": 13,
            "rating": 4.6,
            "enrolledCount": 680,
            "difficulty": "advanced",
            "tags": ["DevOps", "CI/CD", "Docker", "Kubernetes", "Jenkins"],
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "isPublished": True
        },
        {
            "id": "blockchain_basics",
            "title": "Blockchain Fundamentals",
            "description": "Understand blockchain technology, smart contracts, and decentralized applications.",
            "instructor": "Dr. Emma Thompson",
            "thumbnailUrl": "https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=400",
            "category": "Blockchain",
            "duration": 480,
            "totalLessons": 12,
            "rating": 4.4,
            "enrolledCount": 520,
            "difficulty": "beginner",
            "tags": ["Blockchain", "Ethereum", "Smart Contracts", "Web3"],
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "isPublished": True
        },
        {
            "id": "angular_advanced",
            "title": "Advanced Angular Development",
            "description": "Master advanced Angular features including lazy loading, RxJS, and enterprise patterns.",
            "instructor": "Prof. Kevin Lee",
            "thumbnailUrl": "https://images.unsplash.com/photo-1593288942460-e321b92f744d?w=400",
            "category": "Web Development",
            "duration": 600,
            "totalLessons": 15,
            "rating": 4.8,
            "enrolledCount": 950,
            "difficulty": "intermediate",
            "tags": ["Angular", "TypeScript", "RxJS", "Enterprise"],
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "isPublished": True
        },
        {
            "id": "data_analytics",
            "title": "Data Analytics with Python",
            "description": "Learn data analysis, visualization, and insights using Python, pandas, and matplotlib.",
            "instructor": "Dr. Maria Garcia",
            "thumbnailUrl": "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400",
            "category": "Data Science",
            "duration": 420,
            "totalLessons": 11,
            "rating": 4.5,
            "enrolledCount": 1100,
            "difficulty": "beginner",
            "tags": ["Python", "Pandas", "Data Visualization", "Analytics"],
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "isPublished": True
        }
    ]
    
    # Add courses
    print("Adding courses...")
    for course in courses:
        add_document("courses", course["id"], course)
        time.sleep(0.5)  # Rate limiting
    
    # Expanded lessons data
    lessons = [
        # Flutter Basics Lessons
        {
            "id": "flutter_intro",
            "courseId": "flutter_basics",
            "title": "Introduction to Flutter",
            "description": "Get started with Flutter development environment and understand the basics.",
            "type": "video",
            "order": 1,
            "duration": 30,
            "videoUrl": "https://youtu.be/VPvVD8t02U8?si=RPYAJhMp8Ez3-REE",
            "isPublished": True,
            "isFree": True,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "attachments": []
        },
        {
            "id": "flutter_quiz_lesson",
            "courseId": "flutter_basics",
            "title": "Flutter Quiz Assessment",
            "description": "Test your understanding of Flutter fundamentals with this quiz.",
            "type": "quiz",
            "order": 4,
            "duration": 15,
            "quizId": "flutter_quiz",
            "isPublished": True,
            "isFree": True,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "attachments": []
        },
        {
            "id": "flutter_widgets",
            "courseId": "flutter_basics",
            "title": "Understanding Widgets",
            "description": "Learn about Flutter widgets and how to use them effectively.",
            "type": "video",
            "order": 2,
            "duration": 45,
            "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            "isPublished": True,
            "isFree": False,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "attachments": []
        },
        {
            "id": "flutter_state",
            "courseId": "flutter_basics",
            "title": "State Management in Flutter",
            "description": "Master state management patterns in Flutter applications.",
            "type": "video",
            "order": 3,
            "duration": 60,
            "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            "isPublished": True,
            "isFree": False,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "attachments": []
        },
        # React Advanced Lessons
        {
            "id": "react_hooks",
            "courseId": "react_advanced",
            "title": "Advanced React Hooks",
            "description": "Deep dive into custom hooks and advanced hook patterns.",
            "type": "video",
            "order": 1,
            "duration": 50,
            "videoUrl": "https://youtu.be/dCLhUialKPQ?si=C5iRtUi9nMFN_T4-",
            "isPublished": True,
            "isFree": True,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "attachments": []
        },
        {
            "id": "react_performance",
            "courseId": "react_advanced",
            "title": "Performance Optimization",
            "description": "Learn techniques to optimize React application performance.",
            "type": "video",
            "order": 2,
            "duration": 55,
            "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "isPublished": True,
            "isFree": False,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "attachments": []
        },
        # Python ML Lessons
        {
            "id": "ml_intro",
            "courseId": "python_ml",
            "title": "Introduction to Machine Learning",
            "description": "Understanding the fundamentals of machine learning.",
            "type": "video",
            "order": 1,
            "duration": 40,
            "videoUrl": "https://youtu.be/hDKCxebp88A?si=72DaJGe5JxMhrhOB",
            "isPublished": True,
            "isFree": True,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "attachments": []
        },
        {
            "id": "ml_models",
            "courseId": "python_ml",
            "title": "Building ML Models",
            "description": "Learn to build and train machine learning models.",
            "type": "video",
            "order": 2,
            "duration": 65,
            "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            "isPublished": True,
            "isFree": False,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "attachments": []
        },
        # AWS Cloud Lessons
        {
            "id": "aws_ec2",
            "courseId": "aws_cloud",
            "title": "AWS EC2 Fundamentals",
            "description": "Learn about AWS EC2 instances and configuration.",
            "type": "video",
            "order": 1,
            "duration": 50,
            "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            "isPublished": True,
            "isFree": True,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "attachments": []
        },
        # UI/UX Lessons
        {
            "id": "ux_research",
            "courseId": "ui_ux_design",
            "title": "UX Research Methods",
            "description": "Learn essential UX research techniques and methodologies.",
            "type": "video",
            "order": 1,
            "duration": 45,
            "videoUrl": "https://youtu.be/truRwcI7-kg?si=pKTi6MIGBxEr8ju8",
            "isPublished": True,
            "isFree": True,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "attachments": []
        },
        # Node.js Lessons
        {
            "id": "node_intro",
            "courseId": "nodejs_backend",
            "title": "Introduction to Node.js",
            "description": "Get started with Node.js and npm packages.",
            "type": "video",
            "order": 1,
            "duration": 40,
            "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            "isPublished": True,
            "isFree": True,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "attachments": []
        },
        {
            "id": "express_api",
            "courseId": "nodejs_backend",
            "title": "Building REST APIs with Express",
            "description": "Create RESTful APIs using Express framework.",
            "type": "video",
            "order": 2,
            "duration": 60,
            "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "isPublished": True,
            "isFree": False,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now(),
            "attachments": []
        }
    ]
    
    # Add lessons
    print("Adding lessons...")
    for lesson in lessons:
        add_document("lessons", lesson["id"], lesson)
        time.sleep(0.5)
    
    # Read quizzes from quizzes.json file
    import os
    # Get the parent directory (project root)
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    quizzes_file_path = os.path.join(project_root, 'quizzes.json')
    with open(quizzes_file_path, 'r', encoding='utf-8') as f:
        quizzes_data = json.load(f)
    
    # Convert quizzes from JSON to the format needed for Firestore
    quizzes = []
    topic_to_course_map = {
        "Flutter": ("flutter_basics", "flutter_quiz_lesson", "flutter_quiz"),
        "React": ("react_advanced", "react_hooks", "react_quiz"),
        "UI/UX": ("ui_ux_design", "ux_research", "ui_ux_quiz"),
        "C++": ("python_ml", "ml_intro", "cpp_quiz")  # Using python_ml course for C++ as placeholder
    }
    
    question_counter = 1
    for topic_data in quizzes_data.get("quizzes", []):
        topic = topic_data["topic"]
        mapping = topic_to_course_map.get(topic, ("flutter_basics", "flutter_intro", "flutter_quiz"))
        course_id, lesson_id, quiz_id = mapping
        
        quiz_questions = []
        for idx, q in enumerate(topic_data["questions"], 1):
            options = []
            for opt_idx, option_text in enumerate(q["options"]):
                is_correct = (opt_idx == q["answer_index"])
                options.append({
                    "id": f"opt{question_counter}_{opt_idx}",
                    "text": option_text,
                    "isCorrect": is_correct,
                    "order": opt_idx + 1
                })
            
            quiz_questions.append({
                "id": f"q{question_counter}",
                "question": q["question"],
                "type": "multipleChoice",
                "options": options,
                "points": 10,
                "order": idx
            })
            question_counter += 1
        quizzes.append({
            "id": quiz_id,
            "courseId": course_id,
            "lessonId": lesson_id,
            "title": f"{topic} Quiz",
            "description": f"Test your understanding of {topic} fundamentals.",
            "questions": quiz_questions,
            "timeLimit": 15,
            "passingScore": 70,
            "maxAttempts": 3,
            "isPublished": True,
            "createdAt": datetime.now(),
            "updatedAt": datetime.now()
        })
    
    # Add quizzes
    print("Adding quizzes...")
    for quiz in quizzes:
        add_document("quizzes", quiz["id"], quiz)
        time.sleep(0.5)
    
    print("Sample data added successfully!")
    print("Note: You may need to authenticate with Firebase to add data to production.")

if __name__ == "__main__":
    main()
