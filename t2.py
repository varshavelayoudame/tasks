# problems/models.py
from django.db import models

class Problem(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    difficulty = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

class TestCase(models.Model):
    problem = models.ForeignKey(Problem, on_delete=models.CASCADE)
    input = models.TextField()
    output = models.TextField()
    is_public = models.BooleanField(default=False)