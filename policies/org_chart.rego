package org_chart

employees = {
    "dracula": {"manager": "janet", "roles": ["engineering"]},
    "alice": {"manager": "janet", "roles": ["engineering"]},
    "janet": {"roles": ["engineering"]},
    "ken": {"roles": ["hr"]},
}

default allow = false

allow {
    not is_private_resource
}

allow {
    read_own_reviews
}

allow {
    read_subordinate_reviews
}

allow {
    is_hr
}

is_private_resource {
    input.path[0] == "reviews"
}

read_own_reviews {
    user := input.user
    input.path == ["reviews", user]
}

read_subordinate_reviews {
    some user
    manager := employees[user].manager
    input.user == manager
    input.path == ["reviews", user]
}

is_hr {
    user := input.user
    employees[user].roles[_] = "hr"
}
