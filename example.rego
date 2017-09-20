package example

default allow = false

allow {
    allowed_methods[_] = input.method
    authenticated
}

authenticated {
    input.user != null
}

allow {
    input.source = "ingress"
    input.target = "productpage"
}


allowed_methods = {"GET", "POST"}
