package org_chart

employees = {
    "bob": {"manager": "janet", "roles": ["engineering"]},
    "alice": {"manager": "janet", "roles": ["engineering"]},
    "janet": {"roles": ["engineering"]},
    "ken": {"roles": ["hr"]},
}

# Allow access to non-sensitive APIs.
allow { not is_sensitive_api }

is_sensitive_api {
    input.path[0] = "reviews"
}

# Allow users access to sensitive APIs serving their own data.
allow {
    input.path = ["reviews", user]
    input.user = user
}

# Allow managers access to sensitive APIs serving their reports' data.
allow {
    input.path = ["reviews", user]
    input.user = employees[user].manager
}

# Allow HR to access all APIs.
allow {
    is_hr
}

is_hr {
    input.user = user
    employees[user].roles[_] = "hr"
}
