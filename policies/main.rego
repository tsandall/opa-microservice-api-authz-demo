package example

import data.service_graph
import data.org_chart

default allow = false

allow {
    service_graph.allow
}

#pii = ["ssn"] {
#    input.path = ["details", user]
#    input.user != user
#    not org_chart.is_hr
#}
