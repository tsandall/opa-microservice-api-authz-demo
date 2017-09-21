package service_graph

service_graph = {
    "landing_page": ["details"],
    "reviews": ["ratings"],
}

default allow = false

#allow {
#    input.external = true
#    input.target = "landing_page"
#}
#
#allow {
#    allowed_targets = service_graph[input.source]
#    input.target = allowed_targets[_]
#}
