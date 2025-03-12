# leaderboard/models.py
from django.db import models
from accounts.models import User
from problems.models import Problem

class Leaderboard(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    problem = models.ForeignKey(Problem, on_delete=models.CASCADE)
    score = models.IntegerField(default=0)
    updated_at = models.DateTimeField(auto_now=True)