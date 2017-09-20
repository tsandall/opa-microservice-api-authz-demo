package example

default allow = false

allow {
    allowed_methods[_] = input.method
}

allowed_methods = {"GET", "POST"}
