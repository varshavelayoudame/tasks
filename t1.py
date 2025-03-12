# accounts/models.py
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    is_admin = models.BooleanField(default=False)
    is_participant = models.BooleanField(default=True)
    is_judge = models.BooleanField(default=False)