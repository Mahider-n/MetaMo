from functools import reduce

def listDifference(list1: list, list2: list) -> list:
    return [list1[i] - list2[i] for i in range(len(list1))]

def norm(array:list):
    return reduce(lambda x,y: x+y ,[i**2 for i in array])


def calculate_norm_difference(list1: list, list2: list):
    diff_list = listDifference(list1, list2)
    return round(norm(diff_list), 2)
