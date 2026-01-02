#!/bin/bash

# BTEC Assignment API - Example Usage Script
# This script demonstrates the complete workflow for students and teachers

set -e  # Exit on error

BASE_URL="http://localhost:8000"
API_V1="$BASE_URL/api/v1"

echo "======================================"
echo "BTEC Assignment Management API Demo"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Create a test file
echo "Creating test assignment file..."
echo "This is a sample assignment submission for testing purposes." > test_assignment.txt
echo -e "${GREEN}✓ Test file created: test_assignment.txt${NC}"
echo ""

# 1. Student Login
echo -e "${BLUE}=== Step 1: Student Login ===${NC}"
echo "Logging in as user1@btec.edu..."
STUDENT_RESPONSE=$(curl -s -X POST "$API_V1/login/access-token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=user1@btec.edu&password=1234")

STUDENT_TOKEN=$(echo $STUDENT_RESPONSE | grep -o '"access_token":"[^"]*' | sed 's/"access_token":"//')

if [ -z "$STUDENT_TOKEN" ]; then
    echo -e "${RED}✗ Failed to login as student${NC}"
    echo "Response: $STUDENT_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✓ Student logged in successfully${NC}"
echo "Token: ${STUDENT_TOKEN:0:20}..."
echo ""

# 2. Upload Assignment
echo -e "${BLUE}=== Step 2: Upload Assignment ===${NC}"
echo "Uploading assignment as student..."
UPLOAD_RESPONSE=$(curl -s -X POST "$API_V1/assignments/upload" \
  -H "Authorization: Bearer $STUDENT_TOKEN" \
  -F "title=Math Homework Week 1" \
  -F "description=Algebra exercises from chapter 3" \
  -F "file=@test_assignment.txt")

ASSIGNMENT_ID=$(echo $UPLOAD_RESPONSE | grep -o '"id":"[^"]*' | sed 's/"id":"//')

if [ -z "$ASSIGNMENT_ID" ]; then
    echo -e "${RED}✗ Failed to upload assignment${NC}"
    echo "Response: $UPLOAD_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✓ Assignment uploaded successfully${NC}"
echo "Assignment ID: $ASSIGNMENT_ID"
echo ""

# 3. View Student's Assignments
echo -e "${BLUE}=== Step 3: View Student Assignments ===${NC}"
echo "Fetching student's assignments..."
MY_ASSIGNMENTS=$(curl -s -X GET "$API_V1/assignments/my" \
  -H "Authorization: Bearer $STUDENT_TOKEN")

echo -e "${GREEN}✓ Assignments retrieved${NC}"
echo "$MY_ASSIGNMENTS" | python3 -m json.tool
echo ""

# 4. Get Student Statistics
echo -e "${BLUE}=== Step 4: Student Statistics ===${NC}"
echo "Fetching student statistics..."
STUDENT_STATS=$(curl -s -X GET "$API_V1/assignments/stats" \
  -H "Authorization: Bearer $STUDENT_TOKEN")

echo -e "${GREEN}✓ Statistics retrieved${NC}"
echo "$STUDENT_STATS" | python3 -m json.tool
echo ""

# 5. Teacher Login
echo -e "${BLUE}=== Step 5: Teacher Login ===${NC}"
echo "Logging in as teacher1@btec.edu..."
TEACHER_RESPONSE=$(curl -s -X POST "$API_V1/login/access-token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=teacher1@btec.edu&password=1234")

TEACHER_TOKEN=$(echo $TEACHER_RESPONSE | grep -o '"access_token":"[^"]*' | sed 's/"access_token":"//')

if [ -z "$TEACHER_TOKEN" ]; then
    echo -e "${RED}✗ Failed to login as teacher${NC}"
    echo "Response: $TEACHER_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✓ Teacher logged in successfully${NC}"
echo "Token: ${TEACHER_TOKEN:0:20}..."
echo ""

# 6. View All Assignments (Teacher)
echo -e "${BLUE}=== Step 6: View All Assignments (Teacher) ===${NC}"
echo "Fetching all assignments..."
ALL_ASSIGNMENTS=$(curl -s -X GET "$API_V1/assignments/all" \
  -H "Authorization: Bearer $TEACHER_TOKEN")

echo -e "${GREEN}✓ All assignments retrieved${NC}"
echo "$ALL_ASSIGNMENTS" | python3 -m json.tool
echo ""

# 7. Grade Assignment
echo -e "${BLUE}=== Step 7: Grade Assignment ===${NC}"
echo "Teacher grading the assignment..."
GRADE_RESPONSE=$(curl -s -X PUT "$API_V1/assignments/$ASSIGNMENT_ID/grade" \
  -H "Authorization: Bearer $TEACHER_TOKEN" \
  -F "grade=95" \
  -F "comments=Excellent work! Very thorough and well-organized.")

echo -e "${GREEN}✓ Assignment graded${NC}"
echo "$GRADE_RESPONSE" | python3 -m json.tool
echo ""

# 8. Get Teacher Statistics
echo -e "${BLUE}=== Step 8: Teacher Statistics ===${NC}"
echo "Fetching teacher statistics..."
TEACHER_STATS=$(curl -s -X GET "$API_V1/assignments/stats" \
  -H "Authorization: Bearer $TEACHER_TOKEN")

echo -e "${GREEN}✓ Statistics retrieved${NC}"
echo "$TEACHER_STATS" | python3 -m json.tool
echo ""

# 9. Student Views Updated Assignment
echo -e "${BLUE}=== Step 9: Student Views Graded Assignment ===${NC}"
echo "Student checking their graded assignment..."
UPDATED_ASSIGNMENTS=$(curl -s -X GET "$API_V1/assignments/my" \
  -H "Authorization: Bearer $STUDENT_TOKEN")

echo -e "${GREEN}✓ Updated assignments retrieved${NC}"
echo "$UPDATED_ASSIGNMENTS" | python3 -m json.tool
echo ""

# 10. Download Assignment File
echo -e "${BLUE}=== Step 10: Download Assignment File ===${NC}"
echo "Teacher downloading the assignment file..."
curl -s -X GET "$API_V1/assignments/$ASSIGNMENT_ID/download" \
  -H "Authorization: Bearer $TEACHER_TOKEN" \
  -o "downloaded_assignment.txt"

if [ -f "downloaded_assignment.txt" ]; then
    echo -e "${GREEN}✓ File downloaded successfully${NC}"
    echo "Content:"
    cat downloaded_assignment.txt
    echo ""
fi

# Cleanup
echo -e "${BLUE}=== Cleanup ===${NC}"
echo "Cleaning up test files..."
rm -f test_assignment.txt downloaded_assignment.txt
echo -e "${GREEN}✓ Cleanup complete${NC}"
echo ""

echo "======================================"
echo -e "${GREEN}Demo completed successfully!${NC}"
echo "======================================"
echo ""
echo "Summary:"
echo "1. ✓ Student login"
echo "2. ✓ Assignment upload"
echo "3. ✓ View student assignments"
echo "4. ✓ Student statistics"
echo "5. ✓ Teacher login"
echo "6. ✓ View all assignments"
echo "7. ✓ Grade assignment"
echo "8. ✓ Teacher statistics"
echo "9. ✓ View graded assignment"
echo "10. ✓ Download file"
echo ""
echo "Assignment ID used: $ASSIGNMENT_ID"
