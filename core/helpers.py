import numpy as np
 
def list_difference(arr1, arr2):
    if arr1 is None or len(arr1) == 0: return []
    if arr2 is None or len(arr2) == 0: return []

    if len(arr1) != len(arr2): return []

    diff = np.asarray(arr1, dtype=float) - np.asarray(arr2, dtype=float)
    
    return diff.tolist()

def norm(arr):
    if arr is None or len(arr) == 0: return 0.0
    return float(np.linalg.norm(arr))

def calculate_norm_difference(arr1, arr2):
    if arr1 is None or len(arr1) == 0: return 0.0
    if arr2 is None or len(arr2) == 0: return 0.0
    
    if len(arr1) != len(arr2): return 0.0

    a = np.asarray(arr1)
    b = np.asarray(arr2)

    diff = np.sum(np.square(a - b))
    return round(float(diff), 2)

def cosine_similarity(arr1, arr2):
    if arr1 is None or len(arr1) == 0: return 0.0
    if arr2 is None or len(arr2) == 0: return 0.0
    
    if len(arr1) != len(arr2): return 0.0

    a, b = np.asarray(arr1), np.asarray(arr2)
    norm_a = np.linalg.norm(a)
    norm_b = np.linalg.norm(b)
    
    if norm_a == 0 or norm_b == 0:
        return 0.0
    
    dot_product = np.dot(a, b)
    return round(float(dot_product / (norm_a * norm_b)), 3)

def normalize_vector(arr):
    if arr is None or len(arr) == 0: return []
    a = np.asarray(arr)
    n = np.linalg.norm(a)
    return (a / n).tolist() if n > 0 else a.tolist()


# --- array operations ---

def split(arr, indices_or_sections):
    if arr is None or len(arr) == 0:
        return [] 
    try:
        res = np.split(np.asarray(arr), indices_or_sections)
        return [x.tolist() for x in res]
    except ValueError:
        return []
    
def sum_array(arr):
    if arr is None or len(arr) == 0: return 0.0
    return float(np.sum(arr))

def prod_array(arr):
    if arr is None or len(arr) == 0: return 1.0
    return float(np.prod(arr))

def mean_array(arr):
    if arr is None or len(arr) == 0: return 0.0
    return float(np.mean(arr))

def std_array(arr):
    if arr is None or len(arr) == 0: return 0.0
    return round(float(np.std(arr)), 2)

def var_array(arr):
    if arr is None or len(arr) == 0: return 0.0
    return float(np.var(arr))

def dot_array(arr1, arr2):
    if arr1 is None or len(arr1) == 0: return 0.0
    if arr2 is None or len(arr2) == 0: return 0.0

    if len(arr1) != len(arr2): return 0.0

    a = np.asarray(arr1)
    b = np.asarray(arr2)
    return float(np.dot(a, b))


# --- additional helper functions ---

def softmax(arr):
    if arr is None or len(arr) == 0:
        return []
        
    a = np.asarray(arr)
    exp_a = np.exp(a - np.max(a))
    
    sum_exp = exp_a.sum()
    if sum_exp == 0:
        return []
    # no round 
    return (exp_a / sum_exp).tolist()   

def round_number(value, digits=0):
    return round(float(value), digits)