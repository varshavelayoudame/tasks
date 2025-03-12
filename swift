import os
import uuid
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.utils.timezone import now
from django.contrib.auth import get_user_model
from django.core.validators import MinValueValidator, MaxValueValidator
from django.contrib.postgres.fields import ArrayField

# Custom User Manager
class UserManager(BaseUserManager):
    def create_user(self, username, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Email is required")
        email = self.normalize_email(email)
        user = self.model(username=username, email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(username, email, password, **extra_fields)

# User Model
class User(AbstractUser):
    email = models.EmailField(unique=True)
    rating = models.IntegerField(default=1500)
    USER_ROLES = (
        ('admin', 'Admin'),
        ('participant', 'Participant'),
        ('judge', 'Judge'),
    )
    role = models.CharField(max_length=20, choices=USER_ROLES, default='participant')
    objects = UserManager()
    
    def _str_(self):
        return self.username

# Problem Model
class Problem(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    difficulty = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    test_cases = ArrayField(models.JSONField(), default=list)
    created_at = models.DateTimeField(auto_now_add=True)

    def _str_(self):
        return self.title

# Submission Model
class Submission(models.Model):
    user = models.ForeignKey(get_user_model(), on_delete=models.CASCADE)
    problem = models.ForeignKey(Problem, on_delete=models.CASCADE)
    code = models.TextField()
    language = models.CharField(max_length=50, choices=[('python', 'Python'), ('cpp', 'C++'), ('java', 'Java')])
    status = models.CharField(max_length=50, default='Pending')
    created_at = models.DateTimeField(auto_now_add=True)

    def _str_(self):
        return f'{self.user.username} - {self.problem.title}'

# Leaderboard Model
class Leaderboard(models.Model):
    user = models.OneToOneField(get_user_model(), on_delete=models.CASCADE)
    score = models.IntegerField(default=0)
    last_updated = models.DateTimeField(default=now)

    def _str_(self):
        return f'{self.user.username}: {self.score}'

# Contest Model
class Contest(models.Model):
    name = models.CharField(max_length=255)
    problems = models.ManyToManyField(Problem)
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()

    def is_active(self):
        return self.start_time <= now() <= self.end_time

    def _str_(self):
        return self.name

# Plagiarism Detection Placeholder (Basic Example)
def check_plagiarism(code1, code2):
    return hash(code1) == hash(code2)

# Example: Running a Submission
import subprocess

def execute_code(code, language):
    temp_filename = f'/tmp/{uuid.uuid4()}.{language}'
    with open(temp_filename, 'w') as f:
        f.write(code)
    
    command = {
        'python': ['python3', temp_filename],
        'cpp': ['g++', temp_filename, '-o', temp_filename + '.out', '&&', temp_filename + '.out'],
        'java': ['javac', temp_filename, '&&', 'java', temp_filename.replace('.java', '')]
    }
    try:
        result = subprocess.run(command[language], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=5)
        return result.stdout.decode('utf-8'), result.stderr.decode('utf-8')
    except Exception as e:
        return None, str(e)
    finally:
        os.remove(temp_filename)

# API Views and Leaderboard Updater Placeholder
# You can implement Django REST Framework for proper APIs
