"""
fitness_analysis.py — Computer Vision / MediaPipe logic for body analysis.

Currently **mocked** for development speed.  Replace the mock functions
with real MediaPipe Pose + segmentation logic when the CV pipeline is ready.
"""

import asyncio
import random
from typing import Dict


async def analyze_body_image(image_url: str) -> Dict[str, float]:
    """Analyze a user body image and return derived metrics.

    In production this would:
        1. Download the image from ``image_url``.
        2. Run MediaPipe Pose to detect 33 body landmarks.
        3. Calculate the Waist-to-Shoulder Ratio (WSR) from landmark
           distances (shoulder width vs. waist width).
        4. Optionally detect posture anomalies.

    For now, it simulates a short processing delay and returns
    mock values.

    Args:
        image_url: URL of the uploaded body image.

    Returns:
        dict with keys:
            - ``wsr``: Waist-to-Shoulder Ratio (float 0–1).
            - ``confidence``: Model confidence (float 0–1).
            - ``posture_score``: Posture quality score (float 0–1).
    """
    # Simulate async CV processing time (200-500 ms)
    await asyncio.sleep(random.uniform(0.2, 0.5))

    # Mock WSR — in production this comes from landmark analysis
    mock_wsr = round(random.uniform(0.55, 0.95), 2)
    mock_confidence = round(random.uniform(0.75, 0.98), 2)
    mock_posture = round(random.uniform(0.60, 0.95), 2)

    return {
        "wsr": mock_wsr,
        "confidence": mock_confidence,
        "posture_score": mock_posture,
    }


def calculate_bmi(berat_kg: float, tinggi_cm: float) -> float:
    """Calculate Body Mass Index from weight (kg) and height (cm).

    Formula: BMI = weight / (height_in_meters ** 2)
    """
    tinggi_m = tinggi_cm / 100.0
    if tinggi_m <= 0:
        return 0.0
    return round(berat_kg / (tinggi_m ** 2), 1)


def calculate_whtr(lingkar_perut_cm: float, tinggi_cm: float) -> float:
    """Calculate Waist-to-Height Ratio (WHtR).

    A WHtR > 0.5 is generally associated with higher metabolic risk.
    """
    if tinggi_cm <= 0:
        return 0.0
    return round(lingkar_perut_cm / tinggi_cm, 3)