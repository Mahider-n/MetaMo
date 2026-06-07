from dataclasses import dataclass
import numpy as np

@dataclass
class Stimulus:
    novelty: float
    conduciveness: float
    risk: float
    effort: float

@dataclass
class Action:
    id: str
    goal_correlations: np.ndarray
    risk_estimate: float
    delta_g: np.ndarray

@dataclass
class MotivationalState:
    G: np.ndarray
    M: np.ndarray

NUM_GOALS = 8
NUM_MODULATORS = 6
G_IND = 0
G_TRANS = 1
